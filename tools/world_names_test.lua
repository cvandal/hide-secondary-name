-- Focused regression test for the experimental nameplate workaround.
local HSN = { db = { settings = { enabled = false } } }
unpack = unpack or table.unpack
UNIT_NAME_FONT = "Fonts\\ARIALN.TTF"
local values = {
    nameplateShowFriendlyPlayers = "0",
    nameplateShowOnlyNameForFriendlyPlayerUnits = "0",
    UnitSurnameOwn = "1",
    nameplatePlayerMaxDistance = "60",
}
local combat, onEvent, hook
C_CVar = {
    GetCVar = function(key) return values[key] end,
    SetCVar = function(key, value) assert(not combat); values[key] = value end,
}
InCombatLockdown = function() return combat end
CreateFrame = function() return {
    RegisterEvent = function() end,
    SetScript = function(_, _, fn) onEvent = fn end,
} end
hooksecurefunc = function(_, fn) hook = fn end
local function Frame(unit)
    local text = { font = "Original", size = 12, flags = "OUTLINE", color = { 1, 1, 1, 1 },
        shadow = { 0, 0 }, shadowColor = { 0, 0, 0, 0 } }
    function text:SetText(value) self.text = value end
    function text:GetFont() return self.font, self.size, self.flags end
    function text:SetFont(font, size, flags) self.font, self.size, self.flags = font, size, flags end
    function text:GetShadowOffset() return unpack(self.shadow) end
    function text:SetShadowOffset(x, y) self.shadow = { x, y } end
    function text:GetShadowColor() return unpack(self.shadowColor) end
    function text:SetShadowColor(...) self.shadowColor = { ... } end
    function text:GetTextColor() return unpack(self.color) end
    function text:SetVertexColor(...) self.color = { ... } end
    return { unit = unit, name = text }
end
local frames = {
    friend = Frame("friend"), enemy = Frame("enemy"),
    npc = Frame("npc"), player = Frame("player"),
}
local plates = {}
for unit, frame in pairs(frames) do plates[unit] = { UnitFrame = frame } end
C_NamePlate = {
    GetNamePlateForUnit = function(unit)
        assert(not unit:match("^party") and not unit:match("^raid"),
            "Raid<n>/Party<n> unit tokens are not allowed for this call")
        return plates[unit]
    end,
    GetNamePlates = function()
        local result = {}
        for _, plate in pairs(plates) do result[#result + 1] = plate end
        return result
    end,
}
UnitIsPlayer = function(unit) return unit ~= "npc" end
UnitIsUnit = function(a, b) return a == b end
UnitSelectionColor = function(unit, extended)
    assert(extended)
    if unit == "enemy" then return 1, 0, 0 end
    return 0, 0, 1
end
UnitName = function(unit) return unit, "Surname" end
local secret = false
issecretvalue = function() return secret end
CompactUnitFrame_UpdateName = function(frame)
    frame.name:SetText(frame.unit .. " Surname")
    if hook then hook(frame) end
end
local function Load()
    assert(loadfile("src/WorldNames.lua"))("HSN", HSN)
    HSN:ApplyMainNames()
end
Load()
assert(values.nameplateShowFriendlyPlayers == "0", "off by default")
HSN.db.settings.enabled = true
HSN:ApplyMainNames()
assert(values.nameplateShowFriendlyPlayers == "1")
assert(values.nameplateShowOnlyNameForFriendlyPlayerUnits == "1")
assert(values.nameplatePlayerMaxDistance == "100", "player plate range increases")
assert(frames.friend.name.text == "friend" and frames.enemy.name.text == "enemy")
assert(frames.friend.name.font == UNIT_NAME_FONT and frames.friend.name.size == 14)
assert(frames.friend.name.flags == "" and frames.friend.name.color[3] == 1)
assert(frames.enemy.name.color[1] == 1 and frames.enemy.name.color[3] == 0)
assert(frames.npc.name.text == "npc Surname" and frames.player.name.text == "player Surname")
assert(frames.npc.name.font == "Original" and frames.player.name.font == "Original")
for _, unit in ipairs({ "party1", "party4", "raid1", "raid40", "partypet1", "raidpet40" }) do
    local group = Frame(unit)
    CompactUnitFrame_UpdateName(group)
    assert(group.name.text == unit .. " Surname", "group names stay untouched")
    assert(group.name.font == "Original", "group styling stays untouched")
end
local party = Frame("friend")
CompactUnitFrame_UpdateName(party)
assert(party.name.text == "friend Surname", "shared party/raid unit token stays untouched")
assert(party.name.font == "Original", "party frame styling stays untouched")
secret = true
CompactUnitFrame_UpdateName(frames.enemy)
assert(frames.enemy.name.text == "enemy Surname", "secret names are not inspected")
secret = false
onEvent(nil, "NAME_PLATE_UNIT_ADDED", "enemy")
assert(frames.enemy.name.text == "enemy", "new or recycled plates update")
onEvent(nil, "NAME_PLATE_UNIT_REMOVED", "enemy")
assert(frames.enemy.name.font == "Original", "removed plates restore their style before reuse")
onEvent(nil, "NAME_PLATE_UNIT_ADDED", "enemy")
-- Reload resets game frames, as the actual client does.
for _, unit in ipairs({ "friend", "enemy" }) do
    onEvent(nil, "NAME_PLATE_UNIT_REMOVED", unit)
end
Load()
assert(HSN.db.settings.worldNameCVars.nameplateShowFriendlyPlayers == "0", "reload preserves baseline")
combat = true
HSN.db.settings.enabled = false
HSN:ApplyMainNames()
assert(values.nameplateShowFriendlyPlayers == "1", "combat defers CVar restoration")
combat = false
onEvent(nil, "PLAYER_REGEN_ENABLED")
assert(values.nameplateShowFriendlyPlayers == "0" and values.nameplateShowOnlyNameForFriendlyPlayerUnits == "0")
assert(values.nameplatePlayerMaxDistance == "60", "range restores across reload")
assert(HSN.db.settings.worldNameCVars == nil)
assert(frames.friend.name.text == "friend Surname", "disabling restores displayed names")
assert(frames.friend.name.font == "Original" and frames.friend.name.size == 12)
values.nameplatePlayerMaxDistance = "120"
HSN.db.settings.enabled = true
HSN:ApplyMainNames()
assert(values.nameplatePlayerMaxDistance == "120", "longer existing range is retained")
HSN.db.settings.enabled = false
HSN:ApplyMainNames()
assert(values.nameplatePlayerMaxDistance == "120")
assert(values.UnitSurnameOwn == "1", "own surname setting remains untouched")
print("World names tests passed")
