-- Set flags used by Kingdoms.
minetest.register_on_mapgen_init(function(params)
    minetest.set_mapgen_params({
        mgname = "v7",
        flags = "trees, caves, dungeons, noflat, light, decorations",
    })
    -- Biomes won't be registered properly until done manually.
    default.register_biomes()
    default.register_decorations()
    magic.register_mapgen()
end)

local registered_items = {}
function kingdoms.register_dungeon_node(name, probability)
    registered_items[name] = math.ceil((probability or 3) * 100)
end

local defaultitems = {
    ["default:mese"] = 1,
    ["default:diamondblock"] = 1,

    ["default:goldblock"] = 2,
    ["default:copperblock"] = 2,

    ["default:bronzeblock"] = 3,
    ["default:steelblock"] = 3,

    ["default:obsidian"] = 3,
    ["default:coalblock"] = 3,
}

for k,v in pairs(defaultitems) do
    kingdoms.register_dungeon_node(k, v)
end

local function place_item(tab)
    local items = kingdoms.utils.probability_list(registered_items)
    local pos = tab[math.random(1, (#tab or 4))]
    pos.y = pos.y - 1
    local n = core.get_node_or_nil(pos)
    if n and n.name ~= "air" then
        pos.y = pos.y + 1
        local name = items[math.random(1, #items)]
        --Failsafe
        if minetest.registered_nodes[name] then
            core.set_node(pos, {name = name})
        else
            kingdoms.log("warning", "Tried to place unregistered node "..name.." in dungeon.")
        end
    end
end

core.set_gen_notify("dungeon")
core.register_on_generated(function(minp, maxp, blockseed)
    local ntf = core.get_mapgen_object("gennotify")
    if ntf and ntf.dungeon and #ntf.dungeon > 0 then
        core.after(3, place_item, table.copy(ntf.dungeon))
        if math.random(1, 100) < 25 then
            core.after(3, place_item, table.copy(ntf.dungeon))
        end
        if math.random(1, 100) < 25 then
            core.after(3, place_item, table.copy(ntf.dungeon))
        end
    end
end)
