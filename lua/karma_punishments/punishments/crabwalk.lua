local PUNISHMENT = {}
PUNISHMENT.id = "crabwalk"
PUNISHMENT.name = "Crab Walk"
PUNISHMENT.desc = "You can only walk sideways!"
PUNISHMENT.extDesc = "Forward and backward movement is disabled,\nyou can only walk sideways"

function PUNISHMENT:Apply(ply)
    if SERVER then return end

    self:AddHook("StartCommand", function(p, CUserCmd)
        if self:IsPunishedPlayer(p) then
            CUserCmd:SetForwardMove(0)
        end
    end)
end

TTTKP:Register(PUNISHMENT)