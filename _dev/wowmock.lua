--[[
    A hand-written mock of the WoW 3.3.5a client API, good enough to actually load
    and drive the addons in this workspace under plain Lua (fengari / Lua 5.3).

    Design rule: THERE IS NO CATCH-ALL. If addon code calls an API this file does
    not implement, it errors loudly. That is the point -- a silent stub would hide
    exactly the bugs this harness exists to find.

    MOCK.* is the control surface used by scenario files (see smoke.lua).
--]]

MOCK = {
    errors = {},        -- runtime errors caught by the fake error handler
    printed = {},       -- everything the addons printed
    events = {},        -- event name -> list of frames registered for it
    frames = {},        -- every frame ever created
    addons = {},        -- filled in by run.js from the .toc files
    loaded = {},        -- addon name -> true
    popups = {},        -- StaticPopup_Show calls
    sounds = {},
}

MOCK.say = print        -- real stdout, captured before print is overridden below

loadstring = load       -- Ace3's CreateDispatcher needs loadstring under 5.3
unpack = table.unpack

--[[ Lua 5.1 / WoW string library extensions ]]--

-- WoW's Lua truncates floats for %d; Lua 5.3 raises "number has no integer
-- representation" instead. Emulate 5.1 so the harness does not invent bugs.
local rawformat = string.format
local function compat_format(fmt, ...)
    local args = {...}
    local i = 0
    for spec in tostring(fmt):gmatch('%%[-+ #0-9.]*([diouxXc])') do
        i = i + 1
        if type(args[i]) == 'number' then args[i] = math.floor(args[i]) end
    end
    return rawformat(fmt, table.unpack(args, 1, select('#', ...)))
end
string.format = compat_format
format = compat_format

-- Blizzard adds these to the string table, so ("x"):trim() works in-game
string.trim = function(s) return (s:gsub('^%s*(.-)%s*$', '%1')) end
string.join = function(sep, ...) return table.concat({...}, sep) end

strjoin  = function(sep, ...) return table.concat({...}, sep) end
strtrim  = function(s) return (s:gsub('^%s*(.-)%s*$', '%1')) end
strlower = string.lower
strupper = string.upper
strlen   = string.len
strsub   = string.sub
strrep   = string.rep
strrev   = string.reverse
strbyte  = string.byte
strchar  = string.char
strfind  = string.find
strmatch = string.match
strconcat = function(...) return table.concat({...}) end
tinsert  = table.insert
tremove  = table.remove
tconcat  = table.concat
sort     = table.sort
wipe     = function(t) for k in pairs(t) do t[k] = nil end return t end
abs, ceil, floor, sqrt = math.abs, math.ceil, math.floor, math.sqrt
max, min, mod = math.max, math.min, math.fmod
random   = math.random
date     = os.date
time     = os.time
gcinfo   = function() return 1024 end
-- WoW ships the BitLib 'bit' table; Lua 5.3 has native operators, so wrap them
bit = {
    band   = function(a, b) return a & b end,
    bor    = function(a, b) return a | b end,
    bxor   = function(a, b) return a ~ b end,
    bnot   = function(a) return ~a end,
    lshift = function(a, n) return a << n end,
    rshift = function(a, n) return a >> n end,
    mod    = function(a, b) return a % b end,
}
debugstack = function() return 'stack' end

function strsplit(sep, str)
    local out = {}
    for piece in tostring(str):gmatch('([^' .. sep .. ']*)[' .. sep .. ']?') do
        out[#out + 1] = piece
    end
    if out[#out] == '' then out[#out] = nil end
    return table.unpack(out)
end

--[[ error handling: collect instead of aborting, like the client does ]]--

local errorHandler
function seterrorhandler(f) errorHandler = f end
function geterrorhandler()
    return errorHandler or function(msg) MOCK.errors[#MOCK.errors + 1] = tostring(msg) end
end
seterrorhandler(function(msg) MOCK.errors[#MOCK.errors + 1] = tostring(msg) end)

function securecall(f, ...)
    if type(f) == 'string' then f = _G[f] end
    local ok, err = pcall(f, ...)
    if not ok then geterrorhandler()(err) end
end
scrub = function(...) return ... end
issecurevariable = function() return true end

function hooksecurefunc(tbl, name, hook)
    if type(tbl) == 'string' then tbl, name, hook = _G, tbl, name end
    local orig = tbl[name]
    assert(type(orig) == 'function', 'hooksecurefunc: no function ' .. tostring(name))
    tbl[name] = function(...)
        local r = {orig(...)}
        hook(...)
        return table.unpack(r)
    end
end

print = function(...)
    local parts = {}
    for i = 1, select('#', ...) do parts[i] = tostring((select(i, ...))) end
    MOCK.printed[#MOCK.printed + 1] = table.concat(parts, ' ')
end

--[[ the widget object ]]--

local W = {}
W.__index = W
MOCK.W = W

local function newObject(kind, name, parent)
    local o = setmetatable({
        __kind = kind, __name = name, __parent = parent,
        __shown = true, __width = 0, __height = 0, __alpha = 1, __scale = 1,
        __scripts = {}, __points = {}, __regions = {}, __children = {},
        __events = {}, __text = nil, __enabled = true,
        __vertex = {1, 1, 1, 1}, __color = {1, 1, 1, 1},
    }, W)
    if name then _G[name] = o end
    if parent and parent.__children then parent.__children[#parent.__children + 1] = o end
    MOCK.frames[#MOCK.frames + 1] = o
    return o
end
MOCK.newObject = newObject

function W:GetName() return self.__name end
function W:GetObjectType() return self.__kind end
function W:IsObjectType(t) return self.__kind == t end
function W:GetParent() return self.__parent end
function W:SetParent(p) self.__parent = p end

function W:SetWidth(w) self.__width = w end
function W:SetHeight(h) self.__height = h end
function W:GetWidth() return self.__width end
function W:GetHeight() return self.__height end
-- SetSize/GetSize exist in 3.3.5 and are used by the bundled LibDBIcon;
-- the addon code in this workspace deliberately still uses SetWidth/SetHeight.
function W:SetSize(w, h) self.__width, self.__height = w, h end
function W:GetSize() return self.__width, self.__height end

function W:SetPoint(...) self.__points[#self.__points + 1] = {...} end
function W:SetAllPoints() self.__points[#self.__points + 1] = {'ALL'} end
function W:ClearAllPoints() self.__points = {} end
function W:GetNumPoints() return #self.__points end
function W:GetPoint(i)
    local p = self.__points[i or 1]
    if not p then return nil end
    return p[1], p[2], p[3], p[4], p[5]
end
function W:GetRect() return 0, 0, self.__width, self.__height end
function W:GetLeft() return 0 end
function W:GetRight() return self.__width end
function W:GetTop() return self.__height end
function W:GetBottom() return 0 end
function W:GetCenter() return self.__width / 2, self.__height / 2 end

function W:Show()
    if self.__shown then return end
    self.__shown = true
    if self.__scripts.OnShow then securecall(self.__scripts.OnShow, self) end
end
function W:Hide()
    if not self.__shown then return end
    self.__shown = false
    if self.__scripts.OnHide then securecall(self.__scripts.OnHide, self) end
end
function W:IsShown() return self.__shown end
function W:IsVisible()
    local f = self
    while f do
        if not f.__shown then return false end
        f = f.__parent
    end
    return true
end
function W:IsMouseOver() return self.__mouseOver or false end

function W:SetAlpha(a) self.__alpha = a end
function W:GetAlpha() return self.__alpha end
function W:SetScale(s) self.__scale = s end
function W:GetScale() return self.__scale end
function W:GetEffectiveScale() return self.__scale end
function W:SetFrameStrata(s) self.__strata = s end
function W:GetFrameStrata() return self.__strata or 'MEDIUM' end
function W:SetFrameLevel(l) self.__level = l end
function W:GetFrameLevel() return self.__level or 1 end
function W:SetToplevel() end
function W:SetClampedToScreen() end
function W:SetMovable(v) self.__movable = v end
function W:IsMovable() return self.__movable end
function W:SetResizable() end
function W:SetUserPlaced(v) self.__userPlaced = v end
function W:IsUserPlaced() return self.__userPlaced end
function W:SetDontSavePosition() end
function W:StartMoving() self.__moving = true end
function W:StopMovingOrSizing() self.__moving = false end
function W:EnableMouse(v) self.__mouse = v end
function W:IsMouseEnabled() return self.__mouse end
function W:EnableMouseWheel() end
function W:EnableKeyboard() end
function W:SetHitRectInsets() end
function W:SetID(id) self.__id = id end
function W:GetID() return self.__id or 0 end
function W:Raise() end
function W:Lower() end
function W:SetPropagateKeyboardInput() end
function W:RegisterForClicks(...) self.__clicks = {...} end
function W:RegisterForDrag(...) self.__drag = {...} end
function W:SetAttribute(k, v) self.__attr = self.__attr or {} self.__attr[k] = v end
function W:GetAttribute(k) return self.__attr and self.__attr[k] end

function W:SetScript(name, fn) self.__scripts[name] = fn end
function W:GetScript(name) return self.__scripts[name] end
function W:HasScript() return true end
function W:HookScript(name, fn)
    local orig = self.__scripts[name]
    self.__scripts[name] = function(...)
        if orig then orig(...) end
        fn(...)
    end
end

-- drive a script the way the client would
function W:Fire(name, ...)
    local fn = self.__scripts[name]
    if fn then securecall(fn, self, ...) end
end
function W:Click(button)
    self:Fire('PreClick', button or 'LeftButton')
    self:Fire('OnClick', button or 'LeftButton')
    self:Fire('PostClick', button or 'LeftButton')
end

function W:RegisterEvent(e)
    self.__events[e] = true
    MOCK.events[e] = MOCK.events[e] or {}
    for _, f in ipairs(MOCK.events[e]) do if f == self then return end end
    table.insert(MOCK.events[e], self)
end
function W:UnregisterEvent(e)
    self.__events[e] = nil
    local list = MOCK.events[e]
    if not list then return end
    for i = #list, 1, -1 do if list[i] == self then table.remove(list, i) end end
end
function W:UnregisterAllEvents()
    for e in pairs(self.__events) do self:UnregisterEvent(e) end
end
function W:IsEventRegistered(e) return self.__events[e] or false end

function W:CreateTexture(name, layer)
    local t = newObject('Texture', name, self)
    self.__regions[#self.__regions + 1] = t
    t.__layer = layer
    return t
end
function W:CreateFontString(name, layer)
    local t = newObject('FontString', name, self)
    self.__regions[#self.__regions + 1] = t
    t.__layer = layer
    return t
end
function W:GetRegions() return table.unpack(self.__regions) end
function W:GetNumRegions() return #self.__regions end
function W:GetChildren() return table.unpack(self.__children) end
function W:GetNumChildren() return #self.__children end

-- texture / fontstring
function W:SetTexture(...) self.__texture = ... end
function W:GetTexture() return self.__texture end
function W:SetTexCoord(...) self.__texcoord = {...} end
function W:GetTexCoord() return table.unpack(self.__texcoord or {0, 1, 0, 1}) end
function W:SetBlendMode(m) self.__blend = m end
function W:SetVertexColor(r, g, b, a) self.__vertex = {r, g, b, a or 1} end
function W:GetVertexColor() return table.unpack(self.__vertex) end
function W:SetDesaturated(v) self.__desat = v return true end
function W:IsDesaturated() return self.__desat end
function W:SetDrawLayer(l) self.__layer = l end
function W:GetDrawLayer() return self.__layer end
function W:SetGradientAlpha() end
function W:SetHorizTile() end
function W:SetVertTile() end

function W:SetText(t) self.__text = t end
function W:GetText() return self.__text end
function W:SetFormattedText(fmt, ...) self.__text = string.format(fmt, ...) end
function W:SetFont(f, s, fl) self.__font = {f, s, fl} return true end
function W:GetFont() return table.unpack(self.__font or {'Fonts/FRIZQT__.TTF', 12, ''}) end
function W:SetFontObject(o) self.__fontObject = o end
function W:GetFontObject() return self.__fontObject end
function W:SetTextColor(r, g, b, a) self.__color = {r, g, b, a or 1} end
function W:GetTextColor() return table.unpack(self.__color) end
function W:SetShadowColor() end
function W:SetShadowOffset() end
function W:SetJustifyH(j) self.__justifyH = j end
function W:SetJustifyV(j) self.__justifyV = j end
function W:GetJustifyH() return self.__justifyH or 'CENTER' end
function W:SetWordWrap() end
function W:SetNonSpaceWrap() end
function W:GetStringWidth() return #(self.__text or '') * 6 end
function W:GetStringHeight() return 12 end
function W:SetMaxLines() end
function W:SetSpacing() end
function W:SetIndentedWordWrap() end

-- backdrop (3.3.5 style: a plain method, no BackdropTemplate)
function W:SetBackdrop(b) self.__backdrop = b end
function W:GetBackdrop() return self.__backdrop end
function W:SetBackdropColor(r, g, b, a) self.__bdColor = {r, g, b, a or 1} end
function W:GetBackdropColor() return table.unpack(self.__bdColor or {0, 0, 0, 1}) end
function W:SetBackdropBorderColor(r, g, b, a) self.__bdBorder = {r, g, b, a or 1} end
function W:GetBackdropBorderColor() return table.unpack(self.__bdBorder or {1, 1, 1, 1}) end

-- button
function W:SetNormalTexture(t)
    self.__normal = self.__normal or newObject('Texture', nil, self)
    if type(t) ~= 'table' then self.__normal.__texture = t end
    return self.__normal
end
function W:GetNormalTexture() return self.__normal or self:SetNormalTexture() end
function W:SetPushedTexture() self.__pushed = self.__pushed or newObject('Texture', nil, self) return self.__pushed end
function W:GetPushedTexture() return self.__pushed or self:SetPushedTexture() end
function W:SetHighlightTexture() self.__highlight = self.__highlight or newObject('Texture', nil, self) return self.__highlight end
function W:GetHighlightTexture() return self.__highlight or self:SetHighlightTexture() end
function W:SetDisabledTexture() self.__disabled = self.__disabled or newObject('Texture', nil, self) return self.__disabled end
function W:GetDisabledTexture() return self.__disabled or self:SetDisabledTexture() end
function W:SetCheckedTexture() self.__checked = self.__checked or newObject('Texture', nil, self) return self.__checked end
function W:GetCheckedTexture() return self.__checked or self:SetCheckedTexture() end
function W:SetNormalFontObject(o) self.__normalFont = o end
function W:SetHighlightFontObject() end
function W:SetDisabledFontObject() end
function W:SetTextFontObject() end
function W:GetFontString()
    self.__fontString = self.__fontString or newObject('FontString', nil, self)
    return self.__fontString
end
function W:SetFontString(fs) self.__fontString = fs end
-- Button:GetTextWidth/GetTextHeight exist in 3.3.5
function W:GetTextWidth() return #(self.__text or '') * 6 end
function W:GetTextHeight() return 12 end
function W:SetPushedTextOffset() end
function W:Enable() self.__enabled = true end
function W:Disable() self.__enabled = false end
function W:IsEnabled() return self.__enabled end
function W:SetEnabled(v) self.__enabled = v end
function W:SetChecked(v) self.__isChecked = v and true or false end
function W:GetChecked() return self.__isChecked end
function W:LockHighlight() end
function W:UnlockHighlight() end
function W:SetButtonState(s) self.__state = s end
function W:GetButtonState() return self.__state or 'NORMAL' end
function W:SetMotionScriptsWhileDisabled() end

-- slider
function W:SetMinMaxValues(a, b) self.__min, self.__max = a, b end
function W:GetMinMaxValues() return self.__min or 0, self.__max or 1 end
function W:SetValue(v)
    self.__value = v
    if self.__scripts.OnValueChanged then securecall(self.__scripts.OnValueChanged, self, v) end
end
function W:GetValue() return self.__value or self.__min or 0 end
function W:SetValueStep(s) self.__step = s end
function W:GetValueStep() return self.__step or 1 end
function W:SetOrientation(o) self.__orientation = o end
function W:SetThumbTexture() self.__thumb = self.__thumb or newObject('Texture', nil, self) return self.__thumb end
function W:GetThumbTexture() return self.__thumb or self:SetThumbTexture() end
function W:SetObeyStepOnDrag() end
function W:SetStepsPerPage() end

-- editbox
function W:SetAutoFocus(v) self.__autoFocus = v end
function W:SetFocus() self.__focus = true end
function W:ClearFocus()
    self.__focus = false
    if self.__scripts.OnEditFocusLost then securecall(self.__scripts.OnEditFocusLost, self) end
end
function W:HasFocus() return self.__focus end
function W:SetMaxLetters() end
function W:SetNumeric() end
function W:SetMultiLine() end
function W:SetCursorPosition() end
function W:HighlightText() end
function W:Insert(s) self.__text = (self.__text or '') .. s end
function W:SetAltArrowKeyMode() end
function W:SetTextInsets() end
function W:GetNumLetters() return #(self.__text or '') end
function W:AddHistoryLine() end
function W:SetHistoryLines() end

-- type into an editbox the way a player would
function W:Type(text)
    self.__text = text
    self:Fire('OnTextChanged', true)
end

-- scrollframe
function W:SetScrollChild(c) self.__scrollChild = c end
function W:GetScrollChild() return self.__scrollChild end
function W:SetVerticalScroll(v) self.__vscroll = v end
function W:GetVerticalScroll() return self.__vscroll or 0 end
function W:GetVerticalScrollRange() return 100 end
function W:SetHorizontalScroll() end
function W:GetHorizontalScroll() return 0 end
function W:UpdateScrollChildRect() end

-- cooldown / statusbar / model
function W:SetCooldown(start, dur) self.__cooldown = {start, dur} end
function W:SetReverse() end
function W:SetStatusBarTexture() self.__sbTexture = self.__sbTexture or newObject('Texture', nil, self) return self.__sbTexture end
function W:GetStatusBarTexture() return self.__sbTexture or self:SetStatusBarTexture() end
function W:SetStatusBarColor(...) self.__sbColor = {...} end
function W:SetModel() end
function W:SetModelScale() end
function W:ClearModel() end

-- there are no animation groups in 3.3.5; fail loudly if anything reaches for one
function W:CreateAnimationGroup() error('CreateAnimationGroup does not exist in 3.3.5') end

local FRAME_TYPES = {
    Frame = true, Button = true, CheckButton = true, Slider = true, EditBox = true,
    ScrollFrame = true, StatusBar = true, GameTooltip = true, Cooldown = true,
    ColorSelect = true, MessageFrame = true, ScrollingMessageFrame = true,
    SimpleHTML = true, Model = true, PlayerModel = true, DressUpModel = true,
    Minimap = true, MovieFrame = true,
}

function CreateFrame(kind, name, parent, template, id)
    assert(FRAME_TYPES[kind], 'CreateFrame: unknown frame type ' .. tostring(kind))
    local f = newObject(kind, name, parent)
    f.__template = template
    if id then f.__id = id end
    if kind == 'GameTooltip' then MOCK.makeTooltip(f) end
    if template and template:find('ItemButton') then
        f.__icon = newObject('Texture', name and (name .. 'IconTexture') or nil, f)
        f.__count = newObject('FontString', name and (name .. 'Count') or nil, f)
        f.__stock = newObject('FontString', name and (name .. 'Stock') or nil, f)
        f.__borderTex = newObject('Texture', name and (name .. 'NormalTexture') or nil, f)
        f.__cooldownFrame = newObject('Cooldown', name and (name .. 'Cooldown') or nil, f)
    end
    -- Blizzard's templates create named child regions the addons look up by name
    if template and template:find('CheckButtonTemplate') then
        f.__labelText = MOCK.newObject('FontString', name and (name .. 'Text') or nil, f)
    end
    if template and template:find('SliderTemplate') then
        f.__labelText = MOCK.newObject('FontString', name and (name .. 'Text') or nil, f)
        MOCK.newObject('FontString', name and (name .. 'Low') or nil, f)
        MOCK.newObject('FontString', name and (name .. 'High') or nil, f)
    end
    if template and template:find('UIPanelButton') then
        f.__fontString = newObject('FontString', name and (name .. 'Text') or nil, f)
    end
    return f
end

function EnumerateFrames(prev)
    if not prev then return MOCK.frames[1] end
    for i, f in ipairs(MOCK.frames) do if f == prev then return MOCK.frames[i + 1] end end
end

--[[ event dispatch ]]--

function MOCK.fire(event, ...)
    local list = MOCK.events[event]
    if not list then return 0 end
    local n = 0
    for _, f in ipairs({table.unpack(list)}) do
        local fn = f.__scripts.OnEvent
        if fn and f.__events[event] then
            n = n + 1
            local ok, err = pcall(fn, f, event, ...)
            if not ok then MOCK.errors[#MOCK.errors + 1] = event .. ': ' .. tostring(err) end
        end
    end
    return n
end

function MOCK.update(elapsed)
    for _, f in ipairs({table.unpack(MOCK.frames)}) do
        if f.__scripts.OnUpdate and f:IsVisible() then
            local ok, err = pcall(f.__scripts.OnUpdate, f, elapsed or 0.1)
            if not ok then MOCK.errors[#MOCK.errors + 1] = 'OnUpdate: ' .. tostring(err) end
        end
    end
end
