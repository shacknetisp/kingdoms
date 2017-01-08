minetest.register_node("kingdoms:stone_with_silver", {
    description = "Silver Ore",
    tiles = {"default_stone.png^kingdoms_mineral_silver.png"},
    groups = {cracky = 2},
    drop = "kingdoms:silver_lump",
    sounds = default.node_sound_stone_defaults(),
})

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "kingdoms:stone_with_silver",
    wherein        = "default:stone",
    clust_scarcity = 11 * 11 * 11,
    clust_num_ores = 5,
    clust_size     = 4,
    y_min          = 128,
    y_max          = 31000,
})

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "kingdoms:stone_with_silver",
    wherein        = "default:stone",
    clust_scarcity = 16 * 16 * 16,
    clust_num_ores = 5,
    clust_size     = 4,
    y_min          = 32,
    y_max          = 128,
})

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "kingdoms:stone_with_silver",
    wherein        = "default:stone",
    clust_scarcity = 14 * 14 * 14,
    clust_num_ores = 4,
    clust_size     = 2,
    y_min          = -255,
    y_max          = -32,
})

minetest.register_ore({
    ore_type       = "scatter",
    ore            = "kingdoms:stone_with_silver",
    wherein        = "default:stone",
    clust_scarcity = 12 * 12 * 12,
    clust_num_ores = 6,
    clust_size     = 3,
    y_min          = -31000,
    y_max          = -256,
})

minetest.register_node("kingdoms:silverblock", {
    description = "Silver Block",
    tiles = {"kingdoms_silver_block.png"},
    is_ground_content = false,
    groups = {cracky = 1, spellbinding = 1, major_spellbinding = 1},
    sounds = default.node_sound_stone_defaults(),
})

if rawget(_G, 'ancient_world') then
    ancient_world.register_item("kingdoms:silverblock", 2)
end

minetest.register_craftitem("kingdoms:silver_lump", {
    description = "Silver Lump",
    inventory_image = "kingdoms_silver_lump.png",
})

minetest.register_craftitem("kingdoms:silver_ingot", {
    description = "Silver Ingot",
    inventory_image = "kingdoms_silver_ingot.png",
    groups = {spellbinding = 1, minor_spellbinding = 1},
})

minetest.register_craftitem("kingdoms:silver_shard", {
    description = "Silver Shard",
    inventory_image = "kingdoms_silver_shard.png",
    groups = {minor_spellbinding = 1},
})

minetest.register_craft({
    output = 'kingdoms:silver_shard 9',
    recipe = {
        {'kingdoms:silver_ingot'},
    }
})

minetest.register_craft({
    output = 'kingdoms:silverblock',
    recipe = {
        {'kingdoms:silver_ingot', 'kingdoms:silver_ingot', 'kingdoms:silver_ingot'},
        {'kingdoms:silver_ingot', 'kingdoms:silver_ingot', 'kingdoms:silver_ingot'},
        {'kingdoms:silver_ingot', 'kingdoms:silver_ingot', 'kingdoms:silver_ingot'},
    }
})

minetest.register_craft({
    output = 'kingdoms:silver_ingot 9',
    recipe = {
        {'kingdoms:silverblock'},
    }
})

minetest.register_craft({
    output = 'kingdoms:silver_ingot',
    recipe = {
        {'kingdoms:silver_shard', 'kingdoms:silver_shard', 'kingdoms:silver_shard'},
        {'kingdoms:silver_shard', 'kingdoms:silver_shard', 'kingdoms:silver_shard'},
        {'kingdoms:silver_shard', 'kingdoms:silver_shard', 'kingdoms:silver_shard'},
    }
})

minetest.register_craft({
    type = "cooking",
    output = "kingdoms:silver_ingot",
    recipe = "kingdoms:silver_lump",
})

minetest.register_alias("moreores:silver_lump", "kingdoms:silver_lump")
minetest.register_alias("moreores:mineral_silver", "kingdoms:stone_with_silver")
minetest.register_alias("moreores:silver_block", "kingdoms:silverblock")
