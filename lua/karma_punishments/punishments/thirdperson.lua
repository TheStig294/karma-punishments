local PUNISHMENT = {}
PUNISHMENT.id = "thirdperson"
PUNISHMENT.name = "Third-person"
PUNISHMENT.desc = "You're stuck in third-person!"
PUNISHMENT.extDesc = "You are forced to use a third-person view"

function PUNISHMENT:Apply(ply)
    if CLIENT then
        SetGlobalBool("RandomatThirdPerson", true)
        local thirdPersonCvar = GetConVar("thirdperson_etp")
        thirdPersonCvar:SetBool(true)

        self:AddHook("PlayerBindPress", function(p, bind)
            if string.find(bind, "thirdperson_enhanced_toggle") and self:IsPunishedPlayer(p) then
                p:PrintMessage(HUD_PRINTCENTER, "Third person toggle is disabled")

                return true
            end
        end)

        self:AddHook("Think", function()
            if not thirdPersonCvar:GetBool() and self:IsPunishedPlayer(ply) then
                thirdPersonCvar:SetBool(true)
            end
        end)
    end
end

function PUNISHMENT:Reset(ply)
    if CLIENT then
        SetGlobalBool("RandomatThirdPerson", false)
        RunConsoleCommand("thirdperson_etp", "0")
    end
end

-- Check third person mod is installed
function PUNISHMENT:Condition(ply)
    return istable(THIRDPERSON_ENHANCED)
end

TTTKP:Register(PUNISHMENT)