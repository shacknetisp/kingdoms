for _,def in ipairs(magic.crystals) do
    minetest.register_craft({
        type = "cooking",
        output = "magic:"..def.name.."_essence",
        recipe = "magic:crystal_"..def.name,
        cooktime = 6,
    })
    minetest.register_craft({
        type = "shapeless",
        output = "magic:crystal_"..def.name,
        recipe = {"magic:"..def.name.."_essence", "group:spellbinding", "group:stone"}
    })
    minetest.register_craft({
        type = "shapeless",
        output = "magic:concentrated_"..def.name.."_essence",
        recipe = {"magic:"..def.name.."_essence", "magic:"..def.name.."_essence", "magic:"..def.name.."_essence"}
    })
    if def.fuel then
        minetest.register_craft({
            type = "fuel",
            recipe = "magic:crystal_"..def.name,
            burntime = def.fuel,
        })
    end
end
