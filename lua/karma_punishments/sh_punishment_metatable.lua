-- 
-- Creating a fake "PUNISHMENT" class using metatables, borrowed from the randomat's "EVENT" class
-- 
local PUNISHMENT = {}
PUNISHMENT.__index = PUNISHMENT
-- Basic properties
PUNISHMENT.id = nil -- Unique ID name of the punishment, required.
PUNISHMENT.name = nil -- Displayed name of the punishment in chat
PUNISHMENT.desc = nil -- Displayed in chat, punishment description on receiving it
PUNISHMENT.extDesc = nil -- Extended description, displayed in the F1 settings menu
PUNISHMENT.convars = nil -- Table of convar info tables, format:

-- convars = {
--    {
--        name = ConVar name,
--        type = ConVar variable type (bool, int, float or string),
--        decimals = No. of decimals the convar value slider should have in the F1 tab
--    },
--    {
--        ...
--    },
--    ...
--}
-- If false, prevents the punishment from being applied. A different one is selected instead (if available)
function PUNISHMENT:Condition(ply)
    return true
end

-- The function responsible for applying the punishment, run when a player should be punished
function PUNISHMENT:Apply(ply)
end

-- Run on player death, or the next time TTTPrepareRound is called to reset any data or anything that needs cleaning up that the punishment affected
function PUNISHMENT:Reset(ply)
end

-- These functions are from Malivil's randomat mod, where hooks passed are automatically given an appropriate hook id and are removed the next time TTTPrepareRound is called
-- Punishment functions use self:AddHook(), self:RemoveHook() and self:AddCleanupHooks() are used in sh_base_functions.lua to clean up the hooks at the end of the round
function PUNISHMENT:AddHook(hooktype, callbackfunc, suffix)
    callbackfunc = callbackfunc or self[hooktype]
    local id = "TTTKP." .. self.id .. ":" .. hooktype

    if suffix and type(suffix) == "string" and #suffix > 0 then
        id = id .. ":" .. suffix
    end

    hook.Add(hooktype, id, function(...) return callbackfunc(...) end)
    self.Hooks = self.Hooks or {}

    table.insert(self.Hooks, {hooktype, id})
end

function PUNISHMENT:RemoveHook(hooktype, suffix)
    local id = "TTTKP." .. self.id .. ":" .. hooktype

    if suffix and type(suffix) == "string" and #suffix > 0 then
        id = id .. ":" .. suffix
    end

    for idx, ahook in ipairs(self.Hooks or {}) do
        if ahook[1] == hooktype and ahook[2] == id then
            hook.Remove(ahook[1], ahook[2])
            table.remove(self.Hooks, idx)

            return
        end
    end
end

function PUNISHMENT:CleanUpHooks()
    if not self.Hooks then return end

    for _, ahook in ipairs(self.Hooks) do
        hook.Remove(ahook[1], ahook[2])
    end

    table.Empty(self.Hooks)
end

-- Utility functions available inside any PUNISHMENT function, usually used in PUNISHMENT:Apply()
function PUNISHMENT:GetAlivePlayers(shuffle)
    local plys = {}

    for _, ply in ipairs(player.GetAll()) do
        if IsValid(ply) and ply:Alive() and not ply:IsSpec() then
            table.insert(plys, ply)
        end
    end

    if shuffle then
        table.Shuffle(plys)
    end

    return plys
end

local ForceSetPlayermodel = FindMetaTable("Entity").SetModel

function PUNISHMENT:SetModel(ply, model)
    ForceSetPlayermodel(ply, model)
end

function PUNISHMENT:IsPlayer(ply)
    return IsValid(ply) and ply:IsPlayer()
end

function PUNISHMENT:IsAlive(ply)
    return ply:Alive() and not ply:IsSpec()
end

function PUNISHMENT:IsAlivePlayer(ply)
    return self:IsPlayer(ply) and self:IsAlive(ply)
end

function PUNISHMENT:IsPunished(ply)
    return ply.KPPunishment and ply.KPPunishment.active and ply.KPPunishment.id == self.id
end

function PUNISHMENT:IsPunishedPlayer(ply)
    return self:IsAlivePlayer(ply) and self:IsPunished(ply)
end

function PUNISHMENT:IsJester(ply)
    return (ROLE_JESTER and ply:GetRole() == ROLE_JESTER) or (ROLE_SWAPPER and ply:GetRole() == ROLE_SWAPPER) or (ply.IsJesterTeam and ply:IsJesterTeam())
end

-- Making the metatable accessible to the base code by placing it in the TTTKP namespace
TTTKP.punishment_meta = PUNISHMENT