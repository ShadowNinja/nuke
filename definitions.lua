
-- Convenience function
function nuke:get_tiles(name)
	local side = name.."_side.png"
	return {name.."_top.png", name.."_bottom.png",
		side, side, side, side}
end

-- Mese nuke
minetest.register_craft({
	output = "nuke:mese 3",
	recipe = {
		{"nuke:iron",            "default:mese_crystal", "nuke:iron"},
		{"default:mese_crystal", "nuke:iron",            "default:mese_crystal"},
		{"nuke:iron",            "default:mese_crystal", "nuke:iron"}
	}
})

nuke:register_nuke("nuke:mese",
		"Mese nuke",
		tonumber(nuke.config:get("mese_radius")),
		nuke:get_tiles("nuke_mese"))


-- Iron nuke
minetest.register_craft({
	output = "nuke:iron 3",
	recipe = {
		{"nuke:tnt",            "default:steel_ingot", "nuke:tnt"},
		{"default:steel_ingot", "nuke:tnt",            "default:steel_ingot"},
		{"nuke:tnt",            "default:steel_ingot", "nuke:tnt"}
	}
})

nuke:register_nuke("nuke:iron",
		"Iron nuke",
		tonumber(nuke.config:get("iron_radius")),
		nuke:get_tiles("nuke_iron"))


-- Normal TNT
minetest.register_craft({
	output = 'nuke:tnt 3',
	recipe = {
		{"default:coal_lump", "default:sand",      "default:coal_lump"},
		{"default:sand",      "default:coal_lump", "default:sand"},
		{"default:coal_lump", "default:sand",      "default:coal_lump"}
	}
})

nuke:register_nuke("nuke:tnt",
		"TNT",
		tonumber(nuke.config:get("tnt_radius")),
		nuke:get_tiles("default_tnt"))

