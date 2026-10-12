-- variables
Btraddon = SMODS.current_mod
Btraddon.currentGame = nil
Btraddon.configClone = {}
for i, v in pairs(Btraddon.config) do
    Btraddon.configClone[i] = v
end
        -- Probably best to do it like this so you cant load in with link

-- load functions
function Btraddon.Load_file(file) -- basically just SMODS.load_file() but safer, so i can accidentally have somethign break and it be chill
	local chunk = SMODS.load_file(file, "btr_addons")
	if chunk then
		local ok, func = pcall(chunk)
		if ok then
			print("Sillylatro! | loaded ".. file)
			return func
		else
			print("Sillylatro! | Failed loading ".. file, " : ", func)
            print("Sillylatro! | Report this to the developer!!")
		end
	end
	return nil
end

function Btraddon.Load_Dir(directory) -- recursive
	local files = NFS.getDirectoryItems(Btraddon.path .. "/" .. directory)

	for _, filename in ipairs(files) do -- iterate over all files in the directory
		local file_path = directory .. "/" .. filename
		if file_path:match(".lua$") then -- check if its lua
			Btraddon.Load_file(file_path) -- load lua file not file_path:find("%.") then
			Btraddon.Load_Dir(directory.. "/".. filename)
		elseif not file_path:find("%.") then
			Btraddon.Load_Dir(directory.. "/".. filename)
		end
	end
end

-- load
Btraddon.Load_Dir("src")
for _, file in pairs(NFS.getDirectoryItems(Btraddon.path.. "Assets/1x/Icons")) do
    local k = string.sub(file, 0, string.find(file, ".png")-1)
    SMODS.Atlas {
        key = k,
        path = "Icons/".. file,
        px = 96,
        py = 96,
    }
end

-- Playground
--[[
local data = NFS.newFileData(Btraddon.path .. "Assets/link.png")
local sprite = love.graphics.newImage(data)
sprite:setFilter("nearest", "nearest")

Btraddon.EvilCharacter = {
    pos = {
        x = 50, y = 50, -- current pos
        vx = 0, vy = 0, -- velocity
        tx = 0, ty = 0, -- end pos

        og_posx = 0, og_posy = 0,
        og_dist = 0
    },
    speed   = 300,
    facing  = "down",
    action  = false,
    moving  = false,
    busy    = false
}
    -- Util funcs
function walktopoint(target_x, target_y)
    local c = Btraddon.EvilCharacter
                c.busy = false -- because once wasnt enough ??
    local p = c.pos

    local w, h = love.graphics.getDimensions()
    target_x = target_x or math.btr_clamp(p.x + math.random(-w, w) / 3, 64, w - 64)
    target_y = target_y or math.btr_clamp(p.y + math.random(-h, h) / 2.5, 64, h - 64)
        -- this is cool as I can have JUST random x or JUST random y !!

    -- remember where we started and where we're going
    p.og_posx, p.og_posy = p.x, p.y
    p.tx, p.ty = target_x, target_y

    -- omg guys pythag !! i love pythag !!
    p.og_dist = (target_x - p.x)^2 + (target_y - p.y)^2
    if p.og_dist == 0 then
        p.vx, p.vy = 0, 0 -- avoid 0 and bignums
    else
        local dist = math.sqrt(p.og_dist)
        p.vx = (target_x - p.x) / dist * c.speed
        p.vy = (target_y - p.y) / dist * c.speed
        c.moving = true
    end
end
function walkOut()
    
end

local oldupd = love.update
function love.update(dt, ...)
    oldupd(dt, ...)
    local c = Btraddon.EvilCharacter
    local p = c.pos

    if c.moving and not c.busy then
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt

        -- overshoot check (squared distance, no sqrt)
        local dist = (p.og_posx - p.x)^2 + (p.og_posy - p.y)^2
        if dist >= p.og_dist then
            p.x, p.y = p.tx, p.ty
            p.vx, p.vy = 0, 0
            p.og_dist = 0
            c.moving = false
        end
    elseif not c.busy then
        c.busy = true
        G.E_MANAGER:add_event(Event({
            trigger = 'after',
            blocking = false,
            blockable = false,
            delay = math.random(2,15)/10,
            func = function()
                c.busy = false
                walktopoint()
                return true
            end
        }))
    end
end

local olddraw = love.draw
function love.draw(...)
    olddraw(...)
    local c = Btraddon.EvilCharacter
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.rectangle("line", c.pos.x-0.5, c.pos.y-0.5, 15, 15)
end
--]]