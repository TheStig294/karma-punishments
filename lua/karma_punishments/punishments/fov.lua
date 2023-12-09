-- Credit goes to Abi for this punishment from the "Quake Pro" randomat
local PUNISHMENT = {}
PUNISHMENT.id = "fov"
PUNISHMENT.name = "Zoomed-in FOV"
PUNISHMENT.desc = "You're stuck zoomed-in!"
PUNISHMENT.extDesc = "Sets your FOV lower"

PUNISHMENT.convars = {
    {
        name = "kp_fov_scale",
        type = "float",
        decimals = 1
    },
    {
        name = "kp_fov_scale_ironsight",
        type = "float",
        decimals = 1
    }
}

local scaleCvar = CreateConVar("kp_fov_scale", 0.5, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "FOV multiplier", 0.1, 0.9)

local ironsightScaleCvar = CreateConVar("kp_fov_scale_ironsight", 0.3, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Ironsights FOV multiplier", 0.1, 0.9)

local function PlayerInIronsights(ply)
    if not ply.GetActiveWeapon then return false end
    local wep = ply:GetActiveWeapon()

    return IsValid(wep) and wep.GetIronsights and wep:GetIronsights()
end

function PUNISHMENT:Apply(ply)
    if SERVER then
        local scale = scaleCvar:GetFloat()
        local scaleIronsight = ironsightScaleCvar:GetFloat()
        local originalFOV

        if PlayerInIronsights(ply) then
            v:GetActiveWeapon():SetIronsights(false)
            v:SetFOV(0, 0)
        end

        local timername = "TTTKPFovTimer" .. ply:SteamID64()

        timer.Create(timername, 0.1, 0, function()
            if self:IsPunishedPlayer(ply) then
                local fovScale

                if PlayerInIronsights(ply) then
                    fovScale = scaleIronsight
                else
                    fovScale = scale
                end

                -- Save the player's scaled FOV the first time we see them
                if not originalFOV then
                    originalFOV = ply:GetFOV()
                end

                ply:SetFOV(originalFOV * fovScale, 0)
            else
                ply:SetFOV(0, 0)
                timer.Remove(timername)
            end
        end)
    end

    if CLIENT then
        if not ply.GetActiveWeapon then return end
        local wep = ply:GetActiveWeapon()
        if not IsValid(wep) or not wep.GetIronsights or not wep:GetIronsights() then return end
        wep:SetIronsights(false)
        ply:SetFOV(0, 0)
    end
end

TTTKP:Register(PUNISHMENT)