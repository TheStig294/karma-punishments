-- Credit goes to Malivil for this punishment from the "Wasteful!" randomat
local PUNISHMENT = {}
PUNISHMENT.id = "ammo"
PUNISHMENT.name = "Less Ammo"
PUNISHMENT.desc = "You're a bit wasteful with ammo!"
PUNISHMENT.extDesc = "Guns use more ammo per shot"

PUNISHMENT.convars = {
    {
        name = "kp_ammo_wasted_bullets",
        type = "int"
    }
}

local extraShotCvar = CreateConVar("kp_ammo_wasted_bullets", 2, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "No. of extra bullets wasted", 1, 5)

function PUNISHMENT:Apply(ply)
    self:AddHook("EntityFireBullets", function(p, data)
        if not self:IsPunishedPlayer(p) then return end
        local wep = p:GetActiveWeapon()
        if not IsValid(wep) or not wep.Primary or wep.Primary.ClipSize <= 0 then return end
        local ammo = wep:Clip1()
        if ammo <= 0 then return end
        wep:SetClip1(math.max(0, ammo - extraShotCvar:GetInt()))
    end)
end

TTTKP:Register(PUNISHMENT)