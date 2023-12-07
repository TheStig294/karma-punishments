-- This file loads all other Karma Punishments lua files in the right order
if engine.ActiveGamemode() ~= "terrortown" then return end

local function AddServer(fil)
    if SERVER then
        include(fil)
    end
end

local function AddClient(fil)
    if SERVER then
        AddCSLuaFile(fil)
    end

    if CLIENT then
        include(fil)
    end
end

-- Base functions
AddServer("karma_punishments/sh_base_functions.lua")
AddClient("karma_punishments/sh_base_functions.lua")
AddServer("karma_punishments/sv_base_functions.lua")
AddClient("karma_punishments/cl_base_functions.lua")
-- PUNISHMENT object
AddServer("karma_punishments/sh_punishment_metatable.lua")
AddClient("karma_punishments/sh_punishment_metatable.lua")
-- F1 menu tab
AddClient("karma_punishments/cl_f1_settings_tab.lua")
-- Karma Punishments
local files, _ = file.Find("karma_punishments/punishments/*.lua", "LUA")

for _, fil in ipairs(files) do
    AddServer("karma_punishments/punishments/" .. fil)
    AddClient("karma_punishments/punishments/" .. fil)
end