--[[
	Config.lua
		Interface Options panel (Esc > Interface > AddOns > Quest Item Helper) and slash commands.
		Plain Blizzard widgets: the panel is small enough that Ace3 would only add weight.
--]]

local addonName, QIH = ...

local _G = _G
local ipairs, format, lower = ipairs, string.format, string.lower
local GetContainerItemLink = GetContainerItemLink

local PANEL_NAME = 'Quest Item Helper'

local OPTIONS = {
	{ key = 'enabled', label = 'Enable Quest Item Helper',
		tip = 'Turn the whole addon on or off.' },
	{ key = 'highlightEnabled', label = 'Highlight items in bags',
		tip = 'Draw a colored border around old quest items.' },
	{ key = 'showIcon', label = 'Show warning icon',
		tip = 'Add a small warning icon to the corner of flagged items.' },
	{ key = 'showQuestTick', label = 'Tick quest items you still need',
		tip = 'Add a ringed tick to the corner of quest items that a quest in your log still needs.' },
	{ key = 'tooltipEnabled', label = 'Add tooltip information',
		tip = 'Explain in the item tooltip why an item was flagged and which quest it belongs to.' },
	{ key = 'onlyCompleted', label = 'Only flag when the quest is completely inactive (turned in)',
		tip = 'Ignore items of quests that merely left your log (abandoned quests can be picked up again). Only flag items whose quest the server reports as completed.' },
	{ key = 'flagUnlinked', label = 'Also flag quest items no current quest uses (less certain)',
		tip = 'Flag "Quest Item" items that no quest in your log mentions, even when the addon never saw which quest they belong to. Can include items for quests you have not picked up yet.' },
	{ key = 'debug', label = 'Debug output in chat',
		tip = 'Print how each quest item in your bags was judged.' },
}

--[[ options panel ]]--

local COLORS = {
	{ key = 'highlightColor', label = 'Highlight color (click to change)' },
	{ key = 'tickColor', label = 'Quest tick color (click to change)' },
}

local panel, checks, swatches

local function SettingChanged()
	QIH:Invalidate()
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

local function RefreshPanel()
	local db = QIH.db
	for _, check in ipairs(checks) do
		check:SetChecked(db[check.key])
	end
	for _, swatch in ipairs(swatches) do
		local color = db[swatch.key]
		swatch.texture:SetVertexColor(color.r, color.g, color.b)
	end
end

local function CreateSwatch(option, anchor, offsetX, offsetY)
	local swatch = CreateFrame('Button', nil, panel)
	swatch.key = option.key
	swatch:SetWidth(18)
	swatch:SetHeight(18)
	swatch:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', offsetX, offsetY)
	local background = swatch:CreateTexture(nil, 'BACKGROUND')
	background:SetTexture(1, 1, 1)
	background:SetAllPoints()
	swatch.texture = swatch:CreateTexture(nil, 'ARTWORK')
	swatch.texture:SetTexture(1, 1, 1)
	swatch.texture:SetPoint('TOPLEFT', 2, -2)
	swatch.texture:SetPoint('BOTTOMRIGHT', -2, 2)
	swatch:SetScript('OnClick', OpenColorPicker)

	local label = panel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlight')
	label:SetPoint('LEFT', swatch, 'RIGHT', 8, 0)
	label:SetText(option.label)
	return swatch
end

local function CreatePanel()
	panel = CreateFrame('Frame', 'QuestItemHelperOptions', UIParent)
	panel.name = PANEL_NAME
	panel:Hide()

	local title = panel:CreateFontString(nil, 'ARTWORK', 'GameFontNormalLarge')
	title:SetPoint('TOPLEFT', 16, -16)
	title:SetText(PANEL_NAME)

	local subtitle = panel:CreateFontString(nil, 'ARTWORK', 'GameFontHighlightSmall')
	subtitle:SetPoint('TOPLEFT', title, 'BOTTOMLEFT', 0, -8)
	subtitle:SetPoint('RIGHT', panel, 'RIGHT', -32, 0)
	subtitle:SetJustifyH('LEFT')
	subtitle:SetText('Highlights quest items in your bags whose quest you no longer have. It never deletes, sells or moves anything.')

	checks = {}
	local anchor = subtitle
	for i, option in ipairs(OPTIONS) do
		local name = 'QuestItemHelperOptionsCheck' .. i
		local check = CreateFrame('CheckButton', name, panel, 'InterfaceOptionsCheckButtonTemplate')
		check:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', i == 1 and -2 or 0, i == 1 and -16 or -6)
		_G[name .. 'Text']:SetText(option.label)
		check.tooltipText = option.label
		check.tooltipRequirement = option.tip
		check.key = option.key
		check:SetScript('OnClick', function(self)
			QIH.db[self.key] = self:GetChecked() and true or false
			SettingChanged()
		end)
		checks[#checks + 1] = check
		anchor = check
	end

	swatches = {}
	for i, option in ipairs(COLORS) do
		anchor = CreateSwatch(option, anchor, i == 1 and 6 or 0, i == 1 and -12 or -8)
		swatches[#swatches + 1] = anchor
	end

	local scan = CreateFrame('Button', 'QuestItemHelperOptionsScan', panel, 'UIPanelButtonTemplate')
	scan:SetWidth(120)
	scan:SetHeight(22)
	scan:SetPoint('TOPLEFT', anchor, 'BOTTOMLEFT', -4, -16)
	scan:SetText('Rescan bags')
	scan:SetScript('OnClick', function()
		QIH:SlashCommand('scan')
	end)

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
	elseif command == 'reset' then
		self:ResetSettings()
		if panel and panel:IsShown() then
			RefreshPanel()
		end
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
