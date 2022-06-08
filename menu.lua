animationSpeed = 20
menu = {
    showHowToPlay = true
}
options = {
    toggleScale = false
}

defaultFont = love.graphics.newFont("assets/jetbrainsmono_medium.ttf", 15)
headlineFont = love.graphics.newFont("assets/jetbrainsmono_medium.ttf", 25)

function playHandler()
    started = true
end

function quitHandler()
    love.event.quit()
end

function settingStartHandler()
    menu.showHowToPlay = false
    menu.options = { 
        { label = "1.5x scale", active = true, handler = toggleScaleHandler, toggleFieldNAme = "toggleScale" },
        { label = "Back to menu", active = false, handler = settingEndHandler }
    }
end

function toggleScaleHandler()
    options.toggleScale = not options.toggleScale
    if options.toggleScale then
        love.window.setMode(baseWidth * 1.5, baseHeight * 1.5)
    else
        love.window.setMode(baseWidth, baseHeight)
    end
end

function settingEndHandler()
    menu.showHowToPlay = true
    menu.options = { 
        { label = "Play", active = true, handler = playHandler },
        { label = "Settings", active = false, handler = settingStartHandler },
        { label = "Quit", active = false, handler = quitHandler }
    }
end

function menu.load()
    background = {}
    background.tileImage = love.graphics.newImage("assets/grass_pers.png")
    background.tileATime = 0

    menu.options = { 
        { label = "Play", active = true, handler = playHandler },
        { label = "Settings", active = false, handler = settingStartHandler },
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
        300, 300
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

        if not (opt.toggleFieldNAme == null) then
            local toggleX = width / 2 + 50
            love.graphics.setColor(0.4, 0.4, 0.4)
            love.graphics.rectangle("fill", toggleX, 170 + (optionIndex * 25), 40, 20)
            
            if options[opt.toggleFieldNAme] then
                love.graphics.setColor(1, 1, 1)
                love.graphics.rectangle("fill", toggleX + 25, 170 + (optionIndex * 25) + 3, 15, 14)
            else
                love.graphics.setColor(0.2, 0.2, 0.2)
                love.graphics.rectangle("fill", toggleX, 170 + (optionIndex * 25) + 3, 15, 14)
            end
        end

        optionIndex = optionIndex + 1
    end

    if menu.showHowToPlay then
        love.graphics.draw(powerupSprite, powers[1].quad, width / 2 - 125, 310)
        love.graphics.print("Battery makes you go fast!", width / 2 - 100, 310)

        love.graphics.draw(powerupSprite, powers[2].quad, width / 2 - 125, 340)
        love.graphics.print("Do you like money?", width / 2 - 100, 340)
        
        love.graphics.draw(powerupSprite, powers[3].quad, width / 2 - 125, 370)
        love.graphics.print("Get a jump [space] for each", width / 2 - 100, 370)
        love.graphics.print("Helpful to jump over cliffs", width / 2 - 100, 390)
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
