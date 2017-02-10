-- Set flags used by Kingdoms.
if kingdoms.config.mapgen then

    minetest.set_mapgen_setting("mgname", "v7")
    minetest.set_mapgen_setting("flags", "trees, caves, dungeons, noflat, light, decorations")

    kingdoms.log("action", "Applied mapgen settings.")
end
