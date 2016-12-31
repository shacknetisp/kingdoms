kingdoms.utils = {}
        
-- Return a UUID-like identifier.
function kingdoms.utils.uniqueid()
    s = ("%x"):format(math.random(0, 0xFFFF))
    for i=2,10 do
        s = s .. ("-%x"):format(math.random(0, 0xFFFF))
    end
    return s
end
