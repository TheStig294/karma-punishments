-- 
-- TTTKP functions and core logic
-- 
-- The global table/namespace used by the client and server to access all punishment data
TTTKP = {}
TTTKP.punishments = {}
TTTKP.activePunishments = {}
TTTKP.punishment_meta = {} -- Set by sh_punishment_metatable.lua

-- Low karma threshold cvar, defines the amount of karma below which players start receiving punishments
CreateConVar("ttt_kp_low_karma_threshold", "800", {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED}, "The amount of karma below which players start receiving punishments", 0, 1000)

local KPConvars = {
    ttt_kp_low_karma_threshold = true
}

function TTTKP:Register(PUNISHMENT)
    -- Set metatable properties and functions, and register to TTTKP.punishments global table
    setmetatable(PUNISHMENT, TTTKP.punishment_meta)
    TTTKP.punishments[PUNISHMENT.id] = PUNISHMENT
    -- Create enable/disable convar
    local cvarName = "ttt_kp_" .. PUNISHMENT.id

    CreateConVar(cvarName, 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

    -- Add convar to the list of allowed to be changed convars by the "TTTKPChangeConvar" net message
    KPConvars[cvarName] = true

    -- Also add any custom convar settings the punishment may have
    if PUNISHMENT.convars then
        for _, cvarInfo in ipairs(PUNISHMENT.convars) do
            KPConvars[cvarInfo.name] = true
        end
    end
end

-- Allowing KP convars to be changed from the client, if the player is an admin
if SERVER then
    util.AddNetworkString("TTTKPChangeConvar")

    -- Manually define player:IsAdmin() for TTT2
    local function IsAdmin(ply)
        if not IsValid(ply) or not ply:IsPlayer() then return false end
        local userGroup = ply:GetNWString("UserGroup", "user")

        if userGroup == "superadmin" or userGroup == "admin" then
            return true
        else
            return false
        end
    end

    net.Receive("TTTKPChangeConvar", function(_, ply)
        if not IsAdmin(ply) then return end
        local cvarName = net.ReadString()
        -- Don't allow non-KP convars to be changed by this net message
        if not KPConvars[cvarName] then return end
        local value = net.ReadString()

        if ConVarExists(cvarName) then
            GetConVar(cvarName):SetString(value)
        end
    end)
end

-- Resetting all active punishment logic, at the end of each round
hook.Add("TTTEndRound", "TTTKPResetAll", function()
    if TTTKP.activePunishments ~= {} then
        -- Call reset function on all players with a punishment
        for _, ply in ipairs(player.GetAll()) do
            if ply.KPPunishment then
                -- Only reset if the player is actually punished
                if ply.KPPunishment.active then
                    ply.KPPunishment:Reset(ply)
                end

                ply.KPPunishment = nil
            end
        end

        for _, PUNISHMENT in pairs(TTTKP.activePunishments) do
            PUNISHMENT:CleanUpHooks()
        end

        TTTKP.activePunishments = {}
    end
end)

-- Calling punishment reset function on a punished player's death
hook.Add("PostPlayerDeath", "TTTKPResetDeath", function(ply)
    if ply.KPPunishment and ply.KPPunishment.active then
        ply.KPPunishment:Reset(ply)
        ply.KPPunishment.active = false
    end
end)

-- Re-applying punishment on player respawning
hook.Add("PlayerSpawn", "TTTKPPunishmentRespawn", function(ply)
    timer.Simple(0.1, function()
        if ply.KPPunishment and not ply.KPPunishment.active then
            ply.KPPunishment:Apply(ply)
            ply.KPPunishment.active = true
        end
    end)
end)