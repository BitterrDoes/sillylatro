local function changewords(str)
    if not str then return str end

    -- Some joker descriptions use tables for multi-line text
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
        local c = str:sub(i,i)  -- FIX: read ONE character

        -- Tag start?
        if c == "{" then
            local close = str:find("}", i)
            if close then
                table.insert(out, str:sub(i, close))
                i = close + 1
            else
                table.insert(out, c)
                i = i + 1
            end

        -- Start of a word
        elseif c:match("%a") then
            table.insert(out, "j")
            i = i + 1

            while i <= len and str:sub(i,i):match("%a") do
                table.insert(out, str:sub(i,i))
                i = i + 1
            end

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
            -- Check if it's an array-like table (for multi-line text)
            local is_array = false
            if #v > 0 then
                is_array = true
                for i = 1, #v do
                    if type(v[i]) == "string" then
                        v[i] = changewords(v[i])
                    end
                end
            end
            
            -- If not processed as array, recurse into the table
            if not is_array then
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