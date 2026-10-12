local B = Btraddon

    -- util functions
function B.isSnake(x, y)
    for _, s in ipairs(B.snake) do
        if s.x == x and s.y == y then return true end
    end
    return false
end

function B.isApple(x, y)
    for _, a in ipairs(B.apples) do
        if a.x == x and a.y == y then return true end
    end
    return false
end

function B.spawnApple()
    local x, y = love.math.random(3, B.cols - 6), love.math.random(3, B.rows - 6)
    if not B.isSnake(x, y) and not B.isApple(x, y) then
        B.apples[#B.apples + 1] = { x = x, y = y }
        return
    else
        B.spawnApple()
    end
end

function B.reset()
    local cx, cy = math.floor(B.cols / 2), math.floor(B.rows / 2)
    B.snake = {
        { x = cx, y = cy },
        { x = cx, y = cy + 1 },
    }
    B.dir = { x = 0, y = -1 }
    B.dirQueue = {}
    B.apples = {}
        -- 3 apples
    for _ = 1, 3 do B.spawnApple() end
    B.score = 0
    B.timer = 0
    B.state = "ready"
end

    -- logic functions
function B.die()
    B.state = "dead"
    B.trauma = 1
    love.audio.play(B.sfx.death, B.sfx.sand)
    if B.score > B.best then
        B.best = B.score
        B.config.snekbest = B.best
    end
end

function B.step()
    if #B.dirQueue > 0 then B.dir = table.remove(B.dirQueue, 1) end

    local head = B.snake[1]
    local nx, ny = head.x + B.dir.x, head.y + B.dir.y
        -- next pos

    if nx < 0 or nx >= B.cols or ny < 0 or ny >= B.rows then
        return B.die()
    end

    -- eating
    local eaten
    for i, a in ipairs(B.apples) do
        if a.x == nx and a.y == ny then eaten = i break end
    end

    -- tail will move away unless we grow
    local tailLimit = eaten and #B.snake or #B.snake - 1
    for i = 1, tailLimit do
        if B.snake[i].x == nx and B.snake[i].y == ny then return B.die() end
    end

    table.insert(B.snake, 1, { x = nx, y = ny })
    if eaten then   -- lands on apple
        table.remove(B.apples, eaten)
        B.score = B.score + 1
        B.trauma = math.min(1, B.trauma + 0.3)
        love.audio.play(B.sfx.collect)
        B.spawnApple()
    else
        table.remove(B.snake)
    end
end

function B.turn(dx, dy)
    local last = B.dirQueue[#B.dirQueue] or B.dir
    if B.state == "ready" then B.state = "playing" end
    if last.x == -dx and last.y == -dy then return end   -- no reversing
    if last.x == dx and last.y == dy then return end
    if #B.dirQueue < 3 then B.dirQueue[#B.dirQueue + 1] = { x = dx, y = dy } end
end