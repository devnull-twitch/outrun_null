Character = {}
maxFrameKeep = 15
characterCollisionSize = 4
playerSpeed = 100

function Character:new(x, y)
    local o = {}
    o.state = "moveDown"
    o.frameCount = 1
    o.frameKeep = maxFrameKeep
    o.image = null
    o.frames = {}
    o.dead = false
    o.drawOffset = 0
    
    -- jump related parameters
    o.availableJumps = 0
    o.isJumping = false
    o.jumpTime = 0
    o.jumpCurve = null

    o.body = love.physics.newBody(world, x, y, "dynamic") 
    o.shape = love.physics.newCircleShape(characterCollisionSize)
    o.fixture = love.physics.newFixture(o.body, o.shape)
    o.fixture:setUserData("player")
    o.blockings = { up = false, down = false, left = false, right = false  }
    setmetatable(o, self)
    self.__index = self

    return o
end

function Character:init()
    file = "assets/character.png"

    self.image = love.graphics.newImage(file)
    self.frames = {}
    self.frames.idleDown = gridQuad(1, 0, 48, 80)
    self.frames.moveDown = {
        gridQuad(0, 0, 48, 80),
        gridQuad(1, 0, 48, 80),
        gridQuad(2, 0, 48, 80),
    }
    self.frames.idleLeft = gridQuad(1, 1, 48, 80)
    self.frames.moveLeft = {
        gridQuad(0, 1, 48, 80),
        gridQuad(1, 1, 48, 80),
        gridQuad(2, 1, 48, 80),
    }
    self.frames.jumpRight = gridQuad(0, 4, 48, 80)
    self.frames.idleRight = gridQuad(1, 2, 48, 80)
    self.frames.moveRight = {
        gridQuad(0, 2, 48, 80),
        gridQuad(1, 2, 48, 80),
        gridQuad(2, 2, 48, 80),
    }
    self.frames.idleUp = gridQuad(1, 3, 48, 80)
    self.frames.moveUp = {
        gridQuad(0, 3, 48, 80),
        gridQuad(1, 3, 48, 80),
        gridQuad(2, 3, 48, 80),
    }
end

function Character:draw()
    love.graphics.push()
    love.graphics.translate(self.drawOffset * -1, 0)

    local x = self.body:getX()
    local y = self.body:getY()
    if self.isJumping then
        local jt = self.jumpTime
        if jt > 1 then
            jt = 1
        end
        local jumpX, jumpY = self.jumpCurve:evaluate(jt)
        
        -- reset jump
        if self.jumpTime >= 1 then
            self.isJumping = false
            self.state = "idleRight"
            self.body:setX(jumpX)
            self.body:setY(jumpY)
        end

        x = jumpX
        y = jumpY
    end

    if string.sub(self.state, 0, 4) == "move" then
        love.graphics.draw(self.image, self.frames[self.state][self.frameCount], x - (sprite_size/2), y - (sprite_size/2))
        
        self.frameKeep = self.frameKeep - 1
        if self.frameKeep <= 0 then
            self.frameKeep = maxFrameKeep
            self.frameCount = self.frameCount + 1
            if self.frameCount > table.maxn(self.frames[self.state]) then
                self.frameCount = 1
            end
        end
    elseif string.sub(self.state, 0, 4) == "jump" then
        love.graphics.draw(self.image, self.frames[self.state], x - (sprite_size/2), y - (sprite_size/2))
        self.frameCount = 1
        self.frameKeep = maxFrameKeep
    else
        love.graphics.draw(self.image, self.frames[self.state], x - (sprite_size/2), y - (sprite_size/2))
        self.frameCount = 1
        self.frameKeep = maxFrameKeep
    end    

    if debug then
        love.graphics.setLineWidth(1)
        love.graphics.setColor(0.2, 1.0, 0.2)
        love.graphics.circle("line", x, y, characterCollisionSize)

        local genX, genY = self:genGenPosition()
        love.graphics.setLineWidth(2)
        love.graphics.setColor(1.0, 0.2, 0.2)
        love.graphics.rectangle("line", genX * sprite_size, genY * sprite_size, sprite_size, sprite_size)
    end

    love.graphics.pop()
end

function Character:autoScroll(dx)
    self.drawOffset = self.drawOffset + dx
end

function Character:update(dt)
    if self.isJumping then
        self.jumpTime = self.jumpTime + dt
    end
end

function Character:blockMovement(dir)
    self.blockings[dir] = true
end

function Character:unblock()
    self.blockings = { up = false, down = false, left = false, right = false  }
end

jumpHeight = 3 * sprite_size
jumpDistance = 4 * sprite_size
function Character:jump()
    if self.availableJumps > 0 then
        self.availableJumps = self.availableJumps - 1
        self.isJumping = 0
        self.jumpTime = 0
        self.state = "jumpRight"
        self.jumpCurve = love.math.newBezierCurve(
            self.body:getX(),
            self.body:getY(),
            self.body:getX() + (jumpDistance / 2),
            self.body:getY() - jumpHeight,
            self.body:getX() + jumpDistance,
            self.body:getY()
        )
    end
end

function Character:addJump()
    self.availableJumps = self.availableJumps + 1
end

function Character:move(dx, dy)
    if self.isJumping then
        self.body:setLinearVelocity(0, 0)
        return
    end

    if not (dx == 0) then
        if dx > 0 then
            if self.blockings.right then
                dx = 0
            else
                self.state = "moveRight"
            end
        else
            if self.blockings.left then
                dx = 0
            else
                self.state = "moveLeft"
            end
        end
    end

    if not (dy == 0) then
        if dy > 0 then
            if self.blockings.down then
                dy = 0
            else
                self.state = "moveDown"
            end
        else
            if self.blockings.up then
                dy = 0
            else
                self.state = "moveUp"
            end
        end
    end

    if not (dx == 0) or not (dy == 0) then
        self.body:setLinearVelocity(dx * playerSpeed, dy * playerSpeed)
        return
    end

    self.body:setLinearVelocity(0, 0)

    if string.sub(self.state, 0, 4) == "move" then
        self.state = string.gsub(self.state, "move", "idle")
    end
end

function Character:checkDeath(gen)
    local genX, genY = self:genGenPosition()

    if gen.skips[genX] and gen.skips[genX][genY] then
        self.dead = true
    end
end

function Character:genGenPosition()
    local genX = self.body:getX()
    genX = math.floor(genX / sprite_size)
    local genY = math.floor((self.body:getY() + (sprite_size * 0.5))/ sprite_size)

    return genX, genY
end

function Character:isPlayer(fixture)
    return fixture:getUserData() == "player"
end