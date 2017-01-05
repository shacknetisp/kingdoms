minetest.register_craft({
	output = 'default:chest_locked_heavy',
	recipe = {
		{'default:chest_locked', 'default:steel_ingot'},
	}
})

minetest.register_craft({
	output = "kingdoms:corestone",
	recipe = {
		{"magic:concentrated_area_essence", "magic:control_essence"},
		{"default:steelblock", "group:spellbinding"},
		{"magic:solidity_essence", "group:major_spellbinding"}
	}
})
minetest.register_craft({
	output = "kingdoms:claimward",
	recipe = {
		{"magic:area_essence", ""},
		{"default:steelblock", "magic:control_essence"},
		{"group:spellbinding", ""}
	}
})


minetest.register_craft({
	output = "kingdoms:materialized_wall_1",
	recipe = {
		{"magic:vitality_essence"},
		{"group:stone"},
		{"magic:concentrated_solidity_essence"}
	}
})
minetest.register_craft({
	output = "kingdoms:materializer",
	recipe = {
		{"magic:concentrated_vitality_essence", "magic:area_essence"},
		{"group:stone", "group:major_spellbinding"},
		{"magic:concentrated_solidity_essence", ""}
	}
})
