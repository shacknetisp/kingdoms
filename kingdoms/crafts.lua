local has_magic = rawget(_G, 'magic') ~= nil
local essences = {
    concentrated_area = has_magic and "magic:concentrated_area_essence" or "group:major_spellbinding",
    control = has_magic and "magic:control_essence" or "group:spellbinding",
    concentrated_control = has_magic and "magic:concentrated_control_essence" or "group:major_spellbinding",
    solidity = has_magic and "magic:solidity_essence" or "group:spellbinding",
    concentrated_solidity = has_magic and "magic:concentrated_solidity_essence" or "group:major_spellbinding",
    rage = has_magic and "magic:rage_essence" or "group:spellbinding",
    vitality = has_magic and "magic:vitality_essence" or "group:spellbinding",
    concentrated_vitality = has_magic and "magic:concentrated_vitality_essence" or "group:major_spellbinding",
}

minetest.register_craft({
    output = 'default:chest_locked_heavy',
    recipe = {
        {'default:chest_locked', 'default:steel_ingot'},
    }
})

minetest.register_craft({
    output = "kingdoms:corestone",
    recipe = {
        {essences.concentrated_area, essences.control},
        {"default:steelblock", "group:spellbinding"},
        {essences.solidity, "group:major_spellbinding"}
    }
})
minetest.register_craft({
    output = "kingdoms:claimward",
    recipe = {
        {essences.area, ""},
        {"default:steelblock", essences.control},
        {"group:spellbinding", ""}
    }
})
minetest.register_craft({
    output = "kingdoms:core_disruptor",
    recipe = {
        {essences.concentrated_area, essences.rage},
        {"default:steelblock", essences.concentrated_control},
        {"group:major_spellbinding", ""}
    }
})


minetest.register_craft({
    output = "kingdoms:materialized_wall_1 9",
    recipe = {
        {essences.vitality, "", ""},
        {"group:stone", "group:stone", "group:stone"},
        {essences.concentrated_solidity, "", ""}
    }
})
minetest.register_craft({
    output = "kingdoms:materializer",
    recipe = {
        {essences.concentrated_vitality, essences.area},
        {"group:stone", "group:major_spellbinding"},
        {essences.concentrated_solidity, ""}
    }
})
