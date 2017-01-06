kingdoms.utils = {}

-- Return a UUID-like identifier.
function kingdoms.utils.uniqueid()
    local s = ("%x"):format(math.random(0, 0xFFFF))
    for i=2,4 do
        s = s .. ("-%x"):format(math.random(0, 0xFFFF))
    end
    return s
end

function kingdoms.utils.s(label, number, s)
    if number == 1 then
        return ("%d %s"):format(number, label)
    else
        return ("%d %s%s"):format(number, label, s or "s")
    end
end

-- Copy and return numeric-indexed table with only those entries matching <func>.
function kingdoms.utils.filteri(table, func)
    local ret = {}
    local i = 1
    for _,v in ipairs(table) do
        if func(v) then
            ret[i] = v
            i = i + 1
        end
    end
    return ret
end

function kingdoms.utils.table_len(t)
    local ret = 0
    for _,_ in pairs(t) do
        ret = ret + 1
    end
    return ret
end

function kingdoms.utils.spairs(t, order)
    local keys = {}
    for k in pairs(t) do keys[#keys+1] = k end
    if order then
        table.sort(keys, function(a,b) return order(t, a, b) end)
    else
        table.sort(keys)
    end
    local i = 0
    return function()
        i = i + 1
        if keys[i] then
            return keys[i], t[keys[i]]
        end
    end
end

function kingdoms.utils.probability_list(t)
    local ret = {}
    for k,v in pairs(t) do
        for i=1,v do
            table.insert(ret, k)
        end
    end
    return ret
end

function kingdoms.utils.find_nodes_by_area(pos, r, names)
    return minetest.find_nodes_in_area({x = pos.x - r, y = pos.y - r, z = pos.z - r}, {x = pos.x + r, y = pos.y + r, z = pos.z + r}, names)
end

function kingdoms.utils.find_nodes_by_area_under_air(pos, r, names)
    return minetest.find_nodes_in_area_under_air({x = pos.x - r, y = pos.y - r, z = pos.z - r}, {x = pos.x + r, y = pos.y + r, z = pos.z + r}, names)
end

function kingdoms.utils.shuffled(t_in)
    local t = table.copy(t_in)
    local ret = {}
    while #t > 0 do
        local index = math.random(1, #t)
        table.insert(ret, t[index])
        table.remove(t, index)
    end
    return ret
end
