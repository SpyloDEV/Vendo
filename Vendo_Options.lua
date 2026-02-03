local panel = CreateFrame("Frame", "VendoOptions", UIParent)
panel.name = "Vendo"
panel.parent = "Vendo"
panel:Hide()

-- Wait for DB
panel:SetScript("OnShow", function(self)
  if not Vendo or not Vendo.DB then
    self:Hide()
    return
  end
  local db = Vendo.DB

  -- Checkboxes
  local function Cb(key, text, y)
    local cb = CreateFrame("CheckButton", nil, self, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 20, y)
    cb.Text:SetText(text)
    cb:SetChecked(db[key])
    cb:SetScript("OnClick", function() db[key] = cb:GetChecked() end)
    return -35
  end

  if not self.created then
    self.title = self:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    self.title:SetPoint("TOPLEFT", 16, -16)
    self.title:SetText("Vendo 0.2.1")

    local y = -50
    y = Cb("enabled", "Enable Vendo", y)
    y = Cb("autoRepair", "Auto Repair", y)
    y = Cb("autoSellGray", "Auto Sell Gray", y)
    y = Cb("chat", "Chat Messages", y)

    self.created = true
  end
end)

InterfaceOptions_AddCategory(panel)
