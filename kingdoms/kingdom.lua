kingdoms.db.kingdoms = kingdoms.db.kingdoms or {}

local kcommand = {
    params = "",
    description = "Display the Kingdoms GUI.",
    func = function(name)
        local kingdom = kingdoms.player.kingdom(name)
        if kingdom then
            local membersstring = nil
            for _,member in pairs(kingdom.members) do
                membersstring = (membersstring and (membersstring .. ",") or "")
                membersstring = membersstring .. minetest.formspec_escape(("%s - %d"):format(member.name, member.level))
            end
            membersstring = membersstring or ""
            minetest.show_formspec(name, "kingdoms:joined",
                "size[9,6]"
                .."label[0,0;"..minetest.formspec_escape(("%s | You are level %d in this kingdom."):format(kingdom.longname, kingdom.members[name].level)).."]"
                .."textlist[0,0.5;4,5;members;"..membersstring.."]"
            )
        else
            local invitestring = nil
            for _,invite in ipairs(kingdoms.db.invites[name]) do
                invitestring = (invitestring and (invitestring .. ",") or "")
                invitestring = invitestring .. minetest.formspec_escape(("%s from %s"):format(kingdoms.db.kingdoms[invite.kingdom].longname, invite.sender))
            end
            invitestring = invitestring or ""
            minetest.show_formspec(name, "kingdoms:unjoined",
                "size[9,6]"
                .."textlist[0,0;4,5;invitations;"..invitestring.."]"
                .."button[0,5;4,1;acceptinvite;Accept Invitation]"
                .."field[4.75,0.5;4,0.5;name;Kingdom Name (will remove extra whitespace);]"
                .."button[4.5,1;4,1;create;Create Kingdom]"
            )
        end
    end
}
minetest.register_chatcommand("k", kcommand)
minetest.register_chatcommand("kingdoms", kcommand)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "kingdoms:unjoined" then return false end
    local name = player:get_player_name()
    if fields.acceptinvite then
        if not fields.invitations then
            minetest.chat_send_player(name, "You must select an invitation.")
            return true
        end
        local invite = kingdoms.db.invites[name][fields.invitations]
        if not invite then
            minetest.chat_send_player(name, "That invitation does not exist.")
            return true
        end
    elseif fields.create then
        local formattedname = fields.name:gsub("%s%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        if formattedname == "" then
            minetest.chat_send_player(name, "You must name your kingdom something.")
            return true
        end
        local kingdom = {
            id = kingdoms.utils.uniqueid(),
            longname = formattedname,
            members = {},
        }
        for _,k in ipairs(kingdoms.db.kingdoms) do
            if k.id == kingdom.id then
                minetest.chat_send_player(name, "You have managed to collide with another kingdom's ID. Impressive. Try again for a new random ID.")
                return true
            end
            if k.longname == kingdom.longname then
                minetest.chat_send_player(name, "There is already a kingdom with that name.")
                return true
            end
        end
        kingdoms.db.players[name] = kingdom.id
        kingdom.members[name] = {
            name = name,
            level = 100,
        }
        kingdoms.db.kingdoms[kingdom.id] = kingdom
        kingdoms.log("action", ("Kingdom %s ('%s') was created by '%s'."):format(kingdom.id, kingdom.longname, name))
        minetest.chat_send_player(name, "You are now the Monarch of "..kingdom.longname)
        -- Switch to the other formspec.
        kcommand.func(name)
        return true
    end
end)
