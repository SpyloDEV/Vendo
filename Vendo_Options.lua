-- Vendo Options Panel

local addonName = ...
local panel = CreateFrame("Frame", "VendoOptionsPanel", InterfaceOptionsFramePanelContainer)
panel.name = "Vendo"

-- Title
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Vendo")

-- Subtitle
local subtitle = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
subtitle:SetText("Lightweight vendor automation")

-- Helper to create checkboxes
local function CreateCheckbox(text, tooltip, key, yOffset)
  local cb = CreateFrame("CheckButton", nil, panel, "InterfaceOptionsCheckButtonTemplate")
  cb:SetPoint("TOPLEFT", 16, yOffset)
  cb.Text:SetText(text)
  cb.tooltipText = tooltip

  cb:SetScript("OnShow", function(self)
    self:SetChecked(VendoDB[key])
  end)

  cb:SetScript("OnClick", function(self)
    VendoDB[key] = self:GetChecked()
  end)

  return cb
end

-- Checkboxes
CreateCheckbox(
  "Enable Vendo",
  "Master switch for the addon",
  "enabled",
  -60
)

CreateCheckbox(
  "Automatic Repairs",
  "Automatically repair your gear when visiting a vendor",
  "autoRepair",
  -90
)

CreateCheckbox(
  "Sell Gray Items",
  "Automatically sell poor-quality (gray) items",
  "autoSellGray",
  -120
)

CreateCheckbox(
  "Chat Messages",
  "Show chat messages for repairs and sales",
  "chat",
  -150
)

-- Footer
local footer = panel:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
footer:SetPoint("BOTTOMLEFT", 16, 16)
footer:SetText("Vendo © 2025")

InterfaceOptions_AddCategory(panel)
