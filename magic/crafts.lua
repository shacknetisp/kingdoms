for _,def in ipairs(magic.crystals) do
    minetest.register_craft({
        type = "cooking",
        output = "magic:"..def.name.."_essence",
        recipe = "magic:crystal_"..def.name,
        cooktime = 6,
    })
end
