-- 
-- Server-side karma punishment functions 
-- 
-- Debug command for testing punishments, only works on a peer-to-peer server for the server host if sv_cheats is on
concommand.Add("kp_apply", function(ply, _, _, argsStr)
    if argsStr ~= "" then
        local PUNISHMENT = TTTKP.punishments[argStr]
        TTTKP:ApplyPunishment(ply, PUNISHMENT)
    else
        TTTKP:SelectPunishment(ply)
    end
end, nil, "Applies a karma punishment to yourself, if no argument is given, selects a random one", FCVAR_CHEAT)

-- Finds a punishment for the player that can be applied, and applies it with TTTKP:ApplyPunishment()
function TTTKP:SelectPunishment(ply, skipCanPunishCheck)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    -- Choose a random punishment from available ones to give to the player
    local PUNISHMENT

    -- Check for an punishment that has its condition met, and has its convar enabled
    for id, pun in RandomPairs(TTTKP.punishments) do
        if not pun:Condition(ply) then continue end
        if not GetConVar("ttt_kp_" .. pun.id):GetBool() then continue end
        PUNISHMENT = pun
        break
    end

    -- If all punishments are turned off or conditions not met then do nothing
    if not PUNISHMENT then
        ply:ChatPrint("You should have received a karma punishment, but none are enabled with its condition met...")

        return
    end

    hook.Run("TTTKPSelected", ply, PUNISHMENT)
    TTTKP:ApplyPunishment(ply, PUNISHMENT)
end

-- Applies all punishment effects
util.AddNetworkString("TTTKPApply")

function TTTKP:ApplyPunishment(ply, PUNISHMENT)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    -- Punishment function (Where all the magic happens...)
    PUNISHMENT:Apply(ply)
    table.insert(TTTKP.activePunishments, PUNISHMENT)
    -- Add punishment table to the player object for easy reference
    -- Used for detecting if a player is punished
    PUNISHMENT.active = true
    ply.KPPunishment = PUNISHMENT
    -- Client-side changes
    net.Start("TTTKPApply")
    net.WriteString(PUNISHMENT.id)
    net.Send(ply)
end

-- Getting the low karma amount convar and ttt_karma convar
local thresholdCvar = GetConVar("ttt_kp_low_karma_threshold")
local karmaCvar

hook.Add("PostGamemodeLoaded", "TTTKPGetKarmaConvar", function()
    karmaCvar = GetConVar("ttt_karma")
end)

-- Applies a random punishment to every living player below the low karma threshold
hook.Add("TTTBeginRound", "TTTKPApplyPunishments", function()
    -- Do not apply punishments if karma is turned off
    if not karmaCvar:GetBool() then return end

    timer.Simple(0.1, function()
        for _, ply in ipairs(player.GetAll()) do
            if ply:GetLiveKarma() < thresholdCvar:GetInt() and ply:Alive() and not ply:IsSpec() then
                TTTKP:SelectPunishment(ply)
            end
        end
    end)
end)