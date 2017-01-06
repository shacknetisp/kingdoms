kingdoms.db.kingdoms = kingdoms.db.kingdoms or {}

local selectedmember = {}
local selectedinvitation = {}

local kmenuitems = {
    {"invite", "Manage invitations", "invite"},
    {"levels", "Manage levels"},
    {"info", "Manage the description"},
    {"rename", "Rename the kingdom", "rename"},
    {"leave", "Leave the kingdom"},
}

-- The main formspecs, contains menus and options to all others and information about the current status.
local kcommand = {
    params = "",
    description = "Display the Kingdoms GUI.",
    func = function(name)
        local kingdom = kingdoms.player.kingdom(name)
        if kingdom then
            selectedmember[name] = nil
            local membersstring = nil
            for _,n in ipairs(kingdom.memberlist) do
                local member = kingdom.members[n]
                membersstring = (membersstring and (membersstring .. ",") or "")
                membersstring = membersstring .. minetest.formspec_escape(("%s - %d"):format(member.name, member.level))
            end
            membersstring = membersstring or ""
            local kmenuitemsd = {}
            for _,item in ipairs(kmenuitems) do
                if item[3] then
                    if kingdoms.player.can(name, item[3]) then
                        table.insert(kmenuitemsd, minetest.formspec_escape(item[2]))
                    else
                        table.insert(kmenuitemsd, "---")
                    end
                else
                    table.insert(kmenuitemsd, minetest.formspec_escape(item[2]))
                end
            end
            minetest.show_formspec(name, "kingdoms:joined",
                "size[9,6]"
                .."label[0,0;"..minetest.formspec_escape(("%s | You are level %d in this kingdom."):format(kingdom.longname, kingdom.members[name].level)).."]"
                .."label[0,0.5;Age: "
                    ..kingdoms.utils.s("day", math.floor((os.time() - kingdom.created) / 60 / 60 / 24))
                    .." days | Corestone: "..minetest.formspec_escape(kingdom.corestone.pos and minetest.pos_to_string(kingdom.corestone.pos) or "N/A")
                    ..minetest.formspec_escape("\n")..kingdoms.utils.s("member", #kingdom.memberlist)
                    .." | Corestone score: "..tostring(math.ceil((kingdom.corestone.score / kingdoms.config.corestone_score_max) * 1000) / 10).."%"
                    .."]"
                .."textlist[0,1.5;4,4;members;"..membersstring.."]"
                .."label[4.5,0;Kingdom Menu]"
                .."textlist[4.75,0.5;4,5;menu;"..table.concat(kmenuitemsd, ",").."]"
            )
        else
            selectedinvitation[name] = 1
            local invitestring = nil
            if kingdoms.db.invitations[name] then
                for _,invite in ipairs(kingdoms.db.invitations[name]) do
                    invitestring = (invitestring and (invitestring .. ",") or "")
                    invitestring = invitestring .. minetest.formspec_escape(("%s from %s"):format(kingdoms.db.kingdoms[invite.kingdom].longname, invite.sender))
                end
            end
            invitestring = invitestring or ""
            minetest.show_formspec(name, "kingdoms:unjoined",
                "size[9,6]"
                .."textlist[0,0;4,5;invitations;"..invitestring..";1]"
                .."button[0,5;4,1;acceptinvite;Accept Invitation]"
                .."field[4.75,0.5;4,0.5;name;Kingdom Name (will remove extra whitespace);]"
                .."button[4.5,1;4,1;create;Create Kingdom]"
            )
        end
        return true
    end
}
kingdoms.show_main_formspec = kcommand.func
minetest.register_chatcommand("k", kcommand)
minetest.register_chatcommand("kingdoms", kcommand)

function kingdoms.corestone_change(kingdom, delta)
    kingdom.corestone.score = kingdom.corestone.score + delta
    kingdom.corestone.score = math.min(kingdoms.config.corestone_score_max, kingdom.corestone.score)
    kingdom.corestone.score = math.max(0, kingdom.corestone.score)
    if kingdom.corestone.score == 0 and kingdom.corestone.pos then
        kingdoms.log("action", "Corestone removed due to 0 score:")
        minetest.remove_node(kingdom.corestone.pos)
    end
end

-- Generate a dynamic list of default level names.
function kingdoms.possible_levels()
    local ret = {}
    for k,v in kingdoms.utils.spairs(kingdoms.config._defaults, function(t, a, b)
            return (t[a] == t[b]) and (a < b) or ((tonumber(t[a]) or 0) > (tonumber(t[b]) or 0))
        end) do
        local value = string.match(k, "default_level_(.*)")
        if value then
            table.insert(ret, value)
        end
    end
    return ret
end

local function clear_invitations(name)
    if not kingdoms.db.invitations[name] then return end
    for _,i in ipairs(kingdoms.db.invitations[name]) do
        local ikingdom = kingdoms.db.kingdoms[i.kingdom]
        ikingdom.invitations = kingdoms.utils.filteri(ikingdom.invitations, function(v)
            return v ~= name
        end)
    end
    kingdoms.db.invitations[name] = {}
end

local function leave_kingdom(name)
    local kingdom = kingdoms.player.kingdom(name)
    local level = kingdoms.player.kingdom_state(name).level

    kingdom.memberlist = kingdoms.utils.filteri(kingdom.memberlist, function(v) return v ~= name end)
    kingdom.members[name] = nil
    kingdoms.db.players[name] = nil

    -- If there are no members, then the kingdom is disbanded.
    if #kingdom.memberlist == 0 then
        kingdoms.db.invitations = kingdoms.utils.filteri(kingdoms.db.invitations, function(v) return v.kingdom ~= kingdom.id end)
        kingdoms.db.kingdoms[kingdom.id] = nil
        kingdoms.log("action", ("Kingdom %s ('%s') has been disbanded as '%s' leaves."):format(kingdom.id, kingdom.longname, name))
        minetest.chat_send_player(name, ("%s has been disbanded."):format(kingdom.longname))
        return
    end

    -- If this was the level 100 member, choose a new level 100 member from the highest-level member available. If there are two or more, choose the one who joined first.
    -- Level 100s can choose their successor by reserving level 99 for that purpose.
    if level == kingdoms.config.maxlevel then
        local highest = kingdom.members[kingdom.memberlist[1]]
        for _,member in pairs(kingdom.members) do
            if member.level > highest.level then
                highest = member
            elseif member.level == highest.level and member.joined < highest.joined then
                highest = member
            end
        end
        highest.level = kingdoms.config.maxlevel
        kingdoms.log("action", ("%s is the new monarch of '%s'."):format(highest.name, kingdom.longname))
        minetest.chat_send_player(name, ("%s is the new monarch of %s"):format(highest.name, kingdom.longname))
        minetest.chat_send_player(highest.name, ("You are the new monarch of %s"):format(kingdom.longname))
    end
end

-- The Neutral formspec, displays a list of invitations and functionality to create a new kingdom.
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "kingdoms:unjoined" then return false end
    local name = player:get_player_name()
    if fields.acceptinvite then
        if not selectedinvitation[name] or selectedinvitation[name] == 0 or not kingdoms.db.invitations[name] then
            minetest.chat_send_player(name, "You must select an invitation.")
            return true
        end
        local invite = kingdoms.db.invitations[name][selectedinvitation[name]]
        if not invite then
            minetest.chat_send_player(name, "That invitation does not exist.")
            return true
        end
        local kingdom = kingdoms.db.kingdoms[invite.kingdom]
        kingdoms.db.players[name] = kingdom.id
        kingdom.members[name] = {
            name = name,
            level = kingdoms.config.minlevel,
            joined = os.time(),
        }
        table.insert(kingdom.memberlist, name)

        clear_invitations(name)

        kingdoms.log("action", ("'%s' has joined '%s'."):format(name, kingdom.longname))
        minetest.chat_send_player(name, "You are now a member of "..kingdom.longname)
        return kcommand.func(name)
    elseif fields.invitations then
        selectedinvitation[name] = minetest.explode_textlist_event(fields.invitations).index
        return true
    elseif fields.create then
        local formattedname = fields.name:gsub("%s%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        if formattedname == "" then
            minetest.chat_send_player(name, "You must name your kingdom something.")
            return true
        end
        if formattedname:len() > kingdoms.config.max_name_length then
            minetest.chat_send_player(name, "That name is too long.")
            return true
        end

        local kingdom = {
            id = kingdoms.utils.uniqueid(),
            longname = formattedname,
            created = os.time(),
            members = {},
            memberlist = {},
            invitations = {},
            levels = {},
            corestone = {
                placed = 0,
                dug = 0,
                score = kingdoms.config.corestone_score_max,
            },
        }
        for _,k in pairs(kingdoms.db.kingdoms) do
            if k.id == kingdom.id then
                minetest.chat_send_player(name, "You have managed to collide with another kingdom's ID. Impressive. Try again for a new random ID.")
                return true
            end
            if k.longname == kingdom.longname then
                minetest.chat_send_player(name, "There is already a kingdom with that name.")
                return true
            end
        end

        clear_invitations(name)

        kingdoms.db.players[name] = kingdom.id
        kingdom.members[name] = {
            name = name,
            level = kingdoms.config.maxlevel,
            joined = os.time(),
        }
        table.insert(kingdom.memberlist, name)
        kingdoms.db.kingdoms[kingdom.id] = kingdom
        kingdoms.log("action", ("Kingdom %s ('%s') was created by '%s'."):format(kingdom.id, kingdom.longname, name))
        minetest.chat_send_player(name, "You are now the Monarch of "..kingdom.longname)
        -- Switch to the other formspec.
        return kcommand.func(name)
    end
    return true
end)

-- The invitations formspec, manages invitations sent.
local formspec_invitations
formspec_invitations = {
    selected = {},
    func = function(name)
        local kingdom = kingdoms.player.kingdom(name)
        formspec_invitations.selected[name] = kingdom.invitations[1]
        minetest.show_formspec(name, "kingdoms:invitations",
            "size[9,7]"
            .."button[0,0;6,1;kingdoms_special_exit;X]"
            .."textlist[0,1;4,5;invitations;"..table.concat(kingdom.invitations, ",")..";1]"
            .."button[0,6;4,1;cancel;Cancel Invitation]"
            .."field[4.75,1.5;4,0.5;iname;Target Name;]"
            .."button[4.5,2;4,1;invite;Invite]"
        )
        return true
    end,
}

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "kingdoms:invitations" then return false end
    local name = player:get_player_name()
    local kingdom = kingdoms.player.kingdom(name)
    if not kingdoms.player.can(name, "invite") then return true end
    if fields.invite then
        if not core.get_auth_handler().get_auth(fields.iname) then
            minetest.chat_send_player(name, "That player does not exist.")
            return true
        end
        if kingdoms.player.kingdom(fields.iname) then
            minetest.chat_send_player(name, "That player is already in a kingdom.")
            return true
        end
        kingdoms.db.invitations[fields.iname] = kingdoms.db.invitations[fields.iname] or {}
        table.insert(kingdoms.db.invitations[fields.iname], {
            sender = name,
            kingdom = kingdom.id,
        })
        table.insert(kingdom.invitations, fields.iname)
        return formspec_invitations.func(name)
    elseif fields.cancel then
        local selected = formspec_invitations.selected[name]
        if not selected then return true end
        kingdoms.db.invitations[selected] = kingdoms.utils.filteri(kingdoms.db.invitations[selected], function(v)
            return v ~= kingdom.id
        end)
        kingdom.invitations = kingdoms.utils.filteri(kingdom.invitations, function(v)
            return v ~= selected
        end)
        return formspec_invitations.func(name)
    elseif fields.invitations then
        formspec_invitations.selected[name] = kingdom.invitations[minetest.explode_textlist_event(fields.invitations).index]
    end
end)

-- The member formspec, manages an individual member.
local formspec_member = {
    func = function(name)
        local selected = selectedmember[name]
        local sstate = kingdoms.player.kingdom_state(selected)
        minetest.show_formspec(name, "kingdoms:member",
            "size[5,3]"
            .."button[0,0;5,1;kingdoms_special_exit;X]"
            .."label[0,1;"..selected.." - "..tostring(sstate.level).."]"
            .."button[0,1.5;5,0.5;kick;Kick]"
            .."field[0.25,3;1,0;level;Level "..tostring(sstate.level)..";"..tostring(sstate.level).."]"
            .."button[1.2,2.5;4,0.5;changelevel;Change level]"
        )
        return true
    end,
}

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "kingdoms:member" then return false end
    local name = player:get_player_name()
    local kingdom = kingdoms.player.kingdom(name)
    local target = selectedmember[name]
    local state = kingdoms.player.kingdom_state(name)
    local tkingdom = kingdoms.player.kingdom(target)
    local tstate = kingdoms.player.kingdom_state(target)
    if fields.kick then
        if state.level <= tstate.level or not kingdoms.player.can(name, "kick") then
            minetest.chat_send_player(name, "You do not have a sufficient level to kick this player.")
            return formspec_member.func(name)
        end
        minetest.show_formspec(name, "kingdoms:kick", "size[4,3]"
            .."label[0,0;Are you sure you want to kick "..target.." from the kingdom?]"
            .."button[0,1;4,1;yes;Yes]"
            .."button[0,2;4,1;no;No")
    elseif fields.changelevel then
        local level = tonumber(fields.level)
        if not level then
            minetest.chat_send_player(name, "Invalid level.")
            return formspec_member.func(name)
        end
        if not kingdoms.player.can(name, "change_level") or state.level <= tstate.level or level >= state.level then
            minetest.chat_send_player(name, "You do not have a sufficient level to set this player's level to "..tostring(level)..".")
            return formspec_member.func(name)
        end
        tstate.level = level
        return formspec_member.func(name)
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "kingdoms:kick" then return false end
    local name = player:get_player_name()
    local kingdom = kingdoms.player.kingdom(name)
    local state = kingdoms.player.kingdom_state(name)
    local target = selectedmember[name]
    local tkingdom = kingdoms.player.kingdom(target)
    local tstate = kingdoms.player.kingdom_state(target)
    if not kingdoms.player.can(name, "kick") then return true end
    if fields.yes and kingdom and tkingdom and kingdom.id == tkingdom.id and state.level > tstate.level then
        leave_kingdom(target)
        kingdoms.log("action", ("'%s' has been kicked from '%s' by '%s'."):format(target, kingdom.longname, name))
        minetest.chat_send_player(target, "You have been kicked from "..kingdom.longname)
    end
    return kcommand.func(name)
end)

-- The levels formspec, manages the level values of the kingdom.
local formspec_levels
formspec_levels = {
    selected = {},
    possible = kingdoms.possible_levels(),
    func = function(name)
        local kingdom = kingdoms.player.kingdom(name)
        formspec_levels.selected[name] = formspec_levels.possible[1]
        local n = {}
        for _,level in ipairs(formspec_levels.possible) do
            if not kingdom.levels[level] then
                kingdom.levels[level] = kingdoms.config["default_level_"..level]
            end
            table.insert(n, minetest.formspec_escape(("%s - %d (default %d)"):format(level, kingdom.levels[level], kingdoms.config["default_level_"..level])))
        end
        minetest.show_formspec(name, "kingdoms:levels",
            "size[4,5]"
            .."button[0,0;4,1;kingdoms_special_exit;X]"
            .."textlist[0,1;4,4;levels;"..table.concat(n, ",")..";1]"
        )
        return true
    end,
}

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "kingdoms:levels" then return false end
    local name = player:get_player_name()
    local kingdom = kingdoms.player.kingdom(name)

    if fields.levels then
        formspec_levels.selected[name] = formspec_levels.possible[minetest.explode_textlist_event(fields.levels).index]
        if not kingdoms.player.can(name, "set_levels") then
            minetest.chat_send_player(name, "You do not have sufficient level to set levels.")
            return true
        end
        minetest.show_formspec(name, "kingdoms:setlevel", "size[4,3]"
            .."label[0,0;Setting level: "..minetest.formspec_escape(formspec_levels.selected[name]).."]"
            .."field[0.15,1;4,1;value;Value;"..tostring(kingdom.levels[formspec_levels.selected[name]]).."]"
            .."button[0,2;4,1;go;Go]")
        return true
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "kingdoms:setlevel" then return false end
    local name = player:get_player_name()
    local kingdom = kingdoms.player.kingdom(name)
    local state = kingdoms.player.kingdom_state(name)
    local level = formspec_levels.selected[name]
    local oldvalue = kingdom.levels[level]
    local value = tonumber(fields.value)

    if fields.go then
        if oldvalue == value then
            return formspec_levels.func(name)
        end

        if not kingdoms.player.can(name, "set_levels") then
            minetest.chat_send_player(name, "You do not have sufficient level to set levels.")
            return formspec_levels.func(name)
        end
        if value < kingdoms.config.minlevel or value > kingdoms.config.maxlevel then
            minetest.chat_send_player(name, "Invalid level range.")
            return true
        end
        if value > state.level or oldvalue > state.level then
            minetest.chat_send_player(name, "You cannot set that level due to your own level.")
            return true
        end
        kingdom.levels[level] = value
        return formspec_levels.func(name)
    end
end)

-- The info formspec, displays the kingdoms description.
local formspec_info = {
    func = function(name, a)
        local pkingdom = kingdoms.player.kingdom(name)
        local akingdom = a
        if not akingdom then
            akingdom = pkingdom
        end
        local cansave = not a and kingdoms.player.can(name, "set_info") and (pkingdom and pkingdom.id == akingdom.id)
        local s = "size[6,5]"
        if (not a) and cansave then
            s = "size[6,7]"
        elseif (not a) or cansave then
            s = "size[6,6]"
        end
        minetest.show_formspec(name, "kingdoms:info",
            s
            .."label[0,0;"..minetest.formspec_escape(("%s: founded %s ago."):format(akingdom.longname, kingdoms.utils.s("day", math.floor((os.time() - akingdom.created) / 60 / 60 / 24)))).."]"
            .."textarea[0.25,1;6,4;info;Info;"..minetest.formspec_escape(akingdom.info or "").."]"
            ..(cansave and "button[0,5;6,1;save;Save]" or "")
            ..((not a) and (cansave and "button[0,6;6,1;kingdoms_special_exit;X]" or "button[0,5;6,1;kingdoms_special_exit;X]") or "")
        )
        return true
    end,
}
kingdoms.formspec_info = formspec_info

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "kingdoms:info" then return false end
    local name = player:get_player_name()
    local kingdom = kingdoms.player.kingdom(name)

    if fields.save then
        if not kingdoms.player.can(name, "set_info") then
            return true
        end
        kingdom.info = fields.info
        return formspec_info.func(name)
    end
end)

-- The core kingdom formspec, displays the member list and kingdom menu.
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "kingdoms:joined" then return false end
    local name = player:get_player_name()
    local kingdom = kingdoms.player.kingdom(name)
    if fields.menu then
        local m = minetest.explode_textlist_event(fields.menu)
        if not kmenuitems[m.index] then return true end
        local selected = kmenuitems[m.index][1]
        local level = kmenuitems[m.index][3]
        if level and not kingdoms.player.can(name, level) then
            return true
        end
        if selected == "invite" then
            return formspec_invitations.func(name)
        elseif selected == "leave" then
            minetest.show_formspec(name, "kingdoms:leave", "size[4,3]"
                .."label[0,0;Are you sure you want to leave the kingdom?]"
                .."button[0,1;4,1;yes;Yes]"
                .."button[0,2;4,1;no;No")
            return true
        elseif selected == "levels" then
            return formspec_levels.func(name)
        elseif selected == "info" then
            return formspec_info.func(name)
        elseif selected == "rename" then
            minetest.show_formspec(name, "kingdoms:rename", "size[4,2]"
                .."field[0.25,0.2;4,1;name;Kingdom's Name;"..minetest.formspec_escape(kingdom.longname).."]"
                .."button[0,1;4,1;go;Set Name]")
        end
    elseif fields.members then
        selectedmember[name] = kingdom.memberlist[minetest.explode_textlist_event(fields.members).index]
        if not selectedmember[name] then return true end
        return formspec_member.func(name)
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "kingdoms:rename" then return false end
    local name = player:get_player_name()
    local kingdom = kingdoms.player.kingdom(name)
    if fields.go then
        if not kingdoms.player.can(name, "rename") then
            return kcommand.func(name)
        end
        local formattedname = fields.name:gsub("%s%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
        if formattedname == kingdom.longname then
            return kcommand.func(name)
        end
        if formattedname == "" then
            minetest.chat_send_player(name, "You must name your kingdom something.")
            return kcommand.func(name)
        end
        if formattedname:len() > kingdoms.config.max_name_length then
            minetest.chat_send_player(name, "That name is too long.")
            return kcommand.func(name)
        end
        for _,k in pairs(kingdoms.db.kingdoms) do
            if formattedname == k.longname then
                minetest.chat_send_player(name, "There is already a kingdom with that name.")
                return kcommand.func(name)
            end
        end
        kingdom.longname = formattedname
        return kcommand.func(name)
    end
end)

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname ~= "kingdoms:leave" then return false end
    local name = player:get_player_name()
    local kingdom = kingdoms.player.kingdom(name)
    if fields.yes then
        leave_kingdom(name)
        kingdoms.log("action", ("'%s' has left '%s'."):format(name, kingdom.longname))
        minetest.chat_send_player(name, "You are no longer a member of "..kingdom.longname)
    else
        minetest.chat_send_player(name, "You are still a member of "..kingdom.longname)
    end
    return kcommand.func(name)
end)

-- If the formspec has a special <X> button, return to the base formspec when it is pressed.
minetest.register_on_player_receive_fields(function(player, formname, fields)
    if fields.kingdoms_special_exit then
        return kcommand.func(player:get_player_name())
    end
end)
