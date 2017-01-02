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
