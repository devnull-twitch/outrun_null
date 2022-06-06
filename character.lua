Character = {}
maxFrameKeep = 15
characterCollisionSize = 8
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
    o.characterSpriteSize = 32
    
    -- jump related parameters
    o.availableJumps = 0
    o.isJumping = false
    o.jumpTime = 0
    o.jumpCurve = null

    o.body = love.physics.newBody(world, x, y, "dynamic") 
    o.shape = love.physics.newCircleShape(characterCollisionSize)
    o.fixture = love.physics.newFixture(o.body, o.shape)
    o.fixture:setUserData("player")
    setmetatable(o, self)
    self.__index = self

    return o
end

function Character:reset(x, y)
    self.body:setPosition(x, y)
    self.availableJumps = 0
    self.dead = false
    self.drawOffset = 0
end

function Character:init()
    file = "assets/character_v2.png"
    imageW = 380
    imageH = 253

    self.image = love.graphics.newImage(file)
    self.frames = {}
    self.frames.idleDown = gridQuad(1, 0, imageW, imageH, self.characterSpriteSize)
    self.frames.moveDown = {
        gridQuad(0, 0, imageW, imageH, self.characterSpriteSize),
        gridQuad(1, 0, imageW, imageH, self.characterSpriteSize),
        gridQuad(2, 0, imageW, imageH, self.characterSpriteSize),
    }
    self.frames.idleLeft = gridQuad(1, 1, imageW, imageH, self.characterSpriteSize)
    self.frames.moveLeft = {
        gridQuad(0, 1, imageW, imageH, self.characterSpriteSize),
        gridQuad(1, 1, imageW, imageH, self.characterSpriteSize),
        gridQuad(2, 1, imageW, imageH, self.characterSpriteSize),
    }
    self.frames.jumpRight = gridQuad(3, 0, imageW, imageH, self.characterSpriteSize)
    self.frames.idleRight = gridQuad(1, 2, imageW, imageH, self.characterSpriteSize)
    self.frames.moveRight = {
        gridQuad(0, 2, imageW, imageH, self.characterSpriteSize),
        gridQuad(1, 2, imageW, imageH, self.characterSpriteSize),
        gridQuad(2, 2, imageW, imageH, self.characterSpriteSize),
    }
    self.frames.idleUp = gridQuad(1, 3, imageW, imageH, self.characterSpriteSize)
    self.frames.moveUp = {
        gridQuad(0, 3, imageW, imageH, self.characterSpriteSize),
        gridQuad(1, 3, imageW, imageH, self.characterSpriteSize),
        gridQuad(2, 3, imageW, imageH, self.characterSpriteSize)
    }
end

function Character:draw()
    love.graphics.push()
    love.graphics.translate(self.drawOffset * -1, 0)

    local x = self.body:getX()
    local y = self.body:getY()
    local spriteSize = self.characterSpriteSize
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
        love.graphics.draw(self.image, self.frames[self.state][self.frameCount], x - (spriteSize/2), y - (spriteSize/2))
        
        self.frameKeep = self.frameKeep - 1
        if self.frameKeep <= 0 then
            self.frameKeep = maxFrameKeep
            self.frameCount = self.frameCount + 1
            if self.frameCount > table.maxn(self.frames[self.state]) then
                self.frameCount = 1
            end
        end
    elseif self.isJumping then
        love.graphics.draw(self.image, self.frames["jumpRight"], x - (spriteSize/2), y - (spriteSize/2))
        self.frameCount = 1
        self.frameKeep = maxFrameKeep
    else
        love.graphics.draw(self.image, self.frames[self.state], x - (spriteSize/2), y - (spriteSize/2))
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

    -- draw available jump UI
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle(
        "fill",
        gen.width - 100, 35,
        100, 35
    )
    love.graphics.setColor(1, 1, 1)
    for ji = 1, player.availableJumps do
        love.graphics.draw(powerupSprite, powers[3].quad, gen.width - 95 + ((ji - 1) * 20), 40)
    end
end

function Character:autoScroll(dx)
    self.drawOffset = self.drawOffset + dx
end

function Character:update(dt)
    if self.isJumping then
        self.jumpTime = self.jumpTime + dt
    end
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

    if not (dx == 0) or not (dy == 0) then
        self.body:setLinearVelocity(dx * playerSpeed, dy * playerSpeed)
        if dx > 0 then
            self.state = "moveRight"
        elseif dx < 0 then
            self.state = "moveLeft"
        elseif dy > 0 then
            self.state = "moveDown"
        else
            self.state = "moveUp"
        end
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