
local worldpath = minetest.get_worldpath()
nuke.config = Settings(worldpath..DIR_DELIM.."nuke.conf")

local defaults = {
	missile_radius = "16",
	missile_misfire_radius = "5",
	mese_radius = "24",
	iron_radius = "12",
	tnt_radius = "3",
	fancy = "true",
	unprivileged_detonation = "false",
}

local config = nuke.config
for k, v in pairs(defaults) do
	if config:get(k) == nil then
		config:set(k, v)
	end
end

