Vendo = Vendo or {}
local stats = { session = {sold=0, repaired=0}, today={sold=0,repaired=0} }

function Vendo:InitStats()
  self.DB.stats = self.DB.stats or stats
  local s = self.DB.stats
  if s.today.date ~= date("%Y-%m-%d") then s.today = {sold=0, repaired=0, date=date("%Y-%m-%d")} end
end

function Vendo:AddSold(amount) if amount>0 then local s=self.DB.stats; s.session.sold=s.session.sold+amount; s.today.sold=s.today.sold+amount end end
function Vendo:AddRepair(amount) if amount>0 then local s=self.DB.stats; s.session.repaired=s.session.repaired+amount; s.today.repaired=s.today.repaired+amount end end

function Vendo:PrintStats()
  local s = self.DB.stats
  print("|cff6cf5c2Vendo Stats|r")
  print("Session: +"..FormatMoney(s.session.sold).." | -"..FormatMoney(s.session.repaired).." | Net: "..FormatMoney(s.session.sold - s.session.repaired))
  print("Today:   +"..FormatMoney(s.today.sold).." | -"..FormatMoney(s.today.repaired).." | Net: "..FormatMoney(s.today.sold - s.today.repaired))
end

-- Smart Vendor Tooltip (safe)
if MerchantFrame then
  MerchantFrame:HookScript("OnShow", function()
    if IsShiftKeyDown() and Vendo.DB.stats then
      local s = Vendo.DB.stats
      GameTooltip:AddLine("Vendo Net Today: "..FormatMoney(s.today.sold - s.today.repaired), 1,1,0)
      GameTooltip:Show()
    end
  end)
end
