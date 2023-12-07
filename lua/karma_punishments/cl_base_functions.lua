-- 
-- Client-side karma punishment functions
-- 
local thresholdCvar = GetConVar("ttt_kp_low_karma_threshold")

net.Receive("TTTKPApply", function()
    -- Reading data from server
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:IsPlayer() then return end
    local punishmentID = net.ReadString()
    local PUNISHMENT = TTTKP.punishments[punishmentID]
    -- Apply punishment function on the client
    PUNISHMENT:Apply(ply)
    table.insert(TTTKP.activePunishments, PUNISHMENT)
    -- Punishment alert and description
    chat.AddText(COLOR_YELLOW, "===Karma below " .. thresholdCvar:GetInt() .. "!===")

    if PUNISHMENT.desc then
        chat.AddText(COLOR_YELLOW, PUNISHMENT.desc)
    end

    -- Punishment flag
    ply.KPPunishment = PUNISHMENT
end)