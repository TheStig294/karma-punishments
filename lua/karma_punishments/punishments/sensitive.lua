local PUNISHMENT = {}
PUNISHMENT.id = "sensitive"
PUNISHMENT.name = "Random Sensitivity"
PUNISHMENT.desc = "You seem to be a bit sensitive..."
PUNISHMENT.extDesc = "Randomly changes your mouse sensitivity every few seconds"

PUNISHMENT.convars = {
    {
        name = "kp_sensitive_seconds",
        type = "int"
    }
}

local secsCvar = CreateConVar("kp_sensitive_seconds", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Seconds between sensitivity changes", 1, 30)

function PUNISHMENT:Apply(ply)
    if SERVER then return end
    local sensitiveMult = 1

    timer.Create("TTTKPSensitive", secsCvar:GetInt(), 0, function()
        if not self:IsPunishedPlayer(ply) then
            sensitiveMult = 1
            timer.Remove("TTTKPSensitive")

            return
        end

        sensitiveMult = math.Rand(0.1, 10)
    end)

    self:AddHook("AdjustMouseSensitivity", function(defaultSensitivity)
        if not self:IsPunishedPlayer(ply) then return end

        return sensitiveMult
    end)
end

TTTKP:Register(PUNISHMENT)