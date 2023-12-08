local PUNISHMENT = {}
PUNISHMENT.id = "huge"
PUNISHMENT.name = "H.U.G.E. Problem"
PUNISHMENT.desc = "You've got a H.U.G.E. problem!"
PUNISHMENT.extDesc = "Forces you to use only a H.U.G.E."

PUNISHMENT.convars = {
    {
        name = "kp_huge_seconds",
        type = "int"
    }
}

local secsCvar = CreateConVar("kp_huge_seconds", 10, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Seconds between being given a H.U.G.E.", 1, 30)

function PUNISHMENT:Apply(ply)
    if CLIENT then return end
    ply:StripWeapons()
    ply:Give("weapon_zm_sledge").AllowDrop = false
    local timername = "TTTKPHuge" .. ply:SteamID64()

    timer.Create(timername, secsCvar:GetInt(), 0, function()
        if not self:IsPunishedPlayer(ply) then
            timer.Remove(timername)

            return
        end

        ply:StripWeapons()
        ply:Give("weapon_zm_sledge").AllowDrop = false
    end)

    self:AddHook("PlayerCanPickupWeapon", function(p, weapon)
        if self:IsPunishedPlayer(p) and IsValid(weapon) and WEPS.GetClass(weapon) ~= "weapon_zm_sledge" then return false end
    end)
end

TTTKP:Register(PUNISHMENT)