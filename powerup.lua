powerHandlers = {}
powerEffects = {}

function powerHandlers.speedup()
    playerSpeed = playerSpeed + 100
    local slowDown = function()
        playerSpeed = playerSpeed - 100
    end
    table.insert(powerEffects, { time = 2, handler = slowDown })
end

function powerHandlers.addCoin()
    coins = coins + 1
end

function powerHandlers.addJump()
    player:addJump()
end

powerupSprite = love.graphics.newImage("assets/powerups.png")
powers = {
    { name = "Speed up!", quad = gridQuad(0, 0, 64, 64), handler = powerHandlers.speedup },
    { name = "Coin", quad = gridQuad(1, 0, 64, 64), handler = powerHandlers.addCoin },
    { name = "Jump potion", quad = gridQuad(2, 0, 64, 64), handler = powerHandlers.addJump }
}
powerups = { drawOffset = 0 }
powersSpawned = {}

function powerups.spawn(x, y)
    local randomIndex = love.math.random(1, table.maxn(powers))
    -- local randomIndex = 2

    local newPowerup = { power = powers[randomIndex], x = x, y = y }
    newPowerup.body = love.physics.newBody(world, x + (sprite_size / 2), y + (sprite_size / 2))
    newPowerup.shape = love.physics.newRectangleShape(sprite_size, sprite_size)
    newPowerup.fixture = love.physics.newFixture(newPowerup.body, newPowerup.shape)
    newPowerup.fixture:setUserData("powerup")
    powersSpawned[table.maxn(powersSpawned) + 1] = newPowerup
end

function powerups.autoScroll(dx)
    powerups.drawOffset = powerups.drawOffset + dx
end

function powerups.update(dt)
    local effectIndex = 1
    local effectDeletions = {}
    while powerEffects[effectIndex] do
        local effect = powerEffects[effectIndex]
        effect.time = effect.time - dt
        if effect.time <= 0 then
            effect.handler()
            table.insert(effectDeletions, effectIndex)
        end

        effectIndex = effectIndex + 1
    end

    local delIndex = 1
    while effectDeletions[delIndex] do
        table.remove(powerEffects, effectDeletions[delIndex])

        delIndex = delIndex + 1
    end
end

function powerups.draw()
    love.graphics.push()
    love.graphics.translate(powerups.drawOffset * -1, 0)
    
    local renderIndex = 1
    while powersSpawned[renderIndex] do
        local renderTarget = powersSpawned[renderIndex]
        love.graphics.setColor(1.0, 1.0, 1.0)
        love.graphics.draw(powerupSprite, renderTarget.power.quad, renderTarget.x, renderTarget.y)

        if debug then
            love.graphics.setLineWidth(1)
            love.graphics.setColor(0.2, 1.0, 0.2)
            love.graphics.polygon("line", renderTarget.body:getWorldPoints(renderTarget.shape:getPoints()))
        end

        renderIndex = renderIndex + 1
    end

    love.graphics.pop()

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle(
        "fill",
        gen.width - 100, 0,
        100, 35
    )
    love.graphics.setColor(0.9, 0.9, 1)

    love.graphics.print(string.format("Coins: %d", coins), gen.width - 95, 5)
end

function powerups.collision(powerupFixture)
    local powerupIndex = 1
    while powersSpawned[powerupIndex] do
        local existing = powersSpawned[powerupIndex]
        
        if existing.fixture == powerupFixture then
            existing.power.handler()
            existing.body:destroy()
            table.remove(powersSpawned, powerupIndex)
        end

        powerupIndex = powerupIndex + 1
    end
end