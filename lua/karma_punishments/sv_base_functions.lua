-- 
-- Server-side karma punishment functions 
-- 
-- Debug command for testing punishments, only works on a peer-to-peer server for the server host if sv_cheats is on
concommand.Add("kp_apply", function(ply, _, args, argsStr)
    if argsStr ~= "" then
        local PUNISHMENT = TTTKP.punishments[args[1]]
        TTTKP:ApplyPunishment(ply, PUNISHMENT)
    else
        TTTKP:SelectPunishment(ply)
    end
end, nil, "Applies a karma punishment to yourself, if no argument is given, selects a random one", FCVAR_CHEAT)

function TTTKP:IsValidPunishment(PUNISHMENT, victim)
    -- Check punisment argument was passed at all
    if not PUNISHMENT then return false end

    -- Accept string ids for punishments as well
    if isstring(PUNISHMENT) then
        PUNISHMENT = TTTKP.punishments[PUNISHMENT]
    end

    -- Check punishment is a valid table
    if not PUNISHMENT or not istable(PUNISHMENT) or not PUNISHMENT.id then return false end
    -- Check punishment actually exists
    PUNISHMENT = TTTKP.punishments[PUNISHMENT.id]
    -- Check punishment is enabled
    if not PUNISHMENT or not ConVarExists("ttt_kp_" .. PUNISHMENT.id) or not GetConVar("ttt_kp_" .. PUNISHMENT.id):GetBool() then return false end
    -- If a victim player is being checked as well, check the punishment's condition function is met
    if victim then return IsValid(victim) and victim:IsPlayer() and victim:Alive() and not victim:IsSpec() and PUNISHMENT:Condition(victim) end

    return true
end

-- NOTE: Can return nil if all punishments are disabled! (Or conditions aren't met)
function TTTKP:GetValidPunishment(ply)
    for id, PUNISHMENT in RandomPairs(TTTKP.punishments) do
        if TTTKP:IsValidPunishment(PUNISHMENT, ply) then return PUNISHMENT end
    end
end

-- Finds a punishment for the player that can be applied, and applies it with TTTKP:ApplyPunishment()
-- Returns true if no punishment was actually applied
function TTTKP:SelectPunishment(ply, karmaPercentMessage)
    if not IsValid(ply) or not ply:IsPlayer() then return end
    -- Choose a random punishment from available ones to give to the player
    local PUNISHMENT = TTTKP:GetValidPunishment(ply)

    -- If all punishments are turned off or conditions not met then do nothing
    if not PUNISHMENT then
        ply:ChatPrint("You should have received a karma punishment, but none are enabled with its condition met...")

        return true
    end

    hook.Run("TTTKPSelected", ply, PUNISHMENT)
    TTTKP:ApplyPunishment(ply, PUNISHMENT, karmaPercentMessage)
end

-- Applies all punishment effects
util.AddNetworkString("TTTKPApply")

function TTTKP:ApplyPunishment(ply, PUNISHMENT, karmaPercentMessage)
    if not IsValid(ply) or not ply:IsPlayer() then return end

    -- Accept string ids for punishments as well
    if isstring(PUNISHMENT) then
        PUNISHMENT = TTTKP.punishments[PUNISHMENT]
    end

    if not TTTKP:IsValidPunishment(PUNISHMENT, ply) then return end
    -- Punishment function (Where all the magic happens...)
    PUNISHMENT:Apply(ply)
    table.insert(TTTKP.activePunishments, PUNISHMENT)
    -- Add punishment table to the player object for easy reference
    -- Used for detecting if a player is punished
    PUNISHMENT.active = true
    ply.KPPunishment = PUNISHMENT

    -- Stops the "Karma below 80%" part of the alert chat message from appearing
    -- Used when manually applying punishments to players
    if not karmaPercentMessage then
        karmaPercentMessage = false
    end

    -- Client-side changes
    net.Start("TTTKPApply")
    net.WriteString(PUNISHMENT.id)
    net.WriteBool(karmaPercentMessage)
    net.Send(ply)
end

-- Getting the low karma amount convar and ttt_karma convar
local thresholdCvar = GetConVar("ttt_kp_low_karma_threshold")
local karmaCvar = GetConVar("ttt_karma")

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
                TTTKP:SelectPunishment(ply, true)
            end
        end
    end)
end)

-- Chat / command that applies a random karma punishment on the specified player
hook.Add("PlayerSay", "TTTKPManualPunishment", function(sender, text, teamChat)
    if not sender:IsAdmin() or not string.StartsWith(text, "/punish ") then return end
    local playerName = string.lower(string.sub(text, 9))
    local playerToPunish

    for _, ply in ipairs(player.GetAll()) do
        if string.lower(ply:Nick()) == playerName then
            playerToPunish = ply
            break
        end
    end

    if IsValid(playerToPunish) then
        local noValidPunishment = TTTKP:SelectPunishment(playerToPunish)

        if noValidPunishment then
            sender:ChatPrint(playerToPunish:Nick() .. " should have received a karma punishment, but none are enabled with its condition met...")
        else
            sender:ChatPrint(playerToPunish:Nick() .. " was punished!")
        end
    else
        sender:ChatPrint("Player not found")
    end

    return ""
end)