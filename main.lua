require "generator"
require "character"
require "menu"
require "autoscroll"
require "powerup"

character_speed = 70
paused = false
started = false
debug = false

coins = 0

function love.load()
    love.window.setMode(650, 650)

    love.graphics.setFont(defaultFont)
    menu.load()

    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    gen = generator.new()
    generator.genColumn(gen)

    player = Character:new(300, 650/2)
    player:init()
end

function love.draw()
    if not started then
        menu.draw()
        return
    end

    -- clear screen
    love.graphics.clear(0.10, 0.15, 0.2)

    -- draw ground
    love.graphics.setColor(1.0, 1.0, 1.0)
    local quadsDrawn = generator.draw(gen)

    powerups.draw()

    -- draw time and stuff
    autoscroll.draw()

    -- draw player character
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

    autoscroll.update(dt)
    world:update(dt)

    generator.move(gen, autoscroll.speed)
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

    powerups.autoScroll(autoscroll.speed)
    powerups.update(dt)
    
    player:autoScroll(autoscroll.speed)
    player:move(mx * dt, my * dt)
    player:update(dt)
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

    if started and (key == "space") and not isrepeat then
        player:jump()
    end
end

function beginContact(a, b, coll)
    if a:getUserData() == "powerup" then
        powerups.collision(a)
    end
    if b:getUserData() == "powerup" then
        powerups.collision(b)
    end
end

function endContact(a, b, coll)
    
end

function preSolve(a, b, coll)
	
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
	
end