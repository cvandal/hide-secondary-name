local _, HSN = ...

function HSN:CreateSettings()
    if self.category then return end
    local panel = CreateFrame("Frame")
    local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Hide Secondary Name")

    local checkbox = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -16)
    checkbox.Text:SetText("Hide secondary names on world player nameplates")
    checkbox:SetScript("OnClick", function(button) HSN:SetEnabled(button:GetChecked()) end)
    function self:RefreshSettings()
        checkbox:SetChecked(self.db.settings.enabled)
    end
    panel:SetScript("OnShow", function() HSN:RefreshSettings() end)

    local description = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    description:SetPoint("TOPLEFT", checkbox, "BOTTOMLEFT", 4, -12)
    description:SetPoint("RIGHT", panel, "RIGHT", -24, 0)
    description:SetJustifyH("LEFT")
    description:SetText("Uses names-only friendly player nameplates with the overhead-name font and reaction colours. Party frames, raid frames, chat, NPCs and your own name are unchanged.\n\nRequests at least 100 yards of player nameplate range. The client may cap this: distant players can still show their full names. Friendly plate customization may be restricted in instances. Text size approximates ordinary overhead names.\n\nTurning this off restores the previous nameplate settings. Changes requested during combat wait until combat ends. Turn it off before disabling or uninstalling the addon to restore those settings.")

    self.category = Settings.RegisterCanvasLayoutCategory(panel, "Hide Secondary Name")
    Settings.RegisterAddOnCategory(self.category)
    self:RefreshSettings()
end
