local PUNISHMENT = {}
PUNISHMENT.id = "health"
PUNISHMENT.name = "Less Health"
PUNISHMENT.desc = "You're not looking too healthy!"
PUNISHMENT.extDesc = "Sets your health lower"

PUNISHMENT.convars = {
    {
        name = "kp_health_amount",
        type = "int"
    }
}

local healthCvar = CreateConVar("kp_health_amount", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Amount of health you are set to", 1, 99)

function PUNISHMENT:Apply(ply)
    if CLIENT then return end
    ply:SetHealth(healthCvar:GetInt())
    ply:SetMaxHealth(healthCvar:GetInt())
end

-- Obviously this is an advantage if you're a jester...
function PUNISHMENT:Condition(ply)
    return not self:IsJester(ply)
end

TTTKP:Register(PUNISHMENT)