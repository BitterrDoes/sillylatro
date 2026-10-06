local function changewords(str)
    if not str then return str end
    if type(str) == "table" then
        local new = {}
        for k, v in ipairs(str) do
            new[k] = changewords(v)
        end
        return new
    end
    local out = {}
    local i = 1
    local len = #str
    while i <= len do
        local c = str:sub(i,i)
        if c == "{" then
            local close = str:find("}", i)
            if close then
                table.insert(out, str:sub(i, close))
                i = close + 1
            else
                table.insert(out, c)
                i = i + 1
            end
        -- Skip the letter 'a' (both uppercase and lowercase)
        elseif c == "a" or c == "A" then
            i = i + 1
        else
            table.insert(out, c)
            i = i + 1
        end
    end
    return table.concat(out)
end

local function process_localization(tbl)
    if type(tbl) ~= "table" then return end
    
    for k, v in pairs(tbl) do
        if type(v) == "string" then
            tbl[k] = changewords(v)
        elseif type(v) == "table" then
            -- Check if it's a table
            local table = false
            if #v > 0 then
                table = true
                for i = 1, #v do
                    if type(v[i]) == "string" then
                        v[i] = changewords(v[i])
                    end
                end
            end
            
            -- If its not a table then process it
            if not table then
                process_localization(v)
            end
        end
    end
end

local old = init_localization
function init_localization(...)
    process_localization(G.localization)
    return old(...)
end