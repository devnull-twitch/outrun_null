require "generator"
require "character"
require "menu"
require "autoscroll"
require "powerup"

character_speed = 70
paused = false
started = false
debug = false

baseWidth = 650
baseHeight = 650

coins = 0

function love.load()
    love.window.setMode(baseWidth, baseHeight)

    love.graphics.setFont(defaultFont)
    menu.load()

    world = love.physics.newWorld(0, 0, true)
    world:setCallbacks(beginContact, endContact, preSolve, postSolve)

    gen = generator.new()
    generator.genColumn(gen)

    player = Character:new(300, baseHeight/2)
    player:init()
end

function love.draw()
    if not started then
        menu.draw()
        return
    end

    -- clear screen
    love.graphics.clear(0.10, 0.15, 0.2)

    -- handle scaling
    if options.toggleScale then
        love.graphics.scale(1.5, 1.5)
    else
        love.graphics.scale(1, 1)
    end

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

    if player.dead then
        local fade = math.min(1, deadFade)
        local width, height, flags = love.window.getMode()
        local headlineText = "You are dead"
        local textWidth = headlineFont:getWidth(headlineText)

        local boxW = textWidth + 20
        local boxH = headlineFont:getHeight() + (defaultFont:getHeight() * 2) + 40
        local boxX = width / 2 - (boxW / 2)
        local boxY = height / 2 - (boxH / 2)

        love.graphics.setColor(0, 0, 0, fade)
        love.graphics.rectangle(
            "fill",
            boxX, boxY,
            boxW, boxH
        )

        local headlineX = (width / 2) - ((textWidth - 5) / 2)
        local headlineY = (height / 2) - (boxH / 2) + 10

        love.graphics.setColor(0.9, 0.9, 1, fade)
        love.graphics.setFont(headlineFont)
        love.graphics.print(headlineText, headlineX, headlineY)
        love.graphics.setFont(defaultFont)

        local option1Y = headlineY + headlineFont:getHeight() + 10
        love.graphics.print("[R]estart", headlineX, option1Y)

        local option2Y = option1Y + defaultFont:getHeight() + 10
        love.graphics.print("[Q]uit to menu", headlineX, option2Y)
    end
end

playerPhase = 0
deadFade = 0
function love.update(dt)
    if not started then
        menu.update(dt)
        return
    end

    if player.dead then
        deadFade = deadFade + dt
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

    if (autoscroll.phase % 30 == 0) and (math.floor(autoscroll.phase / 30) == playerPhase) then
        playerPhase = playerPhase + 1
        playerSpeed = playerSpeed + 80
    end
end

function love.keypressed(key, scancode, isrepeat)
    if not started then
        menu.keypressed(key, scancode, isrepeat)
        return
    end

    if player.dead and key == "r" and not isrepeat then
        player:reset(300, baseHeight/2)
        generator.reset(gen)
        autoscroll.reset()
    end

    if player.dead and key == "q" and not isrepeat then
        player:reset(300, baseHeight/2)
        generator.reset(gen)
        autoscroll.reset()

        started = false
    end

    if key == "p" and not isrepeat and not player.dead then
        paused = not paused
    end

    if started and (key == "space") and not isrepeat then
        player:jump()
    end
end

function beginContact(a, b, coll)
    if a:getUserData() == "powerup" then
        powerups.collision(a)
        return
    end
    if b:getUserData() == "powerup" then
        powerups.collision(b)
        return
    end

    if debug then
        print(a:getUserData(), b:getUserData())
    end
end

function endContact(a, b, coll)
    
end

function preSolve(a, b, coll)
	
end

function postSolve(a, b, coll, normalimpulse, tangentimpulse)
	
end