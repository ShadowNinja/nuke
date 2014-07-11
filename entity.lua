nuke.entity = {}

function nuke.entity:on_activate(staticdata)
	local o = self.object
	o:setvelocity({x=0, y=3, z=0})
	o:setacceleration({x=0, y=-5, z=0})
	o:settexturemod("^[brighten")
	if nuke.config:get_bool("fancy") then
		local pos = o:getpos()
		local min_pos = vector.new(pos)
		min_pos.x = min_pos.x - 0.2
		min_pos.y = min_pos.y + 0.5
		min_pos.z = min_pos.z - 0.2
		local max_pos = vector.new(pos)
		max_pos.x = max_pos.x + 0.2
		max_pos.y = max_pos.y + 0.5
		max_pos.z = max_pos.z + 0.2
		-- add_particlespawner silently fails in entity callbacks, so
		-- use minetest.after to call it later.
		minetest.after(0, function()
			if self.smoke_spawner == false then
				self.smoke_spawner = minetest.add_particlespawner({
					amount = 512,
					time = 10,
					minpos = min_pos,
					maxpos = max_pos,
					minvel = {x=-1, y=1, z=-1},
					maxvel = {x=1,  y=4,  z=1},
					minacc = vector.new(),
					maxacc = vector.new(),
					minexptime = 0.2,
					maxexptime = 0.4,
					minsize = 2,
					maxsize = 3,
					collisiondetection = false,
					texture = "nuke_smoke_dark.png",
				})
			end
		end)
	end
end

function nuke.entity:on_step(dtime)
	local o = self.object
	self.timer = self.timer + dtime
	self.blinktimer = self.blinktimer + (dtime * self.timer)
	if self.blinktimer > 1 then
		self.blinktimer = self.blinktimer - 1
		o:settexturemod(self.blinkstatus and "" or "^[brighten")
		self.blinkstatus = not self.blinkstatus
	end

	if self.timer < 10 then
		return
	end
	-- Explode
	local pos = vector.round(o:getpos())
	local node = minetest.get_node(pos)

	-- Cause entity physics even if we are put out.
	-- This isn't very realistic but it allows for cannons.
	o:remove()
	minetest.sound_play("nuke_explode",
		{pos = pos, gain = 1.0, max_hear_distance = 16})
	nuke:entity_physics(pos, self.radius)
	if minetest.get_item_group(node.name, "puts_out_fire") <= 0 then
		nuke:explode(pos, self.radius)
	end
	if nuke.config:get_bool("fancy") then
		nuke:effects(pos, self.radius)
	end
end

function nuke.entity:on_punch(hitter)
	self.object:remove()
	hitter:get_inventory():add_item("main", self.name)
	if self.smoke_spawner then
		minetest.delete_particlespawner(self.smoke_spawner)
	end
	-- For add_particlespawner hack to detect if we've been removed
	self.smoke_spawner = nil
end

function nuke.entity:get_staticdata()
	if self.smoke_spawner then
		minetest.delete_particlespawner(self.smoke_spawner)
	end
	-- For add_particlespawner hack to detect if we've been removed
	self.smoke_spawner = nil
end

