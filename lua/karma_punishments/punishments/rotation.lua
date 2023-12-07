local PUNISHMENT = {}
PUNISHMENT.id = "rotation"
PUNISHMENT.name = "Random Rotation"
PUNISHMENT.desc = "You seem to be a bit jittery!"
PUNISHMENT.extDesc = "Rotates your view randomly every few seconds"

PUNISHMENT.convars = {
    {
        name = "kp_rotation_seconds",
        type = "int"
    }
}

local secsCvar = CreateConVar("kp_rotation_seconds", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Seconds between being randomly rotated", 1, 30)

function PUNISHMENT:Apply(ply)
    local timername = "TTTKPRotation" .. ply:SteamID64()

    timer.Create(timername, secsCvar:GetInt(), 0, function()
        if not self:IsPunishedPlayer(ply) then
            timer.Remove(timername)

            return
        end

        ply:SetEyeAngles(ply:EyeAngles() + Angle(0, math.random(75, 480), 0))
    end)
end

TTTKP:Register(PUNISHMENT)