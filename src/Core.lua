local ADDON_NAME, HSN = ...
HSN.version = "0.1.0"

function HSN:Print(message)
    DEFAULT_CHAT_FRAME:AddMessage("|cffd4a017Hide Secondary Name:|r " .. message)
end

function HSN:SetEnabled(enabled)
    self.db.settings.enabled = enabled
    self:ApplyMainNames()
    if self.RefreshSettings then self:RefreshSettings() end
end

local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(_, event, name)
    if event == "ADDON_LOADED" then
        if name ~= ADDON_NAME then return end
        HideSecondaryNameCharDB = HideSecondaryNameCharDB or {}
        local db = HideSecondaryNameCharDB
        db.settings = db.settings or {}
        if db.settings.enabled == nil then db.settings.enabled = true end
        HSN.db = db
        events:UnregisterEvent("ADDON_LOADED")
    elseif event == "PLAYER_LOGIN" then
        HSN:ApplyMainNames()
        HSN:CreateSettings()
    end
end)

SLASH_HIDESECONDARYNAME1 = "/hsn"
SLASH_HIDESECONDARYNAME2 = "/hidesecondaryname"
SlashCmdList.HIDESECONDARYNAME = function(input)
    local command = strtrim(input or ""):lower()
    if command == "on" or command == "off" or command == "toggle" then
        local enabled = command == "on" or (command == "toggle" and not HSN.db.settings.enabled)
        HSN:SetEnabled(enabled)
        HSN:Print(enabled and "Enabled." or "Disabled; previous settings restored after combat.")
    elseif command == "" or command == "settings" then
        if HSN.category then Settings.OpenToCategory(HSN.category:GetID()) end
    else
        HSN:Print("/hsn — settings; /hsn on, off, or toggle — change the display.")
    end
end
