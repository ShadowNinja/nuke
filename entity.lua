nuke.entity = {}

local function remove_smoke(e)
	if e.smoke_spawner then
		minetest.delete_particlespawner(e.smoke_spawner)
	end
	-- For add_particlespawner hack to detect if we've been removed
	e.smoke_spawner = nil
end

function nuke.entity:on_activate(staticdata)
	if static_data and static_data ~= "" then
		for k, v in pairs(minetest.deserialize(static_data)) do
			self[k] = v
		end
	end
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
				local time = self.timer
				self.smoke_spawner = minetest.add_particlespawner({
					amount = 50 * time,
					time = time,
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
	self.timer = self.timer - dtime
	self.blinktimer = self.blinktimer + ((5 * dtime) / self.timer)
	if self.blinktimer > 1 then
		self.blinktimer = self.blinktimer - 1
		o:settexturemod(self.blinkstatus and "" or "^[brighten")
		self.blinkstatus = not self.blinkstatus
	end

	if self.timer <= 0 then
		nuke:detonate(self, self.radius)
		remove_smoke(self)
	end
end

function nuke.entity:on_punch(hitter)
	self.object:remove()
	remove_smoke(self)
	hitter:get_inventory():add_item("main", self.name)
end

function nuke.entity:get_staticdata()
	remove_smoke(self)
	return minetest.serialize({
		player_name = self.player_name,
	})
end

