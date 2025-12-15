local ADDON_NAME = ...
local frame = CreateFrame("Frame")

-- Saved variables (defaults)
VendoDB = VendoDB or {
  enabled = true,
  autoRepair = true,
  autoSellGray = true,
  chat = true,
}

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

-- Sell gray items
local function SellGrayItems()
  local total = 0

  for bag = 0, 4 do
    local slots = C_Container.GetContainerNumSlots(bag)
    for slot = 1, slots do
      local item = C_Container.GetContainerItemInfo(bag, slot)
      if item and item.quality == 0 and item.hyperlink then
        local price = (select(11, GetItemInfo(item.hyperlink)) or 0) * item.stackCount
        if price > 0 then
          C_Container.UseContainerItem(bag, slot)
          total = total + price
        end
      end
    end
  end

  return total
end

-- Auto repair
local function RepairItems()
  if not CanMerchantRepair() then return 0, false end

  local cost = GetRepairAllCost()
  if not cost or cost <= 0 then return 0, false end

  local useGuild = CanGuildBankRepair and CanGuildBankRepair()
  RepairAllItems(useGuild)

  return cost, useGuild
end

-- Merchant interaction
frame:RegisterEvent("MERCHANT_SHOW")
frame:SetScript("OnEvent", function()
  if not VendoDB.enabled then return end

  local sold = 0
  local repaired = 0
  local guild = false

  if VendoDB.autoSellGray then
    sold = SellGrayItems()
  end

  if VendoDB.autoRepair then
    repaired, guild = RepairItems()
  end

  if sold > 0 then
    Print("Sold gray items for +" .. FormatMoney(sold))
  end

  if repaired > 0 then
    Print("Repaired gear for -" .. FormatMoney(repaired) .. (guild and " (guild)" or ""))
  end
end)

-- Slash commands
SLASH_VENDO1 = "/kt"
SlashCmdList["VENDO"] = function(msg)
  msg = (msg or ""):lower()

  if msg == "on" then
    VendoDB.enabled = true
    Print("enabled")
  elseif msg == "off" then
    VendoDB.enabled = false
    Print("disabled")
  elseif msg == "repair" then
    VendoDB.autoRepair = not VendoDB.autoRepair
    Print("Auto repair: " .. (VendoDB.autoRepair and "ON" or "OFF"))
  elseif msg == "sell" then
    VendoDB.autoSellGray = not VendoDB.autoSellGray
    Print("Auto sell gray items: " .. (VendoDB.autoSellGray and "ON" or "OFF"))
  elseif msg == "chat" then
    VendoDB.chat = not VendoDB.chat
    Print("Chat messages: " .. (VendoDB.chat and "ON" or "OFF"))
  else
    Print("Commands: /kt on | off | repair | sell | chat")
  end
end
