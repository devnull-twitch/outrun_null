require "game"
require "generator"
require "character"

character_speed = 70
auto_scroll = 0.2
paused = false
debug = true

function love.load()
    love.window.setMode(650, 650)

    world = love.physics.newWorld(0, 0, true)

    gen = generator.new()
    generator.genColumn(gen)

    player = Character:new(200, 100)
    player:init()
end

function love.draw()
    -- clear screen
    love.graphics.clear(0.10, 0.15, 0.2)

    love.graphics.setColor(1.0, 1.0, 1.0)
    local quadsDrawn = generator.draw(gen)

    love.graphics.setColor(1.0, 1.0, 1.0)
    player:draw()

    if paused then
       local width, height, flags = love.window.getMode()
       love.graphics.setColor(0, 0, 0)
       love.graphics.rectangle(
           "fill",
           width / 2 - 100, height / 2 - 50,
           200, 100
       )
       love.graphics.setColor(0.9, 0.9, 1)
       love.graphics.print("Game [P]aused", width / 2 - 80, height / 2 - 30)
    end
end

function love.update(dt)
    if player.dead then
        return
    end

    if paused then
        return
    end

    world:update(dt)

    generator.move(gen, auto_scroll)
    generator.genColumn(gen)

    local mx = 0
    local my = 0
    if love.keyboard.isDown("w") then
        my = -character_speed
    elseif love.keyboard.isDown("s") then
        my = character_speed
    end
    if love.keyboard.isDown("a") then
        mx = -character_speed
    elseif love.keyboard.isDown("d") then
        mx = character_speed
    end
    
    player:autoScroll(auto_scroll)
    player:move(mx * dt, my * dt)
    player:checkDeath(gen)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "p" and not isrepeat then
        paused = not paused
    end
end