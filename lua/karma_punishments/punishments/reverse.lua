-- Credit goes to Malivil for this punishment from the "Opposite day" randomat
-- (I'm using Mal's version because my ancient code is awful, and only having reversed movement wasn't much of a punishment)
local PUNISHMENT = {}
PUNISHMENT.id = "reverse"
PUNISHMENT.name = "Reverse Controls"
PUNISHMENT.desc = "Your controls have been reversed! (Press 'R' to shoot!)"
PUNISHMENT.extDesc = "Reverses many controls like moving backwards,\nshooting <-> reloading or crouching <-> jumping"

function PUNISHMENT:Apply(ply)
    ply:SetLadderClimbSpeed(-200)

    if CLIENT then
        self:AddHook("StartCommand", function(p, cmd)
            if not self:IsPunishedPlayer(p) then return end
            -- Make the player move the opposite direction
            cmd:SetForwardMove(-cmd:GetForwardMove())
            cmd:SetSideMove(-cmd:GetSideMove())

            -- Attack reloads, reload attacks
            if cmd:KeyDown(IN_ATTACK) then
                cmd:RemoveKey(IN_ATTACK)
                cmd:SetButtons(cmd:GetButtons() + IN_RELOAD)
            elseif cmd:KeyDown(IN_RELOAD) then
                cmd:RemoveKey(IN_RELOAD)
                cmd:SetButtons(cmd:GetButtons() + IN_ATTACK)
            elseif cmd:KeyDown(IN_JUMP) then
                -- Reverse jump and duck too
                cmd:RemoveKey(IN_JUMP)
                cmd:SetButtons(cmd:GetButtons() + IN_DUCK)
            elseif cmd:KeyDown(IN_DUCK) then
                cmd:RemoveKey(IN_DUCK)
                cmd:SetButtons(cmd:GetButtons() + IN_JUMP)
            end
        end)
    end

    -- Override the sprint key so living players can sprint forward while holding the back key
    self:AddHook("TTTSprintKey", function(p)
        if self:IsPunishedPlayer(p) then return IN_BACK end
    end)
end

function PUNISHMENT:Reset(ply)
    ply:SetLadderClimbSpeed(200)
end

TTTKP:Register(PUNISHMENT)