local DoublePendulum = require("src.DoublePendulum")

function love.load()
    dt_accumulator = 0
    simulation_speed = 1.0
    paused = false
    
    love.window.setTitle("Chaos at Apoapsis")
    love.window.setMode(1024, 768, {resizable = true})
    
    local window_width, window_height = love.window.getMode()
    local point_size = 7
    pivot_x = window_width / 2 - point_size / 2
    pivot_y = window_height / 2 - point_size / 2
    cord1_len = 100
    bob1_mass = 10
    cord2_len = 100
    bob2_mass = 10

    pendulum = DoublePendulum.new(point_size, pivot_x, pivot_y, cord1_len , bob1_mass, cord2_len, bob2_mass)
    pendulum2 = DoublePendulum.new(point_size, pivot_x, pivot_y, cord1_len , bob1_mass, cord2_len, bob2_mass)
end

function love.update(dt)
    if not paused then
        dt_accumulator = dt_accumulator + dt * simulation_speed
        pendulum:update(dt * simulation_speed)
        pendulum2:update(dt * simulation_speed)
    end
end

function love.draw()
    -- Clear screen
    love.graphics.clear(0.1, 0.1, 0.15, 1)
    love.graphics.setColor(100/255, 100/255, 255/255, 100/255)
    pendulum:draw()
    love.graphics.setColor(200/255, 170/255, 180/255, 100/255)
    pendulum2:draw()
    
    -- Draw UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Chaos at Apoapsis", 10, 10)
    love.graphics.print("Press SPACE to pause/unpause", 10, 30)
    love.graphics.print("Press +/- to adjust simulation speed", 10, 50)
    love.graphics.print("Press R to reset", 10, 90)
    love.graphics.print(string.format("Speed: %.2fx", simulation_speed), 10, 110)
    love.graphics.print(paused and "PAUSED" or "RUNNING", 10, 130)
end

function love.keypressed(key)
    if key == "space" then
        paused = not paused
    elseif key == "escape" then
        love.event.quit()
    elseif key == "=" or key == "+" then
        simulation_speed = math.min(simulation_speed + 0.1, 5.0)
    elseif key == "-" then
        simulation_speed = math.max(simulation_speed - 0.1, 0.1)
    elseif key == "r" then
        pendulum:reset()
        pendulum2:reset()
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        pendulum.bob2_angular_vel = pendulum.bob2_angular_vel + 10
        pendulum2.bob2_angular_vel = pendulum2.bob2_angular_vel + 10
    end
end

function love.resize(w, h)
    print(string.format("Window resized to %dx%d", w, h))
end
