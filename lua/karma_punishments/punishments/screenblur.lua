local PUNISHMENT = {}
PUNISHMENT.id = "screenblur"
PUNISHMENT.name = "Screen Blur"
PUNISHMENT.desc = "Whoa... Dude..."
PUNISHMENT.extDesc = "Applies a heavy screen blur"

function PUNISHMENT:Apply(ply)
    -- Apply a screen blur screenspace effect on the client
    if SERVER then return end

    local modifiedColours = {
        ["$pp_colour_addr"] = 0.02,
        ["$pp_colour_addg"] = 0.02,
        ["$pp_colour_addb"] = 0,
        ["$pp_colour_brightness"] = 0,
        ["$pp_colour_contrast"] = 1,
        ["$pp_colour_colour"] = 3,
        ["$pp_colour_mulr"] = 0,
        ["$pp_colour_mulg"] = 0.02,
        ["$pp_colour_mulb"] = 0
    }

    self:AddHook("RenderScreenspaceEffects", function()
        if not self:IsPunishedPlayer(ply) then
            -- Since we're on the client only we can safely remove the hook without affecting other
            -- players with the same punishment
            self:RemoveHook("RenderScreenspaceEffects")

            return
        end

        DrawMotionBlur(0.4, 0.8, 0.05)
        DrawToyTown(2, ScrH() / 2)
        DrawSharpen(1.2, 1.2)
        DrawColorModify(modifiedColours)
    end)
end

TTTKP:Register(PUNISHMENT)