local PUNISHMENT = {}
PUNISHMENT.id = "health"
PUNISHMENT.name = "Less Health"
PUNISHMENT.desc = "You're not looking too healthy!"
PUNISHMENT.extDesc = "Sets your health lower (Different punishment for jesters!)"

PUNISHMENT.convars = {
    {
        name = "kp_health_amount",
        type = "int"
    }
}

local healthCvar = CreateConVar("kp_health_amount", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Amount of health you are set to", 1, 99)

function PUNISHMENT:Apply(ply)
  
    ply:SetHealth(healthCvar:GetInt())
    if CLIENT then return end
    ply:SetMaxHealth(healthCvar:GetInt())
end

-- Obviously this is an advantage if you're a jester...
function PUNISHMENT:Condition(ply)
    return not self:IsJester(ply)
end

TTTKP:Register(PUNISHMENT)