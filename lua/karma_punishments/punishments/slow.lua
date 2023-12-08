local PUNISHMENT = {}
PUNISHMENT.id = "slow"
PUNISHMENT.name = "Slow Movement"
PUNISHMENT.desc = "You're feeling a bit slow"
PUNISHMENT.extDesc = "You move more slowly"

PUNISHMENT.convars = {
    {
        name = "kp_slow_mult",
        type = "float",
        decimals = 1
    }
}

local multCvar = CreateConVar("kp_slow_mult", 0.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Speed multiplier", 0.1, 0.9)

function PUNISHMENT:Apply(ply)
    if SERVER then
        ply:SetLaggedMovementValue(multCvar:GetFloat())
    end
end

function PUNISHMENT:Reset(ply)
    if SERVER then
        ply:SetLaggedMovementValue(1)
    end
end

TTTKP:Register(PUNISHMENT)