animationSpeed = 20
menu = {}

defaultFont = love.graphics.newFont("assets/JetBrainsMono-Medium.ttf", 15)
headlineFont = love.graphics.newFont("assets/JetBrainsMono-Medium.ttf", 25)

function playHandler()
    started = true
end

function quitHandler()
    love.event.quit()
end

function menu.load()
    background = {}
    background.tileImage = love.graphics.newImage("assets/GrassPers.png")
    background.tileATime = 0

    menu.options = { 
        { label = "Play", active = true, handler = playHandler },
        { label = "Quit", active = false, handler = quitHandler }
    }
end

function menu.draw()
    love.graphics.setColor(1, 1, 1, 1)
    local tileAY = 300 + (math.sin(background.tileATime / 3) * 150)
    love.graphics.draw(background.tileImage, 100, tileAY)

    local width, height, flags = love.window.getMode()
    love.graphics.setColor(0.2, 0.2, 0.2, 0.6)
    love.graphics.rectangle(
        "fill",
        width / 2 - 150, 125,
        300, 250
    )
    love.graphics.setColor(0.9, 0.9, 1)
    love.graphics.setFont(headlineFont)
    love.graphics.print("Outrun /dev/null", width / 2 - 125, 140)
    love.graphics.setFont(defaultFont)

    local optionIndex = 1
    while menu.options[optionIndex] do
        love.graphics.setColor(0.9, 0.9, 1)

        local opt = menu.options[optionIndex]
        local prefix = "  "
        if opt.active then
            love.graphics.setColor(1, 0.6, 0.6)
            prefix = "> "
        end
        love.graphics.print(prefix .. opt.label, width / 2 - 125, 170 + (optionIndex * 25))

        optionIndex = optionIndex + 1
    end
end

function menu.update(dt)
    background.tileATime = background.tileATime + dt
end

function menu.keypressed(key, scancode, isrepeat)
    if (key == "down") or (key == "s") then
        local optionIndex = 1
        while menu.options[optionIndex] do
            local opt = menu.options[optionIndex]

            optionIndex = optionIndex + 1
            if opt.active then
                menu.options[optionIndex - 1].active = false
                if menu.options[optionIndex] then
                    menu.options[optionIndex].active = true
                else
                    menu.options[1].active = true
                end

                return
            end
        end
    end

    if (key == "up") or (key == "w") then
        local optionIndex = table.maxn(menu.options)
        while menu.options[optionIndex] do
            local opt = menu.options[optionIndex]

            optionIndex = optionIndex - 1
            if opt.active then
                menu.options[optionIndex + 1].active = false
                if menu.options[optionIndex] then
                    menu.options[optionIndex].active = true
                else
                    menu.options[table.maxn(menu.options)].active = true
                end

                return
            end
        end
    end

    if key == "return" then
        local optionIndex = 1
        while menu.options[optionIndex] do
            local opt = menu.options[optionIndex]
            if opt.active then
                opt.handler()
                return
            end
            optionIndex = optionIndex + 1
        end
    end
end
