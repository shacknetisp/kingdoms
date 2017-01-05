if rawget(_G, "unified_inventory") then
    unified_inventory.register_button("kingdoms", {
        type = "image",
        image = "ui_kingdoms_icon.png",
        tooltip = "Open the kingdoms GUI",
        hide_lite=false,
        action = function(player)
            kingdoms.show_main_formspec(player:get_player_name())
        end,
    })
end
