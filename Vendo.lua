local ADDON_NAME = ...
local frame = CreateFrame("Frame")

-- Globals
VendoDBPC = VendoDBPC or {}
local Vendo = { DB = {} }

-- Utils
local function FormatMoney(copper)
  if not copper or copper <= 0 then return "0c" end
  local g = math.floor(copper / 10000)
  local s = math.floor((copper % 10000) / 100)
  local c = copper % 100
  return (g > 0 and g.."g " or "") .. (s > 0 and s.."s " or "") .. c.."c":gsub("%s+$", "")
end

local function Print(msg)
  if Vendo.DB.chat then
    DEFAULT_CHAT_FRAME:AddMessage("|cff6cf5c2Vendo|r: " .. msg)
  end
end

-- Init & Migration
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
  if addon ~= ADDON_NAME then return end

  local charKey = UnitName("player") .. "-" .. GetRealmName()
  VendoDBPC[charKey] = VendoDBPC[charKey] or {}

  -- Migrate old global DB if exists
  if VendoDB then
    for k, v in pairs(VendoDB) do
      if type(v) == "table" then
        VendoDBPC[charKey][k] = VendoDBPC[charKey][k] or {}
        for kk, vv in pairs(v) do VendoDBPC[charKey][k][kk] = vv end
      else
        VendoDBPC[charKey][k] = v
      end
    end
    VendoDB = nil  -- Clear old
    Print("Migrated settings to per-char.")
  end

  Vendo.DB = VendoDBPC[charKey]

  -- Defaults (safe)
  Vendo.DB.enabled = Vendo.DB.enabled ~= false
  Vendo.DB.autoRepair = Vendo.DB.autoRepair ~= false
  Vendo.DB.autoSellGray = Vendo.DB.autoSellGray ~= false
  Vendo.DB.chat = Vendo.DB.chat ~= false

  -- Load Stats
  if Vendo.InitStats then Vendo:InitStats() end

  self:UnregisterEvent("ADDON_LOADED")
end)

-- Sell Grays
local function SellGrays()
  local total = 0
  for bag = 0, 4 do
    for slot = 1, C_Container.GetContainerNumSlots(bag) do
      local info = C_Container.GetContainerItemInfo(bag, slot)
      if info and info.quality == 0 and info.stackCount > 0 then
        local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(info.hyperlink)
        if sellPrice then
          C_Container.UseContainerItem(bag, slot)
          total = total + (sellPrice * info.stackCount)
        end
      end
    end
  end
  return total
end

-- Repair
local function DoRepair()
  if not CanMerchantRepair() then return 0 end
  local cost = GetRepairAllCost()
  if cost > 0 then
    local useGuild = CanGuildBankRepair and CanGuildBankRepair()
    RepairAllItems(useGuild)
    return cost, useGuild
  end
  return 0
end

-- Merchant Event
frame:RegisterEvent("MERCHANT_SHOW")
frame:SetScript("OnEvent", function(self, event)
  if event ~= "MERCHANT_SHOW" or not Vendo.DB.enabled then return end

  local sold = Vendo.DB.autoSellGray and SellGrays() or 0
  if sold > 0 then
    if Vendo.AddSold then Vendo:AddSold(sold) end
    Print("Sold grays: +" .. FormatMoney(sold))
  end

  local repaired, guild = Vendo.DB.autoRepair and DoRepair() or 0
  if repaired > 0 then
    if Vendo.AddRepair then Vendo:AddRepair(repaired) end
    Print("Repaired: -" .. FormatMoney(repaired) .. (guild and " (guild)" or ""))
  end
end)

-- Slash
SLASH_VENDO1 = "/kt"
SlashCmdList["VENDO"] = function(msg)
  msg = (msg or ""):lower()
  if msg == "on" then Vendo.DB.enabled = true; Print("Enabled") end
  if msg == "off" then Vendo.DB.enabled = false; Print("Disabled") end
  if msg == "repair" then Vendo.DB.autoRepair = not Vendo.DB.autoRepair; Print("Repair: " .. (Vendo.DB.autoRepair and "ON" or "OFF")) end
  if msg == "sell" then Vendo.DB.autoSellGray = not Vendo.DB.autoSellGray; Print("Sell: " .. (Vendo.DB.autoSellGray and "ON" or "OFF")) end
  if msg == "chat" then Vendo.DB.chat = not Vendo.DB.chat; Print("Chat: " .. (Vendo.DB.chat and "ON" or "OFF")) end
  if msg == "stats" and Vendo.PrintStats then Vendo:PrintStats() end
  Print(" /kt on|off|repair|sell|chat|stats")
end
