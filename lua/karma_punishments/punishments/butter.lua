local PUNISHMENT = {}
PUNISHMENT.id = "butter"
PUNISHMENT.name = "Butterfingers"
PUNISHMENT.desc = "Your fingers are practically butter!"
PUNISHMENT.extDesc = "Forces you to drop your weapon periodically"

PUNISHMENT.convars = {
    {
        name = "kp_butter_seconds",
        type = "int"
    }
}

local secsCvar = CreateConVar("kp_butter_seconds", 5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Seconds between dropping weapons", 1, 30)

function PUNISHMENT:Apply(ply)
    if CLIENT then return end

    for _, wep in ipairs(ply:GetWeapons()) do
        ply:DropWeapon(wep)
    end

    local timername = "TTTKPButter" .. ply:SteamID64()

    timer.Create(timername, secsCvar:GetInt(), 0, function()
        if not self:IsPunishedPlayer(ply) then
            timer.Remove(timername)

            return
        end

        if ply:GetActiveWeapon().AllowDrop then
            ply:DropWeapon()
            ply:EmitSound("vo/npc/Barney/ba_pain01.wav")
            -- Reset FOV if player was scoped-in
            ply:SetFOV(0, 0.2)
        end
    end)
end

TTTKP:Register(PUNISHMENT)