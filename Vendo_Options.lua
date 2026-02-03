local addonName = ...
local panel = CreateFrame("Frame", "VendoOptionsPanel", UIParent)
panel.name = "Vendo"

-- Title
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("|cff6cf5c2Vendo|r - Erweiterte Options")

-- Subtitle
local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText("Konfiguriere dein Vendor-Erlebnis | Version 0.3.0")

-- Kategorie-Headers erstellen
local function CreateHeader(text, yOffset)
  local header = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  header:SetPoint("TOPLEFT", 16, yOffset)
  header:SetText(text)
  return header
end

-- Checkbox Helper (erweitert mit Farbe)
local function CreateCheckbox(text, tooltip, key, yOffset)
  local cb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", 20, yOffset)
  cb.Text:SetText(text)
  cb.Text:SetTextColor(1, 0.8, 0.1)  -- Gelb für bessere Sicht
  cb.tooltipText = tooltip

  cb:SetScript("OnShow", function(self)
    self:SetChecked(Vendo.DB[key])
  end)

  cb:SetScript("OnClick", function(self)
    Vendo.DB[key] = self:GetChecked()
    if key == "minimapButton" then
      if self:GetChecked() then Vendo:CreateMinimapButton() else -- Hide button end
    end
  end)

  return cb, yOffset - 30
end

-- Slider für Threshold (neu)
local function CreateSlider(text, tooltip, key, min, max, step, yOffset)
  local slider = CreateFrame("Slider", nil, panel, "OptionsSliderTemplate")
  slider:SetPoint("TOPLEFT", 20, yOffset)
  slider:SetWidth(200)
  slider:SetHeight(20)
  slider:SetMinMaxValues(min, max)
  slider:SetValueStep(step)
  slider:SetObeyStepOnDrag(true)
  slider.tooltipText = tooltip
  slider.Text = slider:CreateFontString(nil, "ARTWORK", "GameFontWhite")
  slider.Text:SetPoint("TOP", 0, 15)
  slider.Text:SetText(text)
  slider.Low:SetText(FormatMoney(min))
  slider.High:SetText(FormatMoney(max))

  slider:SetScript("OnShow", function(self)
    self:SetValue(Vendo.DB[key])
    slider.Text:SetText(text .. ": " .. FormatMoney(Vendo.DB[key]))
  end)

  slider:SetScript("OnValueChanged", function(self, value)
    Vendo.DB[key] = value
    slider.Text:SetText(text .. ": " .. FormatMoney(value))
  end)

  return slider, yOffset - 50
end

-- Button Helper (z.B. für Reset)
local function CreateButton(text, func, yOffset)
  local btn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  btn:SetPoint("TOPLEFT", 20, yOffset)
  btn:SetSize(120, 25)
  btn:SetText(text)
  btn:SetScript("OnClick", func)
  return btn, yOffset - 30
end

-- Core Settings
CreateHeader("Core Features", -60)
local y = -90
CreateCheckbox("Enable Vendo", "Master switch", "enabled", y); y = y - 30
CreateCheckbox("Automatic Repairs", "Repair gear automatically", "autoRepair", y); y = y - 30
CreateCheckbox("Sell Gray/Junk Items", "Sell poor items auto", "autoSellGray", y); y = y - 30
CreateSlider("Junk Sell Threshold", "Sell items below this price (0 = only gray)", "autoSellJunkThreshold", 0, 100000, 100, y); y = y - 50

-- Notifications
CreateHeader("Notifications", y - 20); y = y - 40
CreateCheckbox("Chat Messages", "Show chat info", "chat", y); y = y - 30
CreateCheckbox("Sound on Repair", "Play sound on repair", "soundRepair", y); y = y - 30
CreateCheckbox("Sound on Sell", "Play sound on sell", "soundSell", y); y = y - 30

-- UI & Stats
CreateHeader("UI & Stats", y - 20); y = y - 40
CreateCheckbox("Minimap Button", "Show minimap icon for quick access", "minimapButton", y); y = y - 30
CreateButton("Show Stats", function() Vendo:PrintStats() end, y); y = y - 30
CreateButton("Reset Lifetime", function() Vendo:ResetStats("lifetime") end, y); y = y - 30

-- Footer
local footer = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
footer:SetPoint("BOTTOMLEFT", 16, 16)
footer:SetText("Vendo © 2026 | Feedback on GitHub")

InterfaceOptions_AddCategory(panel)
