local B = Btraddon

B.W, B.H = 1920, 1080
B.cell = 24
B.cols, B.rows = math.floor(B.W / B.cell), math.floor(B.H / B.cell)  -- 80 x 45

local nfd = NFS.newFileData

B.sfx = {
    sand = love.audio.newSource(nfd(B.path.. 'Assets/sfx/sand.wav'), 'static'),
    death = love.audio.newSource(nfd(B.path.. 'Assets/sfx/Death.wav'), 'static'),
    collect = love.audio.newSource(nfd(B.path.. 'Assets/sfx/Collect.wav'), 'static'),
}
B.shaders = {
    bloom = love.graphics.newShader(nfd(B.path .. 'Assets/shaders/Bloom.glsl'):getString()), -- probably doing this awfully
    crt = love.graphics.newShader(nfd(B.path .. 'Assets/shaders/CRT.glsl'):getString()),
}

B.col_BG   = { 0.18, 0.12, 0.23 }
B.COLOR_GRID = { 0,0,0, .3 }

-- game state
B.score, B.best, B.timer = 0, 0, 0
B.state = "ready"            -- "ready" | "playing" | "paused" | "dead"
B.glowSigma, B.glowThreshold, B.glowGain, B.glowPasses = 35, 0.55, 9.0, 4
B.crtTime = 0

-- camera stuff
B.trauma = 0.3                    -- shake strength, 0 - 1
B.shakeMove, B.shakeRot = 28, 0.065
B.followAmt = 0.03              -- lean toward the head, keep it low
B.followX, B.followY = 0, 0
B.camX, B.camY, B.camRot = 0, 0, 0

-- load files
Btraddon.Load_file("ReqSrc/snek-util.lua")
Btraddon.Load_file("ReqSrc/snek-upd.lua")

-- require('util')
-- require('upd')

    -- shader helper functions
function B.send(shader, name, ...)
    if shader:hasUniform(name) then shader:send(name, ...) end
end

function B.blurPass(src, dst, dx, dy, threshold, gain)
    love.graphics.setCanvas(dst)
    love.graphics.clear(0, 0, 0, 1)
    local shad = B.shaders.bloom

    love.graphics.setShader(shad)
    B.send(shad, "direction", { dx / src:getWidth(), dy / src:getHeight() })
    B.send(shad, "threshold", threshold)
    B.send(shad, "gain", gain)
    love.graphics.setBlendMode("replace")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(src)
    love.graphics.setBlendMode("alpha")
    love.graphics.setShader()
    love.graphics.setCanvas()
end

-- w, h = size of the canvas going through it
function B.crtPass(w, h)
    local s = B.shaders.crt
    local head = B.snake[1]
    B.send(s, 'distortion_fac', {1.03, 1.01})
    B.send(s, 'scale_fac', {1.0 + 0.018, 1.0 + 0.018})
    B.send(s, 'feather_fac', 0.01)
    B.send(s, 'bloom_fac', .5)
    B.send(s, 'time', B.crtTime)
    B.send(s, 'noise_fac', 0.005)
    B.send(s, 'glitch_intensity', 0.)
    B.send(s, 'crt_intensity', 0.1)
    B.send(s, 'scanlines', h * 0.75)
    -- head pos for the crt, pixels not cells
    B.send(s, 'mouse_screen_pos', { head.x * B.cell + B.cell / 2, head.y * B.cell + B.cell / 2 })
    B.send(s, 'screen_scale', B.cell * 3)
    B.send(s, 'hovering', 0)
end

function B.shrink(src, dst)
    love.graphics.setCanvas(dst)
    love.graphics.setBlendMode("replace")
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(src, 0, 0, 0, dst:getWidth() / src:getWidth(), dst:getHeight() / src:getHeight())
    love.graphics.setBlendMode("alpha")
    love.graphics.setCanvas()
end

        -- Love functions

    -- fyi this used to be love.load
love.audio.setVolume(1)
love.math.setRandomSeed(os.time())
B.font = love.graphics.newFont(22)
B.bigFont = love.graphics.newFont(56)
B.best = B.config.snekbest

-- shader stuff
local W, H = B.W, B.H
local fmt = love.graphics.getCanvasFormats()["rgba16f"] and "rgba16f" or "rgba8"
B.canvas = love.graphics.newCanvas(W, H)
B.final = love.graphics.newCanvas(W, H)
B.half = love.graphics.newCanvas(W / 2, H / 2, { format = fmt })
B.ping = love.graphics.newCanvas(W / 4, H / 4, { format = fmt })
B.pong = love.graphics.newCanvas(W / 4, H / 4, { format = fmt })
B.send(B.shaders.bloom, "sigma", B.glowSigma)

local oldKeyPress = love.keypressed
function love.keypressed(key)
    if B.currentGame ~= "snek" then return oldKeyPress(key) end
    if key == "up" or key == "w" then B.turn(0, -1)
    elseif key == "down" or key == "s" then B.turn(0, 1)
    elseif key == "left" or key == "a" then B.turn(-1, 0)
    elseif key == "right" or key == "d" then B.turn(1, 0)
    elseif (key == "r" and love.keyboard.isDown("lalt")) or (key == "lalt" and love.keyboard.isDown("r")) then -- hard-restart
        SMODS.restart_game()
    elseif key == "r" or (key == "return" and B.state == "dead") then B.reset()
    elseif key == "escape" then
        B.currentGame = nil
    end
end