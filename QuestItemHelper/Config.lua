--[[
	Config.lua
		Interface Options panel (Esc > Interface > AddOns > Quest Item Helper) and slash commands.
		Plain Blizzard widgets: the panel is small enough that Ace3 would only add weight.

		Layout: every control is placed at an absolute offset from the panel's top-left corner by a
		single running cursor, so the whole panel can be checked against the 3.3.5 options area
		(413x428) and nothing depends on the measured height of a wrapped string.
--]]

local addonName, QIH = ...

local _G = _G
local pairs, ipairs, unpack, format, lower = pairs, ipairs, unpack, string.format, string.lower
local GetContainerItemLink = GetContainerItemLink

local PANEL_NAME = 'Quest Item Helper'

-- the panel area of the 3.3.5 Interface Options window
local PANEL_WIDTH, PANEL_HEIGHT = 413, 428
local MARGIN = 16           -- outer padding
local ROW = 26              -- one checkbox row (the template is 26px tall)
local INDENT = 18           -- children of another option
local SECTION_GAP = 10      -- space above a section header

-- section headers and option rows, top to bottom. `parent` names the option that must be on for
-- this one to mean anything; `color` puts a swatch on the row's right edge.
local LAYOUT = {
	{ key = 'enabled', label = 'Enable Quest Item Helper',
		tip = 'Turn the whole addon on or off. Nothing is scanned while it is off.' },

	{ section = 'In your bags' },
	{ key = 'highlightEnabled', label = 'Highlight old quest items', parent = 'enabled',
		color = 'highlightColor', colorLabel = 'Highlight color',
		tip = 'Draw a colored border around quest items whose quest you no longer have.' },
	{ key = 'showIcon', label = 'Add a warning icon', parent = 'highlightEnabled', indent = true,
		tip = 'Add a small warning icon to the corner of highlighted items.' },
	{ key = 'showQuestTick', label = 'Tick quest items you still need', parent = 'enabled',
		color = 'tickColor', colorLabel = 'Tick color',
		tip = 'Add a ringed tick to the corner of quest items that a quest in your log still needs.' },

	{ section = 'Tooltips' },
	{ key = 'tooltipEnabled', label = 'Explain the verdict in item tooltips', parent = 'enabled',
		tip = 'Say in the item tooltip why an item was highlighted or ticked, and which quest it belongs to.' },

	{ section = 'Detection' },
	{ key = 'onlyCompleted', label = 'Only highlight items of turned-in quests', parent = 'enabled',
		tip = 'Ignore items of quests that merely left your log (abandoned quests can be picked up again). Only highlight items whose quest the server reports as completed.' },
	{ key = 'flagUnlinked', label = 'Also highlight unlinked quest items', parent = 'enabled',
		tip = 'Less certain: also highlight "Quest Item" items that no quest in your log mentions, even when the addon never saw which quest they belong to. Can include items for quests you have not picked up yet.' },
}

local DEBUG_OPTION = { key = 'debug', label = 'Debug output in chat',
	tip = 'Print how each quest item in your bags was judged. Useful when reporting a wrong verdict.' }

local DISABLED_REASON = {
	enabled = 'Enable Quest Item Helper first.',
	highlightEnabled = 'Turn on "Highlight old quest items" first.',
	showQuestTick = 'Turn on "Tick quest items you still need" first.',
}

-- Visual tokens. These mirror Bagnon's design system (Bagnon/utility/style.lua) on purpose: this
-- panel sits next to Bagnon's in Interface Options and the overlays draw on Bagnon's slots, so the
-- two should read as one product. They are copied, not imported, because Bagnon is only an
-- optional dependency; keep them in step with style.lua by hand.
local STYLE = {
	FLAT = [[Interface\Buttons\WHITE8X8]],
	muted = { 0.62, 0.62, 0.65 },
	accent = { 1, 0.82, 0 },
	divider = { 1, 1, 1, 0.08 },
	buttonBorder = { 0.3, 0.3, 0.33, 1 },
	warning = { 1, 0.3, 0.25 },        -- the red disabled-reason line, as in Bagnon_Config
	goodHex = '4ce666',                -- colors.good
	warningHex = 'ffb833',             -- colors.warning
	mutedHex = '9e9ea6',               -- colors.muted
}
-- crisp 1px chrome for small controls, Bagnon's Style.flatBackdrop
local FLAT_BACKDROP = {
	bgFile = STYLE.FLAT, edgeFile = STYLE.FLAT, edgeSize = 1,
	insets = { left = 1, right = 1, top = 1, bottom = 1 },
}

--[[ options panel ]]--

local panel, checks, swatches, status

local function IsOn(key)
	return QIH.db[key] and true or false
end

-- an option is usable when every option above it in its parent chain is on
local function IsAvailable(key)
	local option = checks and checks[key] and checks[key].option
	local parent = option and option.parent
	while parent do
		if not IsOn(parent) then
			return false, parent
		end
		parent = checks[parent] and checks[parent].option.parent
	end
	return true
end

-- one tooltip shape for every control: white title, wrapped description, then an optional red
-- line saying why the control is disabled (the same layout Bagnon_Config's widgets use)
local function ShowTooltip(owner, title, description, warning)
	GameTooltip:SetOwner(owner, 'ANCHOR_RIGHT')
	GameTooltip:SetText(title, 1, 1, 1)
	if description then
		GameTooltip:AddLine(description, nil, nil, nil, true)
	end
	if warning then
		GameTooltip:AddLine(warning, STYLE.warning[1], STYLE.warning[2], STYLE.warning[3], true)
	end
	GameTooltip:Show()
end

local function HideTooltip(owner)
	if GameTooltip:IsOwned(owner) then
		GameTooltip:Hide()
	end
end

local function SetCheckEnabled(check, enabled, blockedBy)
	local text = _G[check:GetName() .. 'Text']
	if enabled then
		check:Enable()
		text:SetFontObject('GameFontHighlight')
		check.tooltipWarning = nil
	else
		check:Disable()
		text:SetFontObject('GameFontDisable')
		-- say why, instead of leaving a control that silently does nothing
		check.tooltipWarning = DISABLED_REASON[blockedBy]
	end
end

local function SetSwatchEnabled(swatch, enabled)
	swatch:EnableMouse(enabled)
	swatch:SetAlpha(enabled and 1 or 0.35)
end

local function CountFlagged()
	local count = 0
	QIH:ForEachFlagged(function() count = count + 1 end)
	return count
end

local function UpdateStatus()
	if not status then
		return
	end
	local db = QIH.db
	if not db.enabled then
		status:SetText(format('|cff%sOff. Nothing is being scanned.|r', STYLE.mutedHex))
	elseif not QIH:IsReady() then
		status:SetText(format('|cff%sWaiting for the quest log to load...|r', STYLE.warningHex))
	else
		local count = CountFlagged()
		if count == 0 then
			status:SetText(format('|cff%sActive.|r No old quest items in your bags.', STYLE.goodHex))
		else
			status:SetText(format('|cff%sActive.|r |cff%s%d|r old quest item slot%s in your bags (/qih list).',
				STYLE.goodHex, STYLE.warningHex, count, count == 1 and '' or 's'))
		end
	end
end

local function RefreshPanel()
	if not panel then
		return
	end
	local db = QIH.db
	for _, check in pairs(checks) do
		check:SetChecked(db[check.option.key])
		SetCheckEnabled(check, IsAvailable(check.option.key))
	end
	for _, swatch in ipairs(swatches) do
		local color = db[swatch.key]
		swatch.texture:SetVertexColor(color.r, color.g, color.b)
		local owner = swatch.owner
		SetSwatchEnabled(swatch, IsOn(owner) and (IsAvailable(owner)))
	end
	UpdateStatus()
end

-- Core calls this after every full scan, so an open panel's status line never goes stale
function QIH:UpdateConfigStatus()
	if panel and panel:IsShown() then
		UpdateStatus()
	end
end

local function SettingChanged()
	QIH:Invalidate()
	RefreshPanel()
end

local function SetColor(swatch, r, g, b)
	local color = QIH.db[swatch.key]
	color.r, color.g, color.b = r, g, b
	swatch.texture:SetVertexColor(r, g, b)
	QIH:RefreshButtons()
end

local function OpenColorPicker(swatch)
	local picker = _G.ColorPickerFrame
	local color = QIH.db[swatch.key]
	local previous = { color.r, color.g, color.b }
	picker:Hide()
	picker.hasOpacity = false
	picker.opacityFunc = nil
	picker.previousValues = previous
	picker.func = function()
		SetColor(swatch, picker:GetColorRGB())
	end
	picker.cancelFunc = function()
		SetColor(swatch, previous[1], previous[2], previous[3])
	end
	picker:SetColorRGB(color.r, color.g, color.b)
	ShowUIPanel(picker)
end

local SWATCH_SIZE = 20

local function Swatch_OnEnter(swatch)
	swatch:SetBackdropBorderColor(STYLE.accent[1], STYLE.accent[2], STYLE.accent[3], 1)
	ShowTooltip(swatch, swatch.label, 'Click to change.')
end

local function Swatch_OnLeave(swatch)
	swatch:SetBackdropBorderColor(unpack(STYLE.buttonBorder))
	HideTooltip(swatch)
end

-- a colour square with a 1px frame that turns gold on hover: Bagnon_Config's colour selector
local function CreateSwatch(option, y)
	local swatch = CreateFrame('Button', nil, panel)
	swatch.key, swatch.owner, swatch.label = option.color, option.key, option.colorLabel
	swatch:SetWidth(SWATCH_SIZE)
	swatch:SetHeight(SWATCH_SIZE)
	swatch:SetPoint('TOPLEFT', panel, 'TOPLEFT', PANEL_WIDTH - MARGIN - SWATCH_SIZE, y - (ROW - SWATCH_SIZE) / 2)
	swatch:SetBackdrop(FLAT_BACKDROP)
	swatch:SetBackdropColor(0, 0, 0, 1)
	swatch:SetBackdropBorderColor(unpack(STYLE.buttonBorder))

	swatch.texture = swatch:CreateTexture(nil, 'OVERLAY')
	swatch.texture:SetTexture(STYLE.FLAT)
	swatch.texture:SetPoint('TOPLEFT', 2, -2)
	swatch.texture:SetPoint('BOTTOMRIGHT', -2, 2)

	swatch:SetScript('OnClick', OpenColorPicker)
	swatch:SetScript('OnEnter', Swatch_OnEnter)
	swatch:SetScript('OnLeave', Swatch_OnLeave)
	return swatch
end

local checkCount = 0
local function CreateCheck(option, x, y)
	checkCount = checkCount + 1
	local name = 'QuestItemHelperOptionsCheck' .. checkCount
	local check = CreateFrame('CheckButton', name, panel, 'InterfaceOptionsCheckButtonTemplate')
	check:SetPoint('TOPLEFT', panel, 'TOPLEFT', x, y)
	_G[name .. 'Text']:SetText(option.label)
	check.option = option
	-- our own handlers rather than the template's tooltipText/tooltipRequirement, so the layout
	-- matches the rest of the panel and the disabled reason gets its own red line
	check:SetScript('OnEnter', function(self)
		ShowTooltip(self, self.option.label, self.option.tip, self.tooltipWarning)
	end)
	check:SetScript('OnLeave', HideTooltip)
	check:SetScript('OnClick', function(self)
		QIH.db[self.option.key] = self:GetChecked() and true or false
		SettingChanged()
	end)
	checks[option.key] = check
	return check
end

local function CreateRule(y)
	local rule = panel:CreateTexture(nil, 'ARTWORK')
	rule:SetTexture(unpack(STYLE.divider))
	rule:SetHeight(1)
	rule:SetPoint('TOPLEFT', panel, 'TOPLEFT', MARGIN, y)
	rule:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -MARGIN, y)
	return rule
end

-- gold section title with a faint rule underneath: Bagnon_Config's OptionsPanel:CreateSection
local function CreateSection(text, y)
	local label = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	label:SetPoint('TOPLEFT', panel, 'TOPLEFT', MARGIN, y)
	label:SetJustifyH('LEFT')
	label:SetText(text)
	CreateRule(y - 15)
	return 22
end

local function CreatePanel()
	panel = CreateFrame('Frame', 'QuestItemHelperOptions', UIParent)
	panel.name = PANEL_NAME
	panel:Hide()
	checks, swatches = {}, {}

	local y = -MARGIN

	local title = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	title:SetPoint('TOPLEFT', panel, 'TOPLEFT', MARGIN, y)
	title:SetText(PANEL_NAME)

	local version = _G.GetAddOnMetadata and _G.GetAddOnMetadata(addonName, 'Version')
	if version then
		local versionText = panel:CreateFontString(nil, 'ARTWORK', 'GameFontDisableSmall')
		versionText:SetPoint('TOPRIGHT', panel, 'TOPRIGHT', -MARGIN, y - 4)
		versionText:SetText('v' .. version)
	end
	y = y - 22

	local subtitle = panel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	subtitle:SetPoint('TOPLEFT', panel, 'TOPLEFT', MARGIN, y)
	subtitle:SetWidth(PANEL_WIDTH - 2 * MARGIN)
	subtitle:SetHeight(24)
	subtitle:SetJustifyH('LEFT')
	subtitle:SetJustifyV('TOP')
	subtitle:SetTextColor(unpack(STYLE.muted))
	subtitle:SetText('Marks quest items whose quest you no longer have. It only shows information: nothing is ever deleted, sold or moved.')
	y = y - 28

	status = panel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	status:SetPoint('TOPLEFT', panel, 'TOPLEFT', MARGIN, y)
	status:SetWidth(PANEL_WIDTH - 2 * MARGIN)
	status:SetJustifyH('LEFT')
	y = y - 18

	for _, option in ipairs(LAYOUT) do
		if option.section then
			y = y - SECTION_GAP
			y = y - CreateSection(option.section, y)
		else
			local x = MARGIN - 2 + (option.indent and INDENT or 0)
			CreateCheck(option, x, y)
			if option.color then
				swatches[#swatches + 1] = CreateSwatch(option, y)
			end
			y = y - ROW
		end
	end

	-- footer: troubleshooting on one line, below a rule
	y = y - SECTION_GAP
	CreateRule(y)
	y = y - 8

	CreateCheck(DEBUG_OPTION, MARGIN - 2, y)

	local scan = CreateFrame('Button', 'QuestItemHelperOptionsScan', panel, 'UIPanelButtonTemplate')
	scan:SetWidth(110)
	scan:SetHeight(22)
	scan:SetPoint('TOPLEFT', panel, 'TOPLEFT', PANEL_WIDTH - MARGIN - 110, y - 2)
	scan:SetText('Rescan bags')
	scan:SetScript('OnClick', function()
		QIH:SlashCommand('scan')
	end)
	scan:SetScript('OnEnter', function(self)
		ShowTooltip(self, 'Rescan bags', 'Forget every cached verdict, re-read the quest log and judge every bag slot again.')
	end)
	scan:SetScript('OnLeave', HideTooltip)
	panel.scanButton = scan
	panel.layoutBottom = -(y - ROW)

	panel:SetScript('OnShow', RefreshPanel)
	panel.default = function()
		QIH:ResetSettings()
		RefreshPanel()
	end
	_G.InterfaceOptions_AddCategory(panel)
end

function QIH:OpenConfig()
	if not panel then
		return
	end
	-- 3.3.5 quirk: the first call only opens the frame on its last page, the second selects ours
	_G.InterfaceOptionsFrame_OpenToCategory(panel)
	_G.InterfaceOptionsFrame_OpenToCategory(panel)
end

QIH.PANEL_WIDTH, QIH.PANEL_HEIGHT = PANEL_WIDTH, PANEL_HEIGHT

--[[ slash commands ]]--

local function PrintHelp()
	QIH:Print('commands:')
	QIH:Print('  /qih scan - rescan your bags now')
	QIH:Print('  /qih list - list flagged items in chat')
	QIH:Print('  /qih config - open the options')
	QIH:Print('  /qih debug - toggle debug output')
	QIH:Print('  /qih reset - restore default settings')
	QIH:Print('  /qih forget - also forget learned item/quest links')
end

local function ListFlagged()
	local count = 0
	QIH:ForEachFlagged(function(bag, slot, itemID)
		count = count + 1
		QIH:Print(format('bag %d slot %d: %s', bag, slot, GetContainerItemLink(bag, slot) or ('item ' .. itemID)))
	end)
	if count == 0 then
		QIH:Print('no old quest items found in your bags.')
	end
end

local function RefreshPanelIfShown()
	if panel and panel:IsShown() then
		RefreshPanel()
	end
end

function QIH:SlashCommand(input)
	local command = lower((input or ''):match('^%s*(%S*)') or '')
	if command == 'scan' then
		local count = self:FullRescan()
		if not self.db.enabled then
			self:Print('the addon is disabled (/qih config).')
		elseif not self:IsReady() then
			self:Print('your quest log has not loaded yet, try again in a moment.')
		else
			self:Print(format('scan complete, %d old quest item slot(s) flagged.', count))
		end
		RefreshPanelIfShown()
	elseif command == 'list' then
		ListFlagged()
	elseif command == 'config' or command == 'options' then
		self:OpenConfig()
	elseif command == 'debug' then
		self.db.debug = not self.db.debug
		self:Print('debug output ' .. (self.db.debug and 'enabled' or 'disabled') .. '.')
		if self.db.debug then
			self:FullRescan()
		end
		RefreshPanelIfShown()
	elseif command == 'reset' then
		self:ResetSettings()
		RefreshPanelIfShown()
		self:Print('settings restored to defaults.')
	elseif command == 'forget' then
		self:ForgetKnowledge()
		self:Print('learned item/quest links cleared.')
	elseif command == '' then
		self:Print(format('%s. /qih help for commands.', self.db.enabled and 'enabled' or 'disabled'))
		ListFlagged()
	else
		PrintHelp()
	end
end

--[[ startup, called from Core once the SavedVariables are loaded ]]--

function QIH:OnInitialize()
	CreatePanel()
	self:InstallTooltip()
	self:InstallAdapters()

	_G.SLASH_QUESTITEMHELPER1 = '/qih'
	_G.SLASH_QUESTITEMHELPER2 = '/questitemhelper'
	_G.SlashCmdList.QUESTITEMHELPER = function(input)
		QIH:SlashCommand(input)
	end
end
