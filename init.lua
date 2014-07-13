-- Nuke mod by ShadowNinja
-- Based on the nuke mod by sfan5

nuke = {}
nuke.cid_names = {}

minetest.register_privilege("pyrotechnic", {
	description = "Can detonate nukes",
})

local modpath = minetest.get_modpath("nuke") .. DIR_DELIM

dofile(modpath .. "config.lua")
dofile(modpath .. "entity.lua")
dofile(modpath .. "api.lua")
dofile(modpath .. "internal.lua")
dofile(modpath .. "definitions.lua")
dofile(modpath .. "missiles.lua")

