local PUNISHMENT = {}
PUNISHMENT.id = "fog"
PUNISHMENT.name = "Foggy Vision"
PUNISHMENT.desc = "You can't see too far away"
PUNISHMENT.extDesc = "Puts a fog effect on your screen,\nwhich limits how far you can see"

PUNISHMENT.convars = {
    {
        name = "kp_fog_mult",
        type = "float",
        decimals = 1
    }
}

local multCvar = CreateConVar("kp_fog_mult", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "Fog distance multiplier", 0.1, 5)

function PUNISHMENT:Apply(ply)
    if CLIENT then
        self:AddHook("SetupWorldFog", function()
            if not self:IsPunishedPlayer(ply) then return end
            render.FogMode(MATERIAL_FOG_LINEAR)
            render.FogColor(0, 0, 0)
            render.FogMaxDensity(1)
            render.FogStart(200 * multCvar:GetFloat())
            render.FogEnd(400 * multCvar:GetFloat())

            return true
        end)

        -- If a map has a 3D skybox, apply a fog effect to that too
        self:AddHook("SetupSkyboxFog", function(scale)
            if not self:IsPunishedPlayer(ply) then return end
            render.FogMode(MATERIAL_FOG_LINEAR)
            render.FogColor(0, 0, 0)
            render.FogMaxDensity(1)
            render.FogStart(200 * multCvar:GetFloat() * scale)
            render.FogEnd(400 * multCvar:GetFloat() * scale)

            return true
        end)
    end
end

TTTKP:Register(PUNISHMENT)