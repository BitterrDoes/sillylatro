local B = Btraddon

    -- camera with shakin stuff, drift and following the snake
function B.updateCamera(dt)
    local t0 = B.crtTime

    -- shake, noise so its not jittery
    B.trauma = math.max(0, B.trauma - dt * 1.5)
    local s = B.trauma * B.trauma
    local t = t0 * 400
    local shakeX = (love.math.noise(t, 1) * 2 - 1) * B.shakeMove * s
    local shakeY = (love.math.noise(t, 2) * 2 - 1) * B.shakeMove * s
    local shakeA = (love.math.noise(t, 3) * 2 - 1) * B.shakeRot * s

    -- drift
    local swayX = math.sin(t0 * 0.5) * 5 + math.sin(t0 * 0.23) * 4
    local swayY = math.cos(t0 * 0.41) * 4
    local swayA = math.sin(t0 * 0.3) * 0.003

    -- follow the head a bit
    local head = B.snake[1]
    local tx = -(head.x * B.cell + B.cell / 2 - B.W / 2) * B.followAmt
    local ty = -(head.y * B.cell + B.cell / 2 - B.H / 2) * B.followAmt
    local k = math.min(1, dt * 2.5)
    B.followX = B.followX + (tx - B.followX) * k
    B.followY = B.followY + (ty - B.followY) * k

    B.camX = B.followX + swayX + shakeX
    B.camY = B.followY + swayY + shakeY
    B.camRot = swayA + shakeA
end

local cgameMem = nil
local oldUpd = love.update
function love.update(dt)
    if B.currentGame ~= "snek" then cgameMem = B.currentGame return oldUpd(dt) end
    if cgameMem ~= "snek" then
        B.reset()
        cgameMem = B.currentGame
    end
    B.crtTime = B.crtTime + dt  -- seperate from other timer
    B.updateCamera(dt)
    if B.state ~= "playing" then return end
    B.timer = B.timer + dt
    local speed = 0.075 - (B.score * 0.001)
    while B.timer >= speed and B.state == "playing" do
        B.timer = B.timer - speed
        B.step()
    end
end

local oldDraw = love.draw
function love.draw()
    if B.currentGame ~= "snek" then return oldDraw() end
    if cgameMem ~= "snek" then
        B.reset()
        cgameMem = "snek"
    end
    local W, H, cell, cols, rows = B.W, B.H, B.cell, B.cols, B.rows
    local col_BG, COLOR_GRID = B.col_BG, B.COLOR_GRID
    local snake, apples, state, score, best = B.snake, B.apples, B.state, B.score, B.best
    local canvas, half, ping, pong, final = B.canvas, B.half, B.ping, B.pong, B.final

    -- draw the scene onto the canvas first, the shader needs something to blur
    love.graphics.setCanvas(canvas)

    -- background
    love.graphics.setColor(col_BG)
    love.graphics.rectangle("fill", 0, 0, W, H)

    -- grid
    love.graphics.setColor(COLOR_GRID)
    love.graphics.setLineWidth(1)
    for x = 0, cols do
        love.graphics.line(x * cell + 0.5, 0, x * cell + 0.5, H)
    end
    for y = 0, rows do
        love.graphics.line(0, y * cell + 0.5, W, y * cell + 0.5)
    end

    -- apples
    love.graphics.setColor(1, 1, 1, 1)
    for _, a in ipairs(apples) do
        love.graphics.rectangle("fill", a.x * cell + 2, a.y * cell + 2, cell - 3, cell - 3)
    end

    -- make it slowly fade, trust the vision
    -- (kinda fake transparency for the shader)
    local n = #snake
    for i, s in ipairs(snake) do
        local t = (i - 1) / math.max(n - 1, 1)
        local a = 1 - t * 0.65
        love.graphics.setColor(
            col_BG[1] + (1 - col_BG[1]) * a,
            col_BG[2] + (1 - col_BG[2]) * a,
            col_BG[3] + (1 - col_BG[3]) * a, 1)
        love.graphics.rectangle("fill", s.x * cell + 1, s.y * cell + 1, cell - 1, cell - 1)
    end

    love.graphics.setCanvas()

    -- bloom: shrink, bright pass + blur h/v a couple times, then add it back on top
    B.shrink(canvas, half)
    B.shrink(half, ping)
    for i = 1, B.glowPasses do
        local last = (i == B.glowPasses)
        B.blurPass(ping, pong, 1, 0, i == 1 and B.glowThreshold or 0, 1)
        B.blurPass(pong, ping, 0, 1, 0, last and B.glowGain or 1)
    end

    -- put everything on one canvas (scene + glow + ui) so the crt hits all of it
    love.graphics.setCanvas(final)
    love.graphics.clear(0, 0, 0, 1)

    -- camera, ui is after the pop so it stays still
    love.graphics.push()
    love.graphics.translate(W / 2 + B.camX, H / 2 + B.camY)
    love.graphics.rotate(B.camRot)
    love.graphics.translate(-W / 2, -H / 2)

    -- grid keeps going past the edges so theres no black when it moves
    local pad = cell * 7
    love.graphics.setColor(col_BG)
    love.graphics.rectangle("fill", -pad, -pad, W + pad * 2, H + pad * 2)
    love.graphics.setColor(COLOR_GRID)
    for x = -7, cols + 7 do
        love.graphics.line(x * cell + 0.5, -pad, x * cell + 0.5, H + pad)
    end
    for y = -7, rows + 7 do
        love.graphics.line(-pad, y * cell + 0.5, W + pad, y * cell + 0.5)
    end
    love.graphics.setColor(0, 0, 0, 0.35)
    love.graphics.rectangle("fill", -pad, -pad, W + pad * 2, H + pad * 2)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(canvas)
    love.graphics.setBlendMode("add")
    love.graphics.draw(ping, 0, 0, 0, W / ping:getWidth(), H / ping:getHeight())
    love.graphics.setBlendMode("alpha")
    love.graphics.pop()

    -- my very simple ui
    love.graphics.setFont(B.font)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Highscore: " .. (best > 0 and best or "-"), 6, 4 + 26)
    love.graphics.print("Score: " .. score, 6, 4 + 52)

    -- overlays
    local function center(text, y, f)
        love.graphics.setFont(f)
        love.graphics.printf(text, 0, y, W, "center")
    end
    if state == "ready" then
        love.graphics.setColor(1, 1, 1, 0.85)
        center("Arrow keys / WASD to start     esc to return to balatro", H / 2 + 120, B.font)
    elseif state == "paused" then
        love.graphics.setColor(1, 1, 1, 0.9)
        center("Paused", H / 2 - 40, B.bigFont)
    elseif state == "dead" then
        love.graphics.setColor(0, 0, 0, 0.35)
        love.graphics.rectangle("fill", 0, 0, W, H)
        love.graphics.setColor(1, 1, 1, 1)
        center("Game Over", H / 2 - 70, B.bigFont)
        center("Score " .. score .. "   Best " .. best .. "   -  Enter / R to restart", H / 2 + 10, B.font)
    end

    love.graphics.setCanvas()

    -- scale to window
    local ww, wh = love.graphics.getDimensions()
    local sc = math.min(ww / W, wh / H)
    local ox, oy = (ww - W * sc) / 2, (wh - H * sc) / 2
    love.graphics.clear(0, 0, 0)
    love.graphics.push()
    love.graphics.translate(ox, oy)
    love.graphics.scale(sc)
    love.graphics.setScissor(ox, oy, W * sc, H * sc) -- makes work on any size

    -- crt
    B.crtPass(W, H)
    love.graphics.setShader(B.shaders.crt)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(final)
    love.graphics.setShader()

    love.graphics.setScissor() -- reset
    love.graphics.pop()
end