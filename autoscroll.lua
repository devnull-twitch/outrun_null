speedup_time = 5
speedup_amount = { 0.1, 0.05, 0.03, 0.02, 0.01, 0.005 }
autoscroll = { speed = 0.2, time = 0, totaltime = 0, phase = 1 }

function autoscroll.update(dt)
    autoscroll.time = autoscroll.time + dt
    autoscroll.totaltime = autoscroll.totaltime + dt
    if autoscroll.time > speedup_time then
        local speedupIndex = autoscroll.phase
        if speedupIndex > table.maxn(speedup_amount)  then
            speedupIndex = table.maxn(speedup_amount)
        end
        
        autoscroll.speed = autoscroll.speed + speedup_amount[speedupIndex]
        autoscroll.time = 0
        autoscroll.phase = autoscroll.phase + 1
    end
end

function autoscroll.reset()
    autoscroll.time = 0
    autoscroll.totaltime = 0
    autoscroll.speed = 0.2
    autoscroll.phase = 1
end

function autoscroll.draw()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle(
        "fill",
        0, 0,
        200, 35
    )
    love.graphics.setColor(0.9, 0.9, 1)

    local minutes = math.floor(autoscroll.totaltime / 60)
    local seconds = math.floor(autoscroll.totaltime % 60)
    love.graphics.print("Time: " .. tostring(minutes) .. ":" .. string.format("%02d", seconds) .. " | Phase " .. tostring(autoscroll.phase), 5, 5)
end