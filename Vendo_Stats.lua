Vendo = Vendo or {}
local Vendo = Vendo

local function GetToday()
    return date("%Y-%m-%d")
end

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

function Vendo:AddSold(amount)
    VendoDB.stats.session.sold = VendoDB.stats.session.sold + amount
    VendoDB.stats.today.sold = VendoDB.stats.today.sold + amount
end

function Vendo:AddRepair(amount)
    VendoDB.stats.session.repaired = VendoDB.stats.session.repaired + amount
    VendoDB.stats.today.repaired = VendoDB.stats.today.repaired + amount
end

function Vendo:PrintStats()
    local s = VendoDB.stats.session
    local t = VendoDB.stats.today

    print("Vendo Stats")
    print("Session:")
    print("• Sold:", GetCoinTextureString(s.sold))
    print("• Repairs:", GetCoinTextureString(-s.repaired))
    print("• Net:", GetCoinTextureString(s.sold - s.repaired))

    print("Today:")
    print("• Sold:", GetCoinTextureString(t.sold))
    print("• Repairs:", GetCoinTextureString(-t.repaired))
    print("• Net:", GetCoinTextureString(t.sold - t.repaired))
end
local function ShouldShowTooltipStats()
    if not IsShiftKeyDown() then return false end
    if not MerchantFrame or not MerchantFrame:IsShown() then return false end

    local t = VendoDB.stats and VendoDB.stats.today
    if not t then return false end

    return (t.sold > 0 or t.repaired > 0)
end

local function AddTooltipStats(tooltip)
    local t = VendoDB.stats.today
    if not t then return end

    tooltip:AddLine(" ")
    tooltip:AddLine("|cffffd200Vendo Stats (Today)|r")
    tooltip:AddLine("Sold: " .. GetCoinTextureString(t.sold), 0, 1, 0)
    tooltip:AddLine("Repairs: " .. GetCoinTextureString(-t.repaired), 1, 0.4, 0.4)
    tooltip:AddLine("Net: " .. GetCoinTextureString(t.sold - t.repaired), 0.4, 1, 0.4)
end

GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
    if ShouldShowTooltipStats() then
        AddTooltipStats(tooltip)
        tooltip:Show()
    end
end)
