-------------------------------------------------
-- Vendo Stats Module
-------------------------------------------------

Vendo = Vendo or {}
local Vendo = Vendo

-------------------------------------------------
-- Helpers
-------------------------------------------------

local function GetToday()
    return date("%Y-%m-%d")
end

-------------------------------------------------
-- Init
-------------------------------------------------

function Vendo:InitStats()
    VendoDB.stats = VendoDB.stats or {
        session = { sold = 0, repaired = 0 },
        today = { sold = 0, repaired = 0, date = GetToday() }
    }

    if VendoDB.stats.today.date ~= GetToday() then
        VendoDB.stats.today.sold = 0
        VendoDB.stats.today.repaired = 0
        VendoDB.stats.today.date = GetToday()
    end
end

-------------------------------------------------
-- Tracking
-------------------------------------------------

function Vendo:AddSold(amount)
    if not amount or amount <= 0 then return end
    VendoDB.stats.session.sold = VendoDB.stats.session.sold + amount
    VendoDB.stats.today.sold = VendoDB.stats.today.sold + amount
end

function Vendo:AddRepair(amount)
    if not amount or amount <= 0 then return end
    VendoDB.stats.session.repaired = VendoDB.stats.session.repaired + amount
    VendoDB.stats.today.repaired = VendoDB.stats.today.repaired + amount
end

-------------------------------------------------
-- Chat Output
-------------------------------------------------

function Vendo:PrintStats()
    local s = VendoDB.stats.session
    local t = VendoDB.stats.today

    print("|cffffd200Vendo Stats|r")

    print("Session:")
    print(" • Sold:", GetCoinTextureString(s.sold))
    print(" • Repairs:", GetCoinTextureString(-s.repaired))
    print(" • Net:", GetCoinTextureString(s.sold - s.repaired))

    print("Today:")
    print(" • Sold:", GetCoinTextureString(t.sold))
    print(" • Repairs:", GetCoinTextureString(-t.repaired))
    print(" • Net:", GetCoinTextureString(t.sold - t.repaired))
end

-------------------------------------------------
-- Tooltip
-------------------------------------------------

local function GetActiveStats()
    if IsAltKeyDown() then
        return VendoDB.stats.session, "Session"
    end
    return VendoDB.stats.today, "Today"
end

local function ShouldShowTooltipStats()
    if not (IsShiftKeyDown() or IsAltKeyDown()) then return false end
    if not MerchantFrame or not MerchantFrame:IsShown() then return false end

    local stats = IsAltKeyDown() and VendoDB.stats.session or VendoDB.stats.today
    if not stats then return false end

    return (stats.sold > 0 or stats.repaired > 0)
end

local function AddTooltipStats(tooltip)
    local stats, label = GetActiveStats()
    if not stats then return end

    tooltip:AddLine(" ")
    tooltip:AddLine("|cffffd200Vendo Stats (" .. label .. ")|r")
    tooltip:AddLine("Sold: " .. GetCoinTextureString(stats.sold), 0, 1, 0)
    tooltip:AddLine("Repairs: " .. GetCoinTextureString(-stats.repaired), 1, 0.4, 0.4)
    tooltip:AddLine("Net: " .. GetCoinTextureString(stats.sold - stats.repaired), 0.4, 1, 0.4)
end

GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
    if not MerchantFrame or not MerchantFrame:IsShown() then return end
    if ShouldShowTooltipStats() then
        AddTooltipStats(tooltip)
        tooltip:Show()
    end
end)
