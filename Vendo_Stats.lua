Vendo = Vendo or {}

local function GetToday()
  return date("%Y-%m-%d")
end

local function GetWeek()
  return date("%Y-%W")
end

function Vendo:InitStats()
  Vendo.DB.stats = Vendo.DB.stats or {
    session = { sold = 0, repaired = 0 },
    today = { sold = 0, repaired = 0, date = GetToday() },
    weekly = { sold = 0, repaired = 0, week = GetWeek() },
    lifetime = { sold = 0, repaired = 0 },
  }

  local s = Vendo.DB.stats
  if s.today.date ~= GetToday() then
    s.today = { sold = 0, repaired = 0, date = GetToday() }
  end
  if s.weekly.week ~= GetWeek() then
    s.weekly = { sold = 0, repaired = 0, week = GetWeek() }
  end
end

function Vendo:AddSold(amount)
  if not amount or amount <= 0 then return end
  local s = Vendo.DB.stats
  s.session.sold = s.session.sold + amount
  s.today.sold = s.today.sold + amount
  s.weekly.sold = s.weekly.sold + amount
  s.lifetime.sold = s.lifetime.sold + amount
end

function Vendo:AddRepair(amount)
  if not amount or amount <= 0 then return end
  local s = Vendo.DB.stats
  s.session.repaired = s.session.repaired + amount
  s.today.repaired = s.today.repaired + amount
  s.weekly.repaired = s.weekly.repaired + amount
  s.lifetime.repaired = s.lifetime.repaired + amount
end

function Vendo:ResetStats(type)
  local s = Vendo.DB.stats
  if type == "session" then
    s.session = { sold = 0, repaired = 0 }
  elseif type == "today" then
    s.today = { sold = 0, repaired = 0, date = GetToday() }
  elseif type == "weekly" then
    s.weekly = { sold = 0, repaired = 0, week = GetWeek() }
  elseif type == "lifetime" then
    s.lifetime = { sold = 0, repaired = 0 }
  end
  Print("Reset " .. type .. " stats.")
end

function Vendo:PrintStats()
  local s = Vendo.DB.stats
  print("|cffffd200Vendo Stats|r")
  print("Session: Sold " .. GetCoinTextureString(s.session.sold) .. " | Repairs " .. GetCoinTextureString(s.session.repaired) .. " | Net " .. GetCoinTextureString(s.session.sold - s.session.repaired))
  print("Today: Sold " .. GetCoinTextureString(s.today.sold) .. " | Repairs " .. GetCoinTextureString(s.today.repaired) .. " | Net " .. GetCoinTextureString(s.today.sold - s.today.repaired))
  print("Weekly: Sold " .. GetCoinTextureString(s.weekly.sold) .. " | Repairs " .. GetCoinTextureString(s.weekly.repaired) .. " | Net " .. GetCoinTextureString(s.weekly.sold - s.weekly.repaired))
  print("Lifetime: Sold " .. GetCoinTextureString(s.lifetime.sold) .. " | Repairs " .. GetCoinTextureString(s.lifetime.repaired) .. " | Net " .. GetCoinTextureString(s.lifetime.sold - s.lifetime.repaired))
end

function Vendo:PrintLog()
  print("|cffffd200Vendo Log (letzte 10)|r")
  for i, entry in ipairs(Vendo.DB.log) do
    print(i .. ": " .. date("%H:%M", entry.time) .. " - Sold +" .. FormatMoney(entry.sold) .. " | Repaired -" .. FormatMoney(entry.repaired))
  end
end

-- Tooltip (erweitert, zeigt jetzt auch Weekly/Lifetime mit Modifiers)
local function AddTooltipStats(tooltip)
  local s = Vendo.DB.stats
  tooltip:AddLine(" ")
  tooltip:AddLine("|cffffd200Vendo Stats|r")

  if IsShiftKeyDown() then
    tooltip:AddLine("Today: Net " .. GetCoinTextureString(s.today.sold - s.today.repaired))
  end
  if IsAltKeyDown() then
    tooltip:AddLine("Weekly: Net " .. GetCoinTextureString(s.weekly.sold - s.weekly.repaired))
  end
  if IsControlKeyDown() then
    tooltip:AddLine("Lifetime: Net " .. GetCoinTextureString(s.lifetime.sold - s.lifetime.repaired))
  end
end

GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
  if not MerchantFrame or not MerchantFrame:IsShown() then return end
  if IsShiftKeyDown() or IsAltKeyDown() or IsControlKeyDown() then
    AddTooltipStats(tooltip)
    tooltip:Show()
  end
end)
