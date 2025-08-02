local DoublePendulum = {}
DoublePendulum.__index = DoublePendulum

function DoublePendulum.new(point_size, pivot_x, pivot_y, cord1_len , bob1_mass, cord2_len, bob2_mass)
    local self = setmetatable({}, DoublePendulum)
    
    -- Position
    self.pivot_x = pivot_x
    self.pivot_y = pivot_y
    self.point_size = point_size
    
    -- Pendulum parameters
    self.cord1_len  = cord1_len 
    self.bob1_mass = bob1_mass
    self.cord2_len = cord2_len
    self.bob2_mass = bob2_mass
    self.max_trail_length = 1000
    
    -- Physics constants
    local gravity_base = 9.81
    local gravity_multiplier = 80
    self.gravity = gravity_base * gravity_multiplier
    self.damping = 0.999

    self:reset()
    
    -- Initial position update
    self.bob1_x = self.pivot_x + self.cord1_len * math.sin(self.cord1_angle)
    self.bob1_y = self.pivot_y + self.cord1_len * math.cos(self.cord1_angle)
    self.bob2_x = self.bob1_x + self.cord2_len * math.sin(self.cord2_angle)
    self.bob2_y = self.bob1_y + self.cord2_len * math.cos(self.cord2_angle)

    return self
end

function DoublePendulum:update(dt)
    -- Simple pendulum equation: θ'' = -(g/L) * sin(θ)
    -- local bob1_angular_acceleration = -(self.gravity / self.cord1_len) * math.sin(self.cord1_angle)

    local angle_difference = self.cord2_angle - self.cord1_angle
    local cosine_angle_diff = math.cos(angle_difference)
    local sine_angle_diff = math.sin(angle_difference)
    local sine_cord1_angle = math.sin(self.cord1_angle)
    local sine_cord2_angle = math.sin(self.cord2_angle)
    local combined_bob_mass = self.bob1_mass + self.bob2_mass



    local lagrange_denom_1 = combined_bob_mass * self.cord1_len - self.bob2_mass * self.cord1_len * (cosine_angle_diff ^ 2)
    local lagrange_denom_2 = (self.cord2_len / self.cord1_len) * lagrange_denom_1

    local lagrange_numerator_1 = -self.bob2_mass * self.cord1_len * self.bob1_angular_vel * self.bob1_angular_vel * sine_angle_diff * cosine_angle_diff + 
                                 self.bob2_mass * self.gravity * sine_cord2_angle * cosine_angle_diff + 
                                 self.bob2_mass * self.cord2_len * self.bob2_angular_vel * self.bob2_angular_vel * sine_angle_diff - 
                                 combined_bob_mass * self.gravity * sine_cord1_angle

    local lagrange_numerator_2 = -self.bob2_mass * self.cord2_len * self.bob2_angular_vel * self.bob2_angular_vel * sine_angle_diff * cosine_angle_diff + 
                                 combined_bob_mass * self.gravity * sine_cord1_angle * cosine_angle_diff - 
                                 combined_bob_mass * self.cord1_len * self.bob1_angular_vel * self.bob1_angular_vel * sine_angle_diff -
                                 combined_bob_mass * self.gravity * sine_cord2_angle


    local bob1_angular_acceleration = lagrange_numerator_1 / lagrange_denom_1
    local bob2_angular_acceleration = lagrange_numerator_2 / lagrange_denom_2

    -- Update angular velocity
    self.bob1_angular_vel = self.bob1_angular_vel + bob1_angular_acceleration * dt
    self.bob2_angular_vel = self.bob2_angular_vel + bob2_angular_acceleration * dt

    -- Dampen
    self.bob1_angular_vel = self.bob1_angular_vel * self.damping
    self.bob2_angular_vel = self.bob2_angular_vel * self.damping

    -- Update new angle
    self.cord1_angle = self.cord1_angle + self.bob1_angular_vel * dt
    self.cord2_angle = self.cord2_angle + self.bob2_angular_vel * dt

    -- Calculate cartesian position
    self.bob1_x = self.pivot_x + self.cord1_len * math.sin(self.cord1_angle)
    self.bob1_y = self.pivot_y + self.cord1_len * math.cos(self.cord1_angle)
    self.bob2_x = self.bob1_x + self.cord2_len * math.sin(self.cord2_angle)
    self.bob2_y = self.bob1_y + self.cord2_len * math.cos(self.cord2_angle)

    table.insert(self.trail, {x = self.bob2_x, y = self.bob2_y})
    if #self.trail > self.max_trail_length then
        table.remove(self.trail, 1)
    end
    
end

function DoublePendulum:draw()
    -- Draw tail
    if #self.trail > 1 then
        for i = 1, #self.trail - 1 do
            love.graphics.line(self.trail[i].x, self.trail[i].y, 
                              self.trail[i + 1].x, self.trail[i + 1].y)
        end
    end

    -- Draw pendulum
    love.graphics.circle("fill", self.pivot_x, self.pivot_y, self.point_size)
    love.graphics.circle("fill", self.bob1_x, self.bob1_y, self.point_size)
    love.graphics.line(self.pivot_x, self.pivot_y, self.bob1_x, self.bob1_y)
    love.graphics.circle("fill", self.bob2_x, self.bob2_y, self.point_size)
    love.graphics.line(self.bob1_x, self.bob1_y, self.bob2_x, self.bob2_y)

    -- love.graphics.print("Bob 1 Angular velocity", 300, 10)
    -- love.graphics.print(self.bob1_angular_vel, 500, 10)

    -- love.graphics.print("Bob 1 x", 300, 30)
    -- love.graphics.print(self.bob1_x, 500, 30)
end

function DoublePendulum:reset()
    local random_angle_deviation = 0
    while random_angle_deviation == 0 do
        random_angle_deviation = love.math.random(1, 100) / 10000
    end
    self.cord1_angle = math.pi
    self.cord2_angle = math.pi + random_angle_deviation
    self.bob1_angular_vel = -0.1
    self.bob2_angular_vel = -0.1
    self.trail = {}
end

return DoublePendulum
