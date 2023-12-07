local PUNISHMENT = {}
PUNISHMENT.id = "backwards"
PUNISHMENT.name = "Backwards Movement"
PUNISHMENT.desc = "!pots t'now ,pots t'naC"
PUNISHMENT.extDesc = "Forces you to move backwards only, very quickly\nCan stop in place by holding the forwards key"

PUNISHMENT.convars = {
    {
        name = "kp_backwards_speed",
        type = "int"
    }
}

local speedCvar = CreateConVar("kp_backwards_speed", 440, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Backwards movement speed", 1, 800)

function PUNISHMENT:Apply(ply)
    if SERVER then
        ply.KPBackwardsOldWalkSpeed = ply:GetWalkSpeed()
        ply:ConCommand("+back")
        ply:SetWalkSpeed(speedCvar:GetInt())
        ply:SetRunSpeed(speedCvar:GetInt())
    end
end

function PUNISHMENT:Reset(ply)
    if SERVER then
        ply:ConCommand("-back")
        ply:SetWalkSpeed(ply.KPBackwardsOldWalkSpeed or 220)
        ply:SetRunSpeed(ply.KPBackwardsOldWalkSpeed or 220)
        ply.KPBackwardsOldWalkSpeed = nil
    end
end

TTTKP:Register(PUNISHMENT)