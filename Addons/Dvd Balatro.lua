--- NAME: DVD Balatro
--- AUTHOR: [BitterDoes]
--- DESCRIPTION: Haha dvd logo, can cause headaches

local windowX, windowY
local velocityX, velocityY
local speed = .5
local windowWidth, windowHeight
local screenWidth, screenHeight

local init = false

windowWidth, windowHeight = love.graphics.getDimensions()
screenWidth, screenHeight = love.window.getDesktopDimensions(1)
windowX = (screenWidth - windowWidth) / 2
windowY = (screenHeight - windowHeight) / 2
velocityX = speed
velocityY = speed

if Btraddon.config.dvd then
    love.window.setPosition(windowX, windowY, 1)
end

local old_update = love.update
function love.update(dt, ...)
    old_update(dt, ...)
    
    if not Btraddon.config.dvd or not windowX then init = false return end
    if not init then
        init = true
        local newWidth = screenWidth / 2
        local newHeight = screenHeight / 2
        love.window.setMode(newWidth, newHeight)
        love.resize(newWidth, newHeight)
        windowWidth, windowHeight = newWidth, newHeight
    end
    windowWidth, windowHeight = love.graphics.getDimensions()
    screenWidth, screenHeight = love.window.getDesktopDimensions(1)
    
    windowX = windowX + velocityX
    windowY = windowY + velocityY
    
    if windowX <= 0 or windowX + windowWidth >= screenWidth then
        velocityX = -velocityX
        windowX = math.max(0, math.min(windowX, screenWidth - windowWidth))
    end
    
    if windowY <= 0 or windowY + windowHeight >= screenHeight then
        velocityY = -velocityY
        windowY = math.max(0, math.min(windowY, screenHeight - windowHeight))
    end
    
    love.window.setPosition(math.floor(windowX), math.floor(windowY), 1)
end