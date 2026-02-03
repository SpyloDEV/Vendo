local ADDON_NAME = ...
local frame = CreateFrame("Frame")
local Vendo = {}  -- Namespace für Modularität

-- Utility: money formatting
local function FormatMoney(copper)
  if not copper or copper <= 0 then return "0c" end
  local gold = math.floor(copper / 10000)
  local silver = math.floor((copper % 10000) / 100)
  local copperRest = copper % 100

  local parts = {}
  if gold > 0 then table.insert(parts, gold .. "g") end
  if silver > 0 then table.insert(parts, silver .. "s") end
  if copperRest > 0 or #parts == 0 then
    table.insert(parts, copperRest .. "c")
  end
  return table.concat(parts, " ")
end

-- Chat output
local function Print(msg)
  if VendoDB.chat then
    DEFAULT_CHAT_FRAME:AddMessage("|cff6cf5c2Vendo|r: " .. msg)
  end
end

-- Per-Char Migration und Init
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
  if addon ~= ADDON_NAME then return end

  local charKey = UnitName("player") .. "-" .. GetRealmName()
  VendoDBPC = VendoDBPC or {}
  VendoDBPC[charKey] = VendoDBPC[charKey] or {}

  -- Migrate alte globale DB, falls vorhanden
  if VendoDB then
    for k, v in pairs(VendoDB) do
      VendoDBPC[charKey][k] = v
    end
    VendoDB = nil  -- Alte löschen
  end

  Vendo.DB = VendoDBPC[charKey]  -- Aktuelle DB referenzieren

  -- Defaults
  Vendo.DB.enabled = Vendo.DB.enabled ~= false  -- true default
  Vendo.DB.autoRepair = Vendo.DB.autoRepair ~= false
  Vendo.DB.autoSellGray = Vendo.DB.autoSellGray ~= false
  Vendo.DB.chat = Vendo.DB.chat ~= false
  Vendo.DB.soundRepair = Vendo.DB.soundRepair or false
  Vendo.DB.soundSell = Vendo.DB.soundSell or false
  Vendo.DB.autoSellJunkThreshold = Vendo.DB.autoSellJunkThreshold or 0  -- Copper threshold für extra Junk-Sell
  Vendo.DB.minimapButton = Vendo.DB.minimapButton or true
  Vendo.DB.log = Vendo.DB.log or {}  -- Log Array für letzte Interaktionen (max 10)

  -- Stats Init (aus Vendo_Stats.lua)
  Vendo:InitStats()

  -- Minimap Button (modular)
  if Vendo.DB.minimapButton then
    Vendo:CreateMinimapButton()
  end

  self:UnregisterEvent("ADDON_LOADED")
end)

-- Sell gray/junk items (erweitert)
local function SellItems()
  local total = 0
  local threshold = Vendo.DB.autoSellJunkThreshold

  for bag = 0, 4 do
    local slots = C_Container.GetContainerNumSlots(bag)
    for slot = 1, slots do
      local item = C_Container.GetContainerItemInfo(bag, slot)
      if item and item.hyperlink then
        local quality = item.quality
        local price = (select(11, GetItemInfo(item.hyperlink)) or 0) * item.stackCount
        if (quality == 0 or (quality < 2 and price <= threshold)) and price > 0 then
          C_Container.UseContainerItem(bag, slot)
          total = total + price
        end
      end
    end
  end

  return total
end

-- Auto repair (unverändert, aber mit Sound)
local function RepairItems()
  if not CanMerchantRepair() then return 0, false end

  local cost = GetRepairAllCost()
  if not cost or cost <= 0 then return 0, false end

  local useGuild = CanGuildBankRepair and CanGuildBankRepair()
  RepairAllItems(useGuild)

  return cost, useGuild
end

-- Merchant interaction (erweitert mit Log und Sounds)
frame:RegisterEvent("MERCHANT_SHOW")
frame:SetScript("OnEvent", function(self, event)
  if event ~= "MERCHANT_SHOW" or not Vendo.DB.enabled then return end

  local sold = 0
  local repaired = 0
  local guild = false
  local logEntry = { time = time(), sold = 0, repaired = 0 }

  if Vendo.DB.autoSellGray then
    sold = SellItems()
    logEntry.sold = sold
    Vendo:AddSold(sold)
    if sold > 0 then
      Print("Sold items for +" .. FormatMoney(sold))
      if Vendo.DB.soundSell then PlaySound(120) end  -- AuctionWindowClose Sound
    end
  end

  if Vendo.DB.autoRepair then
    repaired, guild = RepairItems()
    logEntry.repaired = repaired
    Vendo:AddRepair(repaired)
    if repaired > 0 then
      Print("Repaired gear for -" .. FormatMoney(repaired) .. (guild and " (guild)" or ""))
      if Vendo.DB.soundRepair then PlaySound(119) end  -- AuctionWindowOpen Sound
    end
  end

  -- Log hinzufügen (max 10)
  table.insert(Vendo.DB.log, 1, logEntry)
  if #Vendo.DB.log > 10 then table.remove(Vendo.DB.log) end
end)

-- Slash commands (erweitert)
SLASH_VENDO1 = "/kt"
SlashCmdList["VENDO"] = function(msg)
  msg = (msg or ""):lower():trim()
  local args = {strsplit(" ", msg)}

  if msg == "on" then
    Vendo.DB.enabled = true
    Print("enabled")
  elseif msg == "off" then
    Vendo.DB.enabled = false
    Print("disabled")
  elseif args[1] == "repair" then
    Vendo.DB.autoRepair = not Vendo.DB.autoRepair
    Print("Auto repair: " .. (Vendo.DB.autoRepair and "ON" or "OFF"))
  elseif args[1] == "sell" then
    Vendo.DB.autoSellGray = not Vendo.DB.autoSellGray
    Print("Auto sell: " .. (Vendo.DB.autoSellGray and "ON" or "OFF"))
  elseif args[1] == "chat" then
    Vendo.DB.chat = not Vendo.DB.chat
    Print("Chat messages: " .. (Vendo.DB.chat and "ON" or "OFF"))
  elseif args[1] == "stats" then
    Vendo:PrintStats()
  elseif args[1] == "reset" and args[2] then
    Vendo:ResetStats(args[2])
  elseif args[1] == "log" then
    Vendo:PrintLog()
  else
    Print("Commands: /kt on | off | repair | sell | chat | stats | reset [session|today|weekly|lifetime] | log")
  end
end

-- Minimap Button (neu)
function Vendo:CreateMinimapButton()
  local button = CreateFrame("Button", "VendoMinimapButton", Minimap)
  button:SetSize(32, 32)
  button:SetFrameStrata("MEDIUM")
  button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 0, 0)  -- Anpassen
  button:SetNormalTexture("Interface\\AddOns\\Vendo\\icon")  -- Füge eine Icon-Texture hinzu, falls du eine hast
  button:SetScript("OnClick", function(self, btn)
    if btn == "LeftButton" then
      InterfaceOptionsFrame_OpenToCategory("Vendo")
    elseif btn == "RightButton" then
      Vendo:PrintStats()
    end
  end)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Vendo")
    GameTooltip:AddLine("Left: Options | Right: Stats")
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", GameTooltip_Hide)
end
