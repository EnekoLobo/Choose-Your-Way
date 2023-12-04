forceAlign = forceAlign or {}

local top = #forceAlign.tiers
local thicc = 2
local dense = 1

hook.Add("PreDrawHalos", "forceAlign_halos", function()
	if !forceAlign.halos then return end

	local team1 = {}
	local team2 = {}

	for _,ply in pairs(player.GetAll()) do
		if !IsValid(ply) or !ply:Alive() then continue end
		-- wOS support
		if ply:GetNW2Float("CloakTime", 0) >= CurTime() then continue end

		local tier = ply:GetNW2Int("forceAlign_tier")

		if tier == top then
			table.insert(team1, ply)
		end

		if tier == top * -1 then
			table.insert(team2, ply)
		end
	end

	if #team1 > 0 then
		halo.Add(team1, forceAlign.haloClrs[1], thicc, thicc, dense, true, false)
	end

	if #team2 > 0 then
		halo.Add(team2, forceAlign.haloClrs[2], thicc, thicc, dense, true, false)
	end
end)