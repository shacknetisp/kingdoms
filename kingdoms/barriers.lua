minetest.register_node("kingdoms:materializer", {
    description = "Materializer",
    drawtype = "nodebox",
    tiles = {"kingdoms_materializer.png"},
    sounds = default.node_sound_stone_defaults(),
    groups = {cracky = 1, level = 2},
    is_ground_content = false,
    paramtype = "light",
    light_source = 0,

    node_box = {
        type = "fixed",
        fixed = {
            {-0.5 ,-0.5, -0.5, 0.5, 0.5, 0.5},
        }
    },
})

for level = 1, kingdoms.config.materialized_levels do
    local first = (level == 1)
    local last = (level == kingdoms.config.materialized_levels)
    local drop = {}
    -- If this is the first level, it should drop something instead of downgrading.
    if first then
        drop = nil
    end
    minetest.register_node("kingdoms:materialized_wall_"..tostring(level), {
        description = "Materializer Wall Level "..tostring(level),
        drawtype = "nodebox",
        tiles = (last and {"kingdoms_materialized_final.png"} or {"kingdoms_materialized.png"}),
        sounds = default.node_sound_stone_defaults(),
        -- Only include the first and last in the creative inventory.
        groups = {cracky = 1, level = 2, not_in_creative_inventory = ((first or last) and 0 or 1), kingdoms_materialized_up=(last and 0 or 1), block_explosion=(first and 1 or 2)},
        is_ground_content = false,
        paramtype = "light",
        light_source = 0,
        drop = drop,
        level = level,
        node_box = {
            type = "fixed",
            fixed = {
                {-0.5 ,-0.5, -0.5, 0.5, 0.5, 0.5},
            }
        },
        on_destruct = function(pos)
            if not first then
                minetest.after(0, minetest.set_node, pos, {name="kingdoms:materialized_wall_"..tostring(level - 1)})
            end
        end,
        on_blast = function(pos)
            if first then
                minetest.remove_node(pos)
            else
                minetest.after(0, minetest.set_node, pos, {name="kingdoms:materialized_wall_"..tostring(level - 1)})
            end
        end,
    })
end

minetest.register_abm{
    nodenames = {"group:kingdoms_materialized_up"},
    interval = kingdoms.config.materialized_abm_interval,
    chance = kingdoms.config.materialized_abm_chance,
    action = function(pos, node)
        local nextname = "kingdoms:materialized_wall_"..tostring(minetest.registered_nodes[node.name].level + 1)
        local r = kingdoms.config.materializer_radius
        local positions = minetest.find_nodes_in_area(
            {x = pos.x - r, y = pos.y - r, z = pos.z - r},
            {x = pos.x + r, y = pos.y + r, z = pos.z + r},
            {"kingdoms:materializer"})
        for _, mpos in ipairs(positions) do
            -- local meta = minetest.get_meta(mpos)
            minetest.swap_node(pos, {name=nextname})
            return
        end
    end,
}
