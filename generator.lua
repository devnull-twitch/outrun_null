sprite_size = 16

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

function genNext(gen, x, y)
    local pos = {}

    if gen.cols[x] and gen.cols[x][y - 1] then
        local i = 1
        while pattern.allowedNeighbors[gen.cols[x][y - 1]][i] do
            table.insert(pos, pattern.allowedNeighbors[gen.cols[x][y - 1]][i])
            i = i + 1
        end
    end

    if gen.cols[x - 1] and gen.cols[x - 1][y] then
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

    gen.column = 0
    gen.offset = 0
    gen.cols = {}

    return gen
end

function generator.genColumn(gen)
    while gen.column * sprite_size < gen.width + gen.offset + sprite_size do
        gen.cols[gen.column] = {}
        local i = 0
        while (i * sprite_size) < gen.height do
            local r = love.math.random(0, 3)
            gen.cols[gen.column][i] = genNext(gen, gen.column, i)
            i = i + 1
        end
        gen.column = gen.column + 1
        print("gen col length", gen.column)
    end
end

function generator.draw(gen)
    love.graphics.push()
    love.graphics.origin()
    love.graphics.translate(gen.offset * -1, 0)
    gen.spriteBatch:clear()

    local counter = 0
    local i = math.floor(gen.offset / sprite_size)
    while gen.cols[i] and (i * sprite_size < gen.width + gen.offset) do
        local j = 0
        while gen.cols[i][j] do
            gen.spriteBatch:add(pattern.quads[gen.cols[i][j]], i*sprite_size, j*sprite_size)
            j = j + 1
            counter = counter + 1
        end
        i = i + 1
    end

    love.graphics.draw(gen.spriteBatch)
    love.graphics.pop()

    return counter
end

function generator.move(gen, translateX)
    gen.offset = gen.offset + translateX
end
