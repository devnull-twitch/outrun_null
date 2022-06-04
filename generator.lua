sprite_size = 16
void_start = 10
extra_spacing = 10
powerup_spacing = 10

function gridQuad(cellX, cellY, sw, sh)
    return love.graphics.newQuad(cellX * sprite_size, cellY * sprite_size, sprite_size, sprite_size, sw, sh)
end

generator = {}
pattern = {
    file = "assets/ground_tiles.png",
    quads = {
        gridQuad(0, 0, 112, 112), -- dirt, min light
        gridQuad(0, 1, 112, 112), -- dirt, normal
        gridQuad(0, 2, 112, 112), -- dirt, rough
        gridQuad(0, 3, 112, 112), -- dirt, light, min grass
        gridQuad(0, 4, 112, 112), -- dirt, rough, min grass
        gridQuad(0, 5, 112, 112), -- dirt, light, grass
        gridQuad(0, 6, 112, 112), -- dirt, rough, grass
        gridQuad(1, 0, 112, 112), -- dirt, light
        gridQuad(1, 1, 112, 112), -- dirt, light, min rough
        gridQuad(1, 2, 112, 112), -- dirt, rough, min light
        gridQuad(1, 3, 112, 112), -- grass, short
        gridQuad(2, 3, 112, 112), -- grass, normal
        gridQuad(2, 4, 112, 112) -- grass, high
    },
    allowedNeighbors = {
        { 1, 2, 3, 6, 8 },
        { 2, 1, 6 },
        { 3, 5, 1, 10 },
        { 4, 6, 11 },
        { 5, 3, 7 },
        { 6, 4, 7 },
        { 7, 6, 5 },
        { 8, 1, 9 },
        { 9, 8, 10 },
        { 10, 9 },
        { 11, 12, 4 },
        { 12, 11, 13 },
        { 13, 12 }
    }
}
extras = {
    file = "assets/dark_rocky_forest_tiles.png",
    quads = {
        gridQuad(1, 0, 192, 128), -- 1: void cliff bottom
        gridQuad(0, 1, 192, 128), -- 2: void cliff right
        gridQuad(2, 1, 192, 128), -- 3: void cliff left
        gridQuad(1, 2, 192, 128), -- 4: void cliff top
        gridQuad(3, 5, 192, 128), -- 5: tree open side
        gridQuad(7, 7, 192, 128), -- 6: tree center
        gridQuad(3, 7, 192, 128)  -- 7: tree closed side
    }
}

function genNext(gen, x, y)
    local pos = {}

    if gen.cols[x] and gen.cols[x][y - 1] then
        local i = 1
        while pattern.allowedNeighbors[gen.cols[x][y - 1]][i] and gen.cols[x][y - 1] > 0 do
            table.insert(pos, pattern.allowedNeighbors[gen.cols[x][y - 1]][i])
            i = i + 1
        end
    end

    if gen.cols[x - 1] and gen.cols[x - 1][y] and gen.cols[x - 1][y] > 0 then
        local i = 1
        while pattern.allowedNeighbors[gen.cols[x - 1][y]][i] do
            table.insert(pos, pattern.allowedNeighbors[gen.cols[x - 1][y]][i])
            i = i + 1
        end
    end

    if table.maxn(pos) <= 0 then
        return 1
    end

    return pos[love.math.random(table.maxn(pos))]
end

function generator.new()
    local gen = {}

    local width, height, flags = love.window.getMode()
    gen.width = width
    gen.height = height

    local image = love.graphics.newImage(pattern.file)
    gen.spriteBatch = love.graphics.newSpriteBatch(image)

    local extrasImage = love.graphics.newImage(extras.file)
    gen.extraBatch = love.graphics.newSpriteBatch(extrasImage)

    gen.column = 0
    gen.offset = 0
    gen.cols = {}
    gen.skips = {}
    gen.skipRuns = {}
    
    gen.extras = {}
    gen.extraPhysics = {}
    gen.lastExtra = 15

    gen.lastPowerup = 20

    gen.borderRight = {}
    gen.borderRight.body = love.physics.newBody(world, width - 10, height/2, "kinematic")
    gen.borderRight.shape = love.physics.newEdgeShape(0, -height/2, 0, height/2)
    gen.borderRight.fixture = love.physics.newFixture(gen.borderRight.body, gen.borderRight.shape)

    gen.borderTop = {}
    gen.borderTop.body = love.physics.newBody(world, width/2, 10, "kinematic")
    gen.borderTop.shape = love.physics.newEdgeShape(-width/2, 0, width/2, 0)
    gen.borderTop.fixture = love.physics.newFixture(gen.borderTop.body, gen.borderTop.shape)

    gen.borderBottom = {}
    gen.borderBottom.body = love.physics.newBody(world, width/2, height-10, "kinematic")
    gen.borderBottom.shape = love.physics.newEdgeShape(-width/2, 0, width/2, 0)
    gen.borderBottom.fixture = love.physics.newFixture(gen.borderBottom.body, gen.borderBottom.shape)

    return gen
end

function generator.genColumn(gen)
    while gen.column * sprite_size < gen.width + gen.offset + sprite_size do
        if (gen.column > gen.lastExtra + extra_spacing) and (love.math.random() > 0.92) then
            generator.makeCliff(gen, gen.column, 3)
        end

        if (gen.column > gen.lastPowerup + powerup_spacing) and (love.math.random() > 0) then
            local powerupY = math.floor(love.math.random(3, gen.height / sprite_size - 3))
            powerups.spawn(gen.column * sprite_size, powerupY * sprite_size)
            gen.lastPowerup = gen.column
        end 

        gen.cols[gen.column] = {}
        gen.skips[gen.column] = {}
        gen.skipRuns[gen.column] = void_start + 1
        local i = 0
        while (i * sprite_size) < gen.height do
            local r = love.math.random(0, 3)
            gen.cols[gen.column][i] = genNext(gen, gen.column, i)
            i = i + 1
        end
        gen.column = gen.column + 1
    end

    -- void zone update
    local init_i = math.floor(gen.offset / sprite_size)
    local i = math.floor(gen.offset / sprite_size)
    while i < (init_i + void_start) do
        if gen.skipRuns[i] > i - init_i then
            gen.skipRuns[i] = i - init_i
            local j = 0
            while (j * sprite_size) < gen.height do
                gen.skips[i][j] = gen.skips[i][j] or love.math.random(i - init_i + 1) <= 1

                j = j + 1
            end
        end

        i = i + 1
    end
end

function generator.makeCliff(gen, x, cw)
    local wx = 0
    while wx < cw do
        gen.extras[x + wx] = {}
        gen.skips[x + wx] = {}
        gen.skipRuns[x + wx] = void_start

        if not gen.cols[x + wx] then
            gen.cols[x + wx] = {}
        end

        local cy = 0
        while (cy * sprite_size) < gen.height do
            gen.cols[x + wx][cy] = 0
            if wx == 0 then
                gen.extras[x + wx][cy] = 2
            elseif wx == cw - 1 then
                gen.extras[x + wx][cy] = 3
            end
            cy = cy + 1
        end

        wx = wx + 1
    end

    local bridgeY = math.floor(love.math.random(3, gen.height / sprite_size - 3))
    wx = -1
    while wx < cw + 1 do
        if not gen.cols[x + wx] then
            gen.cols[x + wx] = {}
        end
        if not gen.extras[x + wx] then
            gen.extras[x + wx] = {}
        end

        gen.extras[x + wx][bridgeY] = 6
        wx = wx + 1
    end

    gen.column = gen.column + cw
    gen.lastExtra = gen.column

    -- cliff physics
    local extraPhysic = {}
    local width = cw * sprite_size
    local upperHeight = bridgeY * sprite_size
    local lowerHeight = gen.height - upperHeight - sprite_size
    local bodyX = x * sprite_size + (width / 2)
    extraPhysic.upperBody = love.physics.newBody(world, bodyX, (upperHeight - (sprite_size / 2)) / 2)
    extraPhysic.upperShape = love.physics.newRectangleShape(width, upperHeight - (sprite_size / 2))
    extraPhysic.upperFixture = love.physics.newFixture(extraPhysic.upperBody, extraPhysic.upperShape)
    extraPhysic.lowerBody = love.physics.newBody(world, bodyX, upperHeight + sprite_size + (lowerHeight / 2))
    extraPhysic.lowerShape = love.physics.newRectangleShape(width, lowerHeight)
    extraPhysic.lowerFixture = love.physics.newFixture(extraPhysic.lowerBody, extraPhysic.lowerShape)

    table.insert(gen.extraPhysics, extraPhysic)
end

function generator.draw(gen)
    love.graphics.push()
    love.graphics.origin()
    love.graphics.translate(gen.offset * -1, 0)
    gen.spriteBatch:clear()
    gen.extraBatch:clear()

    local counter = 0
    local init_i = math.floor(gen.offset / sprite_size)
    local i = math.floor(gen.offset / sprite_size)
    while gen.cols[i] and (i * sprite_size < gen.width + gen.offset) do
        local j = 0
        while gen.cols[i][j] do
            if (not gen.skips[i] or not gen.skips[i][j]) and gen.extras[i] and gen.extras[i][j] then
                gen.extraBatch:add(extras.quads[gen.extras[i][j]], i*sprite_size, j*sprite_size)
            elseif (not gen.skips[i] or not gen.skips[i][j]) and gen.cols[i][j] > 0 then
                gen.spriteBatch:add(pattern.quads[gen.cols[i][j]], i*sprite_size, j*sprite_size)
            end

            j = j + 1
            counter = counter + 1
        end
        i = i + 1
    end

    love.graphics.draw(gen.spriteBatch)
    love.graphics.draw(gen.extraBatch)

    if debug then
        local extraPhysicsIndex = 1
        while gen.extraPhysics[extraPhysicsIndex] do
            local extraPhysics = gen.extraPhysics[extraPhysicsIndex]
            love.graphics.setLineWidth(1)
            love.graphics.setColor(0.2, 1.2, 0.2)
            love.graphics.polygon("line", extraPhysics.upperBody:getWorldPoints(extraPhysics.upperShape:getPoints()))
            love.graphics.polygon("line", extraPhysics.lowerBody:getWorldPoints(extraPhysics.lowerShape:getPoints()))

            extraPhysicsIndex = extraPhysicsIndex + 1
        end
    end

    love.graphics.pop()

    return counter
end

function generator.move(gen, translateX)
    gen.offset = gen.offset + translateX
    if gen.offset < 0 then
        gen.offset = 0
    end

    gen.borderRight.body:setX(gen.borderRight.body:getX() + translateX)
    gen.borderTop.body:setX(gen.borderTop.body:getX() + translateX)
    gen.borderBottom.body:setX(gen.borderBottom.body:getX() + translateX)
end
