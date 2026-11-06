local _, HSN = ...

-- Ordinary overhead names are rendered by the client. Test the supported
-- names-only friendly plates instead; never change shared name-format APIs.
local cvars = {
    nameplateShowFriendlyPlayers = "1",
    nameplateShowOnlyNameForFriendlyPlayerUnits = "1",
    nameplatePlayerMaxDistance = "100",
}

-- World names use UNIT_NAME_FONT, rather than the nameplate font. Their
-- perspective sizing is native code; 14 UI units is an approximation to test.
local NAME_SIZE = 14
local styles = setmetatable({}, { __mode = "k" })

local function RestoreStyle(text)
    local style = styles[text]
    if not style then return end
    text:SetFont(style.font, style.size, style.flags)
    text:SetShadowOffset(style.shadowX, style.shadowY)
    text:SetShadowColor(unpack(style.shadowColor))
    text:SetVertexColor(unpack(style.color))
    styles[text] = nil
end

local function StyleName(frame)
    local text = frame.name
    if not styles[text] then
        local font, size, flags = text:GetFont()
        local shadowX, shadowY = text:GetShadowOffset()
        styles[text] = {
            unit = frame.unit,
            font = font, size = size, flags = flags,
            shadowX = shadowX, shadowY = shadowY,
            shadowColor = { text:GetShadowColor() },
            color = { text:GetTextColor() },
        }
    end
    text:SetFont(UNIT_NAME_FONT or "Fonts\\ARIALN.TTF", NAME_SIZE, "")
    text:SetShadowOffset(1, -1)
    text:SetShadowColor(0, 0, 0, 1)
    -- Extended selection colours distinguish friendly/PvP players, rather
    -- than using the nameplate's class colour or default white text.
    text:SetVertexColor(UnitSelectionColor(frame.unit, true))
end

local function Enabled()
    return HSN.db and HSN.db.settings.enabled
end

local function UpdateName(frame)
    if not frame or not frame.name then return end
    if not Enabled() or not frame.unit then RestoreStyle(frame.name); return end
    -- CompactUnitFrame_UpdateName is shared with party/raid frames. Only accept
    -- the actual frame owned by a world nameplate, including recycled plates.
    local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit(frame.unit)
    if not plate or plate.UnitFrame ~= frame then return end
    if not UnitIsPlayer(frame.unit) or UnitIsUnit(frame.unit, "player") then
        RestoreStyle(frame.name)
        return
    end
    local name = UnitName(frame.unit)
    if issecretvalue and issecretvalue(name) then return end
    if type(name) == "string" and name ~= "" then
        frame.name:SetText(name)
        StyleName(frame)
    end
end

local function RefreshNames()
    if not C_NamePlate or not C_NamePlate.GetNamePlates then return end
    for _, plate in ipairs(C_NamePlate.GetNamePlates()) do
        if plate.UnitFrame and CompactUnitFrame_UpdateName then
            CompactUnitFrame_UpdateName(plate.UnitFrame)
        end
    end
end

local hooked = false
function HSN:ApplyMainNames()
    if not self.db then return end
    if not hooked and type(CompactUnitFrame_UpdateName) == "function" then
        hooksecurefunc("CompactUnitFrame_UpdateName", UpdateName)
        hooked = true
    end
    if InCombatLockdown and InCombatLockdown() then return end
    local settings = self.db.settings
    if Enabled() then
        settings.worldNameCVars = settings.worldNameCVars or {}
        for key, value in pairs(cvars) do
            local current = C_CVar and C_CVar.GetCVar(key)
            if current ~= nil then
                if settings.worldNameCVars[key] == nil then
                    settings.worldNameCVars[key] = current
                end
                -- Never shorten a longer distance chosen by the user.
                if key == "nameplatePlayerMaxDistance" then
                    value = tostring(math.max(tonumber(current) or 0, tonumber(value)))
                end
                C_CVar.SetCVar(key, value)
            end
        end
    elseif settings.worldNameCVars then
        for text in pairs(styles) do RestoreStyle(text) end
        for key, value in pairs(settings.worldNameCVars) do
            if cvars[key] and C_CVar and C_CVar.GetCVar(key) ~= nil then
                C_CVar.SetCVar(key, value)
            end
        end
        settings.worldNameCVars = nil
    end
    RefreshNames()
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("NAME_PLATE_UNIT_ADDED")
events:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
events:RegisterEvent("ADDON_LOADED")
events:SetScript("OnEvent", function(_, event, unit)
    if event == "NAME_PLATE_UNIT_REMOVED" then
        -- A removed plate can immediately be reused for an NPC. Restore before
        -- that happens, even when it is absent from GetNamePlates().
        for text, style in pairs(styles) do
            if style.unit == unit then RestoreStyle(text) end
        end
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        if not Enabled() then return end
        local plate = C_NamePlate and C_NamePlate.GetNamePlateForUnit(unit)
        if plate then UpdateName(plate.UnitFrame) end
    else
        HSN:ApplyMainNames()
    end
end)
