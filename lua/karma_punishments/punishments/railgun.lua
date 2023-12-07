local PUNISHMENT = {}
PUNISHMENT.id = "railgun"
PUNISHMENT.name = "Forced Railgun"
PUNISHMENT.desc = "Uh-oh... Forced railgun!"
PUNISHMENT.extDesc = "Forces the you to use a railgun (Different punishment for jesters!)"

PUNISHMENT.convars = {
    {
        name = "kp_railgun_seconds",
        type = "int"
    }
}

local secsCvar = CreateConVar("kp_railgun_seconds", 3, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Seconds between being given a railgun", 1, 30)

function PUNISHMENT:Apply(ply)
    local timername = "TTTKPRailgun" .. ply:SteamID64()

    timer.Create(timername, secsCvar:GetInt(), 0, function()
        if not self:IsPunishedPlayer(ply) then
            timer.Remove(timername)

            return
        end

        ply:StripWeapons()
        local SWEP = ply:Give("weapon_rp_railgun")
        SWEP.AllowDrop = false
    end)

    self:AddHook("PlayerCanPickupWeapon", function(p, weapon)
        if self:IsPunishedPlayer(p) and IsValid(weapon) and WEPS.GetClass(weapon) ~= "weapon_rp_railgun" then return false end
    end)
end

-- Check the railgun is installed and the player is not a jester
function PUNISHMENT:Condition(ply)
    return weapons.Get("weapon_rp_railgun") ~= nil and not self:IsJester(ply)
end

TTTKP:Register(PUNISHMENT)