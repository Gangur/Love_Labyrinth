require "world"
require "player"
require "pqueue"
require "maze"

function loadTextures()
    env = {}
    env.tileset = love.graphics.newImage("assets/RogueEnvironment16x16.png")

    map = {{}}

    local quads = {
        {0,  5*16,  0*16}, -- floor v1
        {1,  6*16,  0*16}, -- floor v2
        {2,  7*16,  0*16}, -- floor v3
        {3,  0*16,  0*16}, -- upper left corner
        {4,  3*16,  0*16}, -- upper right corner
        {5,  0*16,  3*16}, -- lower left corner
        {6,  3*16,  3*16}, -- lower right corner
        {7,  2*16,  0*16}, -- horizontal
        {8,  0*16,  2*16}, -- vertical
        {9,  1*16,  2*16}, -- up
        {10, 2*16,  3*16}, -- down
        {11, 2*16,  1*16}, -- left
        {12, 1*16,  1*16}, -- right
        {13, 2*16,  2*16}, -- down cross
        {14, 1*16,  3*16}, -- up cross
        {15, 3*16,  1*16}, -- left cross
        {16, 0*16,  1*16}, -- right cross
        {17, 3*16, 14*16}, -- spikes
        {18, 5*16, 13*16} -- coin
    }
    env.textures = {}
    for i = 1, #quads do
        local q = quads[i]
        env.textures[q[1]] = love.graphics.newQuad(q[2], q[3], 16, 16, env.tileset:getDimensions())
    end

    pl = {}
    pl.tileset = love.graphics.newImage("assets/RoguePlayer_48x48.png")
    pl.textures = {}
    for i = 1, 6 do
        pl.textures[i] = love.graphics.newQuad((i - 1) * 48, 48 * 2, 48, 48, pl.tileset:getDimensions())
    end

end

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()
    loadTextures()

    world = World:create()
    scaleX = width / (world.width * 16)
    scaleY = height / (world.height * 16)

    world:placeObjects()
    player = world.player

-- Place code here
    local len = 31
    for i = 1, len do
        map[i] = {}
        for j = 1, len do
            map[i][j] = "*"
        end
    end
    COUNT = 0
end

function PrintMap()
    for i = 1, #map do
        for j = 1, #map do
            io.write(" "..map[j][i])
        end
        io.write('\n')
    end
    io.write('\n')
end

function WriteToMap(x,y, env)
    map[x][y] = " "

    if not(env.left) then
        if map[x-1][y] ~= " " then
            map[x-1][y] = "0"
        end
    else
        map[x-1][y] = "#"
    end

    if not(env.right) then
        if map[x+1][y] ~= " " then
            map[x+1][y] = "0"
        end
    else
        map[x+1][y] = "#"
    end

    if not(env.up) then
        if map[x][y-1] ~= " " then
            map[x][y-1] = "0"
        end
    else
        map[x][y-1] = "#"
    end

    if not(env.down) then
        if map[x][y+1] ~= " " then
            map[x][y+1] = "0"
        end
    else
        map[x][y+1] = "#"
    end
end

function step(x0,y0 ,x, y, env)
    if y0 > y then
        if x0 > x then
            if map[x0 -1][y0] == " " then
                x0 = x0 - 1
            elseif map[x0][y0 - 1] == " " then
                y0 = y0 - 1
            elseif map[x0 + 1][y0] == " " then
                x0 = x0 + 1
            elseif map[x0][y0 + 1] == " " then
                y0 = y0 + 1
            end
        else
            if map[x0 +1][y0] == " " then
                x0 = x0 + 1
            elseif map[x0][y0 - 1] == " " then
                y0 = y0 - 1
            elseif map[x0 - 1][y0] == " " then
                x0 = x0 - 1
            elseif map[x0][y0 + 1] == " " then
                y0 = y0 + 1
            end
        end
    else
        if x0 > x then
            if map[x0 -1][y0] == " " then
                x0 = x0 - 1
            elseif map[x0][y0 + 1] == " " then
                y0 = y0 + 1
            elseif map[x0 + 1][y0] == " " then
                x0 = x0 + 1
            elseif map[x0][y0 - 1] == " " then
                y0 = y0 - 1
            end
        else
            if map[x0 +1][y0] == " " then
                x0 = x0 + 1
            elseif map[x0][y0 + 1] == " " then
                y0 = y0 + 1
            elseif map[x0 - 1][y0] == " " then
                x0 = x0 - 1
            elseif map[x0][y0 - 1] == " " then
                y0 = y0 - 1
            end
        end
    end
    
    if COUNT == 150 then
        return
    end

    if x0 == x and y0 == y then
        map[x0][y0] = " "
        COUNT = 0
    else
        map[x0][y0] = "0"
        COUNT = COUNT + 1
        step(x0,y0 ,x, y, env)
    end
end

function BuildReturnRoute(x, y, env)
    local available = {{}}
    available[1] = { 9999, 0, 0}
    for i = 1, #map do
        for j = 1, #map do
            if map[i][j] == "0" then
                local dx = math.abs(x - i) 
                local dy = math.abs(y - j) 
                available[#available+1] = {math.sqrt(dx*dx+dy+dy), i, j}
            end
        end
    end

    local min = { 9999, 0, 0}
    for i = 1, #available do
        if min[1] > available[i][1] then
            min = available[i]
        end
    end

    local x0 = min[2]
    local y0 = min[3]

    step(x0,y0 ,x, y, env)
    PrintMap()
    --print(x0.." "..y0.." - "..x.." "..y)
    --PrintMap()
end

function love.update(dt)
    player:update(dt, world)
    world:update(player)
    seek(world:getEnv())
end

function seek(env)
    local x = env.position[1]+1
    local y = env.position[2]+1
    WriteToMap(x, y, env)

    
    if map[x - 1][y] == "0" then
        world:move("left")
    elseif map[x][y-1] == "0" then
        world:move("up")
    elseif map[x + 1][y] == "0" then
        world:move("right")
    elseif map[x][y+1] == "0" then
        world:move("down")
    else
        BuildReturnRoute(x, y, env)
    end
    --world:move(directions[love.math.random(1, #directions)])

    --if not(env.left) then
    --    world:move("left")
    --elseif not(env.up) then
    --    world:move("up")
    --elseif not(env.down) then
    --    world:move("down")
    --else
    --    world:move("right")
    --end
end

function love.draw()
    love.graphics.scale(scaleX, scaleY)
    world:draw()
    player:draw(world)
end


function love.keypressed(key)
    if key == "left" then
        world:move("left")
    end
    if key == "right" then
        world:move("right")
    end
    if key == "up" then
        world:move("up")
    end
    if key == "down" then
        world:move("down")
    end

    
    if key == "p" then
        local env = world:getEnv()
        print(env.position[1], env.position[2], env.left, env.right, env.up, env.down, env.coin)
        PrintMap()
    end
    
end