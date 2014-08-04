
local priv_set = {pyrotechnic=true}
function nuke:can_detonate(player_name)
	if self.config:get_bool("unprivileged_detonation") or
			(player_name and minetest.check_player_privs(
				player_name, priv_set)) then
		return true
	end
	return false
end


function nuke:ignite(pos, node_name, player_name, time)
	minetest.dig_node(pos)
	minetest.sound_play("nuke_ignite",
			{pos = pos, gain = 1.0, max_hear_distance = 10})
	local o = minetest.add_entity(pos, node_name)
	local e = o:get_luaentity()
	e.player_name = player_name
	if time then
		e.timer = time
	end
	return o
end


function nuke:calc_velocity(pos1, pos2, old_vel, power)
	local vel = vector.direction(pos1, pos2)
	vel = vector.normalize(vel)
	vel = vector.multiply(vel, power * 10)

	-- Divide by distanve
	local dist = vector.distance(pos1, pos2)
	dist = math.max(dist, 1)
	vel = vector.divide(vel, dist)

	-- Add old velocity
	vel = vector.add(vel, old_vel)
	return vel
end

-- Entity physics
function nuke:entity_physics(pos, radius)
	-- Make the damage radius larger than the destruction radius
	radius = radius * 2
	local objs = minetest.get_objects_inside_radius(pos, radius)
	for _, obj in pairs(objs) do
		local obj_vel = obj:getvelocity()
		local obj_pos = obj:getpos()
		local dist = vector.distance(pos, obj_pos)
		local damage = (4 / math.max(dist, 1)) * radius
		obj:set_hp(obj:get_hp() - damage)

		-- Ignore velocity calculation for entities exactly at our
		-- position (us) and entities without velocity
		-- (non-LuaEntitySAO).
		if dist ~= 0 and obj_vel ~= nil then
			obj:setvelocity(nuke:calc_velocity(pos, obj_pos,
					obj_vel, radius))
		end
	end
end


function nuke:effects(pos, radius)
	minetest.add_particlespawner({
		amount = math.min(128 * radius / 2, 4096),
		time = 1,
		minpos = vector.subtract(pos, radius / 2),
		maxpos = vector.add(pos, radius / 2),
		minvel = {x=-20, y=-20, z=-20},
		maxvel = {x=20,  y=20,  z=20},
		minacc = vector.new(),
		maxacc = vector.new(),
		minexptime = 1,
		maxexptime = 3,
		minsize = 8,
		maxsize = 16,
		collisiondetection = true,
		texture = "nuke_smoke_light.png",
	})
end


function nuke:check_protection(pos, radius, player_name)
	if areas and areas.canInteractInArea and
			not areas:canInteractInArea(
				vector.subtract(pos, radius),
				vector.add     (pos, radius),
				player_name) then
		return false
	end
	return true
end


function nuke:detonate(entity, radius)
	local e, o = entity, entity.object
	local pos = o:getpos()

	o:remove()

	-- Check protection
	if not self:check_protection(pos, radius, e.player_name) then
		if e.player_name then
			minetest.chat_send_player(e.player_name,
					"Can't detonate, area protected.")
		end
		minetest.add_item(pos, e.name)
		return
	end

	-- Cause entity physics even if we are put out.
	-- This isn't very realistic but it allows for cannons.
	minetest.sound_play("nuke_explode",
		{pos = pos, gain = 1.0, max_hear_distance = 16})
	self:entity_physics(pos, radius)
	local node = minetest.get_node(pos)
	if minetest.get_item_group(node.name, "puts_out_fire") <= 0 then
		self:explode(pos, radius, e.player_name)
	end
	if self.config:get_bool("fancy") then
		self:effects(pos, radius)
	end
end


function nuke:explode(pos, radius, player_name)
	local start = os.clock()
	local pos = vector.round(pos)
	local vm = VoxelManip()
	local pr = PseudoRandom(os.time())
	local p1 = vector.subtract(pos, radius)
	local p2 = vector.add(pos, radius)
	local MinEdge, MaxEdge = vm:read_from_map(p1, p2)
	local a = VoxelArea:new({MinEdge = MinEdge, MaxEdge = MaxEdge})
	local data = vm:get_data()

	local cid_names = nuke.cid_names
	local p = {}

	local c_air = minetest.get_content_id("air")

	for z = -radius, radius do
	for y = -radius, radius do
	local vi = a:index(pos.x - radius, pos.y + y, pos.z + z)
	for x = -radius, radius do
		if (x * x) + (y * y) + (z * z) <=
				(radius * radius) + pr:next(-radius, radius) then
			local name = cid_names[data[vi]]
			if name then
				p.x = pos.x + x
				p.y = pos.y + y
				p.z = pos.z + z
				self:ignite(p, name, player_name, 1)
			end
			data[vi] = c_air
		end
		vi = vi + 1
	end
	end
	end

	vm:set_data(data)
	vm:update_liquids()
	vm:write_to_map()
	vm:update_map()
	print("Nuke exploded in "..(os.clock() - start).." seconds")
end

