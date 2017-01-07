-- Create a small explosion of flowing water.
local function drop_water(self, pos)
    local water = "default:water_flowing"
    local limit = 5
    -- Put out fires first.
    local positions = kingdoms.utils.shuffled(kingdoms.utils.find_nodes_by_area(pos, 3, {"fire:basic_flame"}))
    for _,p in ipairs(positions) do
        limit = limit - 1
        minetest.set_node(p, {name=water})
        if limit <= 0 then
            break
        end
    end
    limit = math.max(limit, 3)
    -- A smaller air radius, avoiding travel through thick walls.
    positions = kingdoms.utils.shuffled(kingdoms.utils.find_nodes_by_area(pos, 1, {"air"}))
    for _,p in ipairs(positions) do
        limit = limit - 1
        minetest.set_node(p, {name=water})
        if limit <= 0 then
            break
        end
    end
    return true
end

magic.register_spell("magic:spell_water", {
    description = "Water Spell",
    type = "missile",
    color = "#00F",
    emblem = "action",
    speed = 20,
    cost = 4,
    gravity = 0.25,
    hit_node = drop_water,
    hit_object = drop_water,
})
minetest.register_craft({
    output = "magic:spell_water 2",
    recipe = {
        {"magic:calm_essence", "group:minor_spellbinding", "magic:area_essence"},
    },
})
