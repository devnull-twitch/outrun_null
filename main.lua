require "game"
require "generator"
require "character"
require "menu"

character_speed = 70
auto_scroll = 0.2
paused = false
started = false
debug = false

function love.load()
    love.window.setMode(650, 650)

    love.graphics.setFont(defaultFont)
    menu.load()

    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    gen = generator.new()
    generator.genColumn(gen)

    player = Character:new(200, 100)
    player:init()
end

function love.draw()
    if not started then
        menu.draw()
        return
    end

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
    if not started then
        menu.update(dt)
        return
    end

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
    if not started then
        menu.keypressed(key, scancode, isrepeat)
        return
    end

    if key == "p" and not isrepeat then
        paused = not paused
    end

    if key == "m" and not isrepeat then
        auto_scroll = 0
    end
end

function beginContact(a, b, coll)
    if not coll:isTouching() then
        return
    end

    local x1, y1, x2, y2 = coll:getPositions()
    local px, py = player.body:getPosition()
    local xDiff = math.abs(px - x1)
    local yDiff = math.abs(py - y1)

    if xDiff > yDiff then
        if px > x1 then
            player.blockings.left = true
        else
            player.blockings.right = true
        end
    end

    if yDiff > xDiff then
        if py > y1  then
            player.blockings.up = true
        else
            player.blockings.down = true
        end
    end
end

function endContact(a, b, coll)
    print("end contact")
	player:unblock()
end

function preSolve(a, b, coll)
	
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
	
end