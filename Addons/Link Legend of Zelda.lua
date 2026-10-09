    -- thank you Jade and Dilly for the assistance with getting images
local data = NFS.newFileData(Btraddon.path .. "Assets/link.png")
local sprite = love.graphics.newImage(data)
sprite:setFilter("nearest", "nearest")

-- I wanted shorter code >:3
local isDown = love.keyboard.isDown

-- x, y = top left of first frame, w, h = frame size, ox, oy = where Links body sits in the frame
local function NewAnimation(x, y, w, h, frameCount, fps, ox, oy)
    local animation = {}
    for ix=1, frameCount do
        table.insert(animation, love.graphics.newQuad(x + w*(ix-1), y, w, h, sprite))
    end
    animation["Info"] = {
        frames = frameCount,
        rate = fps,
        ox = ox or 0,
        oy = oy or 0,
    }
    return animation
end
local CharAnims = {
    down = NewAnimation(0, 0, 16, 16,    2, 6),
    up = NewAnimation(0, 16, 16, 16,     2, 6),
    right = NewAnimation(0, 32, 16, 16,  2, 6),
    left = NewAnimation(0, 48, 16, 16,   2, 6),
}
local AttackAnims = {
    down = NewAnimation(0, 64, 16, 27,   3, 12),
    up = NewAnimation(0, 91, 16, 28,     3, 12, 0, 14),
    right = NewAnimation(0, 119, 27, 16, 3, 12),
    left = NewAnimation(0, 136, 27, 16,  3, 12, 10),
}
local currentFrame = 1
local animTimer = 0
Btraddon.char = { x = 50, y = 50, speed = 300, facing = "down", attacking = false }
local char = Btraddon.char

local olddraw = love.draw
function love.draw(...)
    olddraw(...)
    if Btraddon.Link then
        local anim = (char.attacking and AttackAnims or CharAnims)[char.facing]
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(sprite, anim[currentFrame], char.x, char.y, 0, 3, 3, anim.Info.ox, anim.Info.oy)
    end
end

    -- tysm to meta and noodle!!!
local oldLPress = Controller.queue_L_cursor_press
function Controller.queue_L_cursor_press(self, ...)
    if Btraddon.Link and not Btraddon.LinkAttack then return end
    oldLPress(self, ...)
end
local oldLRelease = Controller.L_cursor_release
function Controller.L_cursor_release(self, ...)
    if Btraddon.Link and not Btraddon.LinkAttack then return end
    Btraddon.LinkAttack = nil
    oldLRelease(self, ...)
end


-- LastDirectionx/y
local ldx, ldy = 0, 1
local lastAttack = 0
-- link animating and controls
local oldupd = love.update
function love.update(dt, ...)
    oldupd(dt, ...)
    if not Btraddon.Link and Btraddon.config.link then
        -- spawning at the middle
        Btraddon.Link = true
        
        windowWidth, windowHeight = love.graphics.getDimensions()
        char.x = windowWidth /2
        char.y = windowHeight /2
    end
    -- copy
    Btraddon.Link = Btraddon.config.link
    if not Btraddon.Link then love.mouse.setVisible(true) return end
    love.mouse.setVisible(false)

-- MOVEMENT
    -- check whats pressed
    local dx = (isDown("right", "d") and 1 or 0) - (isDown("left", "a") and 1 or 0)
    local dy = (isDown("down", "s") and 1 or 0) - (isDown("up", "w") and 1 or 0)

    -- stand still while swinging
    if char.attacking then dx, dy = 0, 0 end
    local animate = dx ~= 0 or dy ~= 0

    -- use last Direction if attempting to move diagonally
    if dx ~= 0 and dy ~= 0 then
        dx, dy = ldx, ldy
    end
    if animate then ldx, ldy = dx, dy end

    -- move char
    char.x = char.x + dx * char.speed * dt
    char.y = char.y + dy * char.speed * dt

-- set mouse pos
    if love.window.hasMouseFocus() then
        love.mouse.setPosition(char.x + 24 + ldx * 48, char.y + 24 + ldy * 48)
    end
-- ATTACK
    local attacking = isDown("return", "x")
    if attacking and not char.attacking and love.timer.getTime() - lastAttack > .5 then
        Btraddon.LinkAttack = true
        G.CONTROLLER:queue_L_cursor_press()
        G.CONTROLLER:L_cursor_release()
        lastAttack = love.timer.getTime()

        char.attacking = true
        char.facing = ldx ~= 0 and (ldx > 0 and "right" or "left") or (ldy > 0 and "down" or "up")
        currentFrame = 1
        animTimer = 0
    end

-- ANIMATIONS
    if char.attacking then
        local info = AttackAnims[char.facing].Info
        local frameTime = 1 / info.rate
        animTimer = animTimer + dt
        while char.attacking and animTimer >= frameTime do
            animTimer = animTimer - frameTime
            if currentFrame < info.frames then
                currentFrame = currentFrame + 1
            else
                char.attacking = false
                currentFrame = 1
                animTimer = 0
            end
        end
        return
    end

    if not animate then return end

    -- set facing
    local oldfacing = char.facing
    char.facing = dx ~= 0 and (dx > 0 and "right" or "left") or (dy > 0 and "down" or "up")
    if char.facing ~= oldfacing then
        currentFrame = 1
        animTimer = 0
    end

    local info = CharAnims[char.facing].Info
    local frameTime = 1 / info.rate
    animTimer = animTimer + dt
    while animTimer >= frameTime do
        animTimer = animTimer - frameTime
        currentFrame = currentFrame % info.frames + 1
        -- ouuu look at me with my modulo
    end
end