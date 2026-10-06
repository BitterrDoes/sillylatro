local function changewords(str)
    if not str then return str end
    if type(str) == "table" then
        local new = {}
        for k, v in ipairs(str) do
            new[k] = changewords(v)
        end
        return new
    end
    
    -- Collect all letters and their positions
    local letters = {}
    local structure = {}
    local i = 1
    local len = #str
    
    while i <= len do
        local c = str:sub(i,i)
        if c == "{" then
            local close = str:find("}", i)
            if close then
                table.insert(structure, {type = "tag", value = str:sub(i, close)})
                i = close + 1
            else
                table.insert(structure, {type = "tag", value = c})
                i = i + 1
            end
        elseif c:match("%a") then
            table.insert(letters, c)
            table.insert(structure, {type = "letter"})
            i = i + 1
        else
            table.insert(structure, {type = "other", value = c})
            i = i + 1
        end
    end
    
    -- Sort all letters
    table.sort(letters, function(a, b)
        return a:lower() < b:lower()
    end)
    
    -- Rebuild string with sorted letters
    local out = {}
    local letter_idx = 1
    for _, item in ipairs(structure) do
        if item.type == "letter" then
            table.insert(out, letters[letter_idx])
            letter_idx = letter_idx + 1
        else
            table.insert(out, item.value)
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
            -- Check if it's an array
            local is_array = false
            if #v > 0 then
                is_array = true
                for i = 1, #v do
                    if type(v[i]) == "string" then
                        v[i] = changewords(v[i])
                    end
                end
            end
            
            -- If it's not an array then process it recursively
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