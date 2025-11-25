local PUNISHMENT = {}
PUNISHMENT.id = "thirdperson"
PUNISHMENT.name = "Third-person"
PUNISHMENT.desc = "You're stuck in third-person!"
PUNISHMENT.extDesc = "You are forced to use a third-person view"

function PUNISHMENT:Apply(ply)
    if SERVER then return end

    self:AddHook("CalcView", function(p, pos, angles, fov, znear, zfar)
        if not self:IsPunishedPlayer(p) or not p:Alive() or p:IsSpec() then return end

        local view = {
            origin = util.TraceLine({
                start = pos,
                endPos = pos - angles:Forward() * 100
            }).HitPos,
            angles = angles,
            fov = fov,
            drawviewer = true,
            znear = znear,
            zfar = zfar
        }

        return view
    end)
end

TTTKP:Register(PUNISHMENT)