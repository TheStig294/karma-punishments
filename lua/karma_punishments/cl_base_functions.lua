-- 
-- Client-side karma punishment functions
-- 
local thresholdCvar = GetConVar("ttt_kp_low_karma_threshold")

net.Receive("TTTKPApply", function()
    -- Reading data from server
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local punishmentID = net.ReadString()
    local noPercent = net.ReadBool()
    local PUNISHMENT = TTTKP.punishments[punishmentID]
    -- Apply punishment function on the client
    PUNISHMENT:Apply(ply)
    table.insert(TTTKP.activePunishments, PUNISHMENT)
    -- Punishment alert and description
    local karmaValue = ""

    -- In Custom Roles for TTT, karma is displayed as a percentage, so we need to convert the karma
    -- threshold for punishments into a percentage
    if ConVarExists("ttt_show_raw_karma_value") and not GetConVar("ttt_show_raw_karma_value"):GetBool() then
        karmaValue = math.Round(thresholdCvar:GetInt() / GetGlobalInt("ttt_karma_max", 1000) * 100) .. "%"
    else
        karmaValue = thresholdCvar:GetInt()
    end

    local msg

    if noPercent then
        msg = "===Karma punishment!==="
    else
        msg = "===Karma below " .. karmaValue .. ". Karma punishment!==="
    end

    chat.AddText(COLOR_YELLOW, msg)

    if PUNISHMENT.desc then
        chat.AddText(COLOR_YELLOW, PUNISHMENT.desc)
    end

    -- Punishment flag
    PUNISHMENT.active = true
    ply.KPPunishment = PUNISHMENT
end)