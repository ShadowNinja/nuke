
-- Create some tables first so that they're only created once
local mesecon_def = {effector = {
	rules = {
		{x=0,  y=1,  z=-1},
		{x=0,  y=0,  z=-1},
		{x=0,  y=-1, z=-1},
		{x=0,  y=1,  z=1},
		{x=0,  y=-1, z=1},
		{x=0,  y=0,  z=1},
		{x=1,  y=0,  z=0},
		{x=1,  y=1,  z=0},
		{x=1,  y=-1, z=0},
		{x=-1, y=1,  z=0},
		{x=-1, y=-1, z=0},
		{x=-1, y=0,  z=0},
		{x=0,  y=-1, z=0},
		{x=0,  y=1,  z=0},
		{x=0,  y=2,  z=0},
	},
	action_on = function(pos, node)
		if nuke:can_detonate() then
			nuke:ignite(pos, node.name)
		end
	end,
}}

local node_groups = {dig_immediate = 3, mesecon = 2, falling_node=1}
local entity_groups = {punch_operable = 1}
local sounds = default.node_sound_stone_defaults()
local collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5}

local function on_punch(pos, node, player)
	local stack = player:get_wielded_item()
	local player_name = player:get_player_name()
	if stack:get_name() == "default:torch" and
			nuke:can_detonate(player_name) then
		nuke:ignite(pos, node.name, player_name)
	end
end

function nuke:register_nuke(name, description, radius, tiles)
	minetest.register_node(name, {
		tiles = tiles,
		description = description,
		sounds = sounds,
		groups = node_groups,
		on_punch = on_punch,
		mesecons = mesecon_def,
	})

	local e = self.entity
	minetest.register_entity(name, {
		textures = tiles,
		radius = radius,
		physical = true,
		collisionbox = collisionbox,
		visual = "cube",
		groups = entity_groups,
		health = 10,
		timer = 10,
		blinktimer = 0,
		blinkstatus = true,
		on_activate = e.on_activate,
		on_step = e.on_step,
		on_punch = e.on_punch,
		get_staticdata = e.get_staticdata,
		smoke_spawner = false,
	})

	self.cid_names[minetest.get_content_id(name)] = name

	if nuke:can_detonate() then
		minetest.register_abm({
			nodenames = {name},
			neighbors = {"group:igniter"},
			interval = 1,
			chance = 1,
			action = function(pos, node)
				self:ignite(pos, node.name)
			end
		})
	end
end

