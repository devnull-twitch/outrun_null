require "game"
require "generator"

movementX = 1

function love.load()
    love.window.setMode(650, 650)

    gen = generator.new()
    generator.genColumn(gen)
end

function love.draw()
    love.graphics.setColor(1.0, 1.0, 1.0)
    local quadsDrawn = generator.draw(gen)

    -- debug show quads drawn
    love.graphics.setColor(1.0, 1.0, 1.0)
    love.graphics.rectangle(
        "fill",
        0, 0,
        90, 20
    )
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(tostring(quadsDrawn) .. " quads", 5, 5)
end

function love.update(dt)
    generator.move(gen, movementX)
    generator.genColumn(gen)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "a" then
        movementX = -1
    end
end

function love.keyreleased(key, scancode)
    if key == "a" then
        movementX = 1
    end
end