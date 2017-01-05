magic.crystals = {
    {
        name = "rage",
        desc = "Rage",
        color = "#A00",
        light = 10,
        ores = {
            {
                rarity = 10 * 10 * 10,
                clust_num_ores = 1,
                clust_size     = 1,
                wherein        = "default:lava_source",
                y_max = -64,
            },
        },
    },
    {
        name = "calm",
        desc = "Calm",
        color = "#00F",
        light = 5,
        ores = {
            {
                rarity = 10 * 10 * 10,
                clust_num_ores = 1,
                clust_size     = 1,
                wherein        = "default:water_source",
                y_max = -64,
            },
            {
                rarity = 16 * 16 * 16,
                clust_num_ores = 1,
                clust_size     = 1,
                wherein        = "default:water_source",
                y_min = -32,
                y_max = -8,
            },
        },
    },
}

for _,def in ipairs(magic.crystals) do
    minetest.register_node("magic:crystal_"..def.name, {
        description = def.desc.." Crystal",
        drawtype = "glasslike",
        tiles = {"magic_crystal.png^[colorize:"..def.color..":"..tostring(0xCC)},
        groups = {cracky = 2},
        light_source = def.light or 7,
        sunlight_propagates = true,
        use_texture_alpha = true,
        paramtype = "light",
        sounds = default.node_sound_stone_defaults(),
    })

    minetest.register_craftitem("magic:"..def.name.."_essence", {
        description = def.desc.." Essence",
        inventory_image = "magic_essence.png^[colorize:"..def.color..":"..tostring(0xCC),
    })

    local ndefd = {
        ore_type       = "scatter",
        ore            = "magic:crystal_"..def.name,
        wherein        = "default:stone",
        clust_num_ores = 1,
        clust_size     = 1,
        y_min          = -31000,
        y_max          = 31000,
    }

    if def.ores then
        for _,oredef in ipairs(def.ores) do
            local ndef = table.copy(ndefd)
            ndef.clust_scarcity = oredef.rarity * #magic.crystals * (def.rarity or 1)
            for k,v in pairs(oredef) do
                ndef[k] = v
            end
            minetest.register_ore(ndef)
        end
    end

    if not def.nodefgen then
        local ores = {
            {
                rarity = 16 * 16 * 16,
                clust_num_ores = 3,
                clust_size     = 2,
                y_max          = -64,
            },
            {
                rarity = 14 * 14 * 14,
                clust_num_ores = 3,
                clust_size     = 2,
                y_min          = 32,
            },
        }
        for _,oredef in ipairs(ores) do
            local ndef = table.copy(ndefd)
            ndef.clust_scarcity = oredef.rarity * #magic.crystals * (def.rarity or 1)
            for k,v in pairs(oredef) do
                ndef[k] = v
            end
            minetest.register_ore(ndef)
        end
    end
end
