-- Set flags used by Kingdoms.
if kingdoms.config.mapgen then
    minetest.clear_registered_biomes()
    minetest.clear_registered_decorations()

    minetest.set_mapgen_setting("mgname", "v7")
    minetest.set_mapgen_setting("flags", "trees, caves, dungeons, noflat, light, decorations")

    default.register_biomes()
    default.register_decorations()
    kingdoms.log("action", "Applied mapgen settings.")
end
magic.register_mapgen()
