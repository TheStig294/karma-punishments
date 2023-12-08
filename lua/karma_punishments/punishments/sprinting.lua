local PUNISHMENT = {}
PUNISHMENT.id = "sprinting"
PUNISHMENT.name = "No Sprinting"
PUNISHMENT.desc = "Your legs feel a bit tired..."
PUNISHMENT.extDesc = "Your sprinting is disabled"

function PUNISHMENT:Apply(ply)
    self:AddHook("TTTSprintStaminaPost", function(p)
        if self:IsPunishedPlayer(p) then return 0 end
    end)

    if CLIENT then
        self:AddHook("PlayerBindPress", function(p, bind)
            if self:IsPunishedPlayer(p) and string.find(bind, "+speed") then
                p:PrintMessage(HUD_PRINTCENTER, "Sprinting is disabled")

                return true
            end
        end)

        -- These hooks will be automatically be re-added by the installed sprint mod
        timer.Simple(0.1, function()
            hook.Remove("Think", "TTTSprintThink")
            hook.Remove("Think", "TTTSprint4Think")
        end)
    end
end

-- Check sprinting is a thing, and if it can be disabled, is is not
function PUNISHMENT:Condition(ply)
    return ConVarExists("ttt_sprint_bonus_rel") and (not ConVarExists("ttt_sprint_enabled") or GetConVar("ttt_sprint_enabled"):GetBool())
end

TTTKP:Register(PUNISHMENT)