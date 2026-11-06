-- Focused world-name regression checks, followed by standalone addon loading.
dofile("tools/world_names_test.lua")

local frames = {}
local function Object()
    local object = { Text = { SetText = function() end } }
    function object:RegisterEvent() end
    function object:UnregisterEvent() end
    function object:SetScript(event, callback) self[event] = callback end
    function object:CreateFontString() return Object() end
    function object:SetPoint() end
    function object:SetText() end
    function object:SetJustifyH() end
    function object:SetChecked(value) self.checked = value end
    function object:GetChecked() return self.checked end
    return object
end
CreateFrame = function()
    local frame = Object()
    frames[#frames + 1] = frame
    return frame
end
local category = { GetID = function() return 42 end }
local opened
Settings = {
    RegisterCanvasLayoutCategory = function() return category end,
    RegisterAddOnCategory = function(value) assert(value == category) end,
    OpenToCategory = function(id) opened = id end,
}
DEFAULT_CHAT_FRAME = { AddMessage = function() end }
SlashCmdList = {}
strtrim = function(value) return value:match("^%s*(.-)%s*$") end
local addon = {}
for line in io.lines("src/HideSecondaryName.toc") do
    if line:match("%.lua$") then assert(loadfile("src/" .. line))("HideSecondaryName", addon) end
end
frames[1].OnEvent(nil, "ADDON_LOADED", "HideSecondaryName")
assert(addon.db.settings.enabled, "standalone addon starts enabled")
assert(addon.db.settings.worldNameCVars == nil, "fresh settings have no prior CVar baseline")
frames[1].OnEvent(nil, "PLAYER_LOGIN")
assert(addon.category == category)
SlashCmdList.HIDESECONDARYNAME("")
assert(opened == 42)
SlashCmdList.HIDESECONDARYNAME("off")
assert(not addon.db.settings.enabled)
SlashCmdList.HIDESECONDARYNAME("on")
assert(addon.db.settings.enabled)
SlashCmdList.HIDESECONDARYNAME("toggle")
assert(not addon.db.settings.enabled)
print("Standalone addon smoke test passed")
