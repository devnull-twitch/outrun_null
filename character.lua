Character = {}
maxFrameKeep = 15
characterCollisionSize = 4

function Character:new(x, y)
    local o = {}
    o.state = "moveDown"
    o.frameCount = 1
    o.frameKeep = maxFrameKeep
    o.image = null
    o.frames = {}
    o.dead = false
    o.drawOffset = 0
    o.body = love.physics.newBody(world, x, y, "dynamic") 
    o.shape = love.physics.newCircleShape(characterCollisionSize)
    o.fixture = love.physics.newFixture(o.body, o.shape)
    o.savePos = { x = x, y = y }
    setmetatable(o, self)
    self.__index = self

    return o
end

function Character:init()
    file = "assets/character.png"

    self.image = love.graphics.newImage(file)
    self.frames = {}
    self.frames.idleDown = gridQuad(1, 0, 48, 64)
    self.frames.moveDown = {
        gridQuad(0, 0, 48, 64),
        gridQuad(1, 0, 48, 64),
        gridQuad(2, 0, 48, 64),
    }
    self.frames.idleLeft = gridQuad(1, 1, 48, 64)
    self.frames.moveLeft = {
        gridQuad(0, 1, 48, 64),
        gridQuad(1, 1, 48, 64),
        gridQuad(2, 1, 48, 64),
    }
    self.frames.idleRight = gridQuad(1, 2, 48, 64)
    self.frames.moveRight = {
        gridQuad(0, 2, 48, 64),
        gridQuad(1, 2, 48, 64),
        gridQuad(2, 2, 48, 64),
    }
    self.frames.idleUp = gridQuad(1, 3, 48, 64)
    self.frames.moveUp = {
        gridQuad(0, 3, 48, 64),
        gridQuad(1, 3, 48, 64),
        gridQuad(2, 3, 48, 64),
    }
end

function Character:draw()
    love.graphics.push()
    love.graphics.translate(self.drawOffset * -1, 0)

    if string.sub(self.state, 0, 4) == "move" then
        love.graphics.draw(self.image, self.frames[self.state][self.frameCount], self.body:getX() - (sprite_size/2), self.body:getY() - (sprite_size/2))
        
        self.frameKeep = self.frameKeep - 1
        if self.frameKeep <= 0 then
            self.frameKeep = maxFrameKeep
            self.frameCount = self.frameCount + 1
            if self.frameCount > table.maxn(self.frames[self.state]) then
                self.frameCount = 1
            end
        end
    else
        love.graphics.draw(self.image, self.frames[self.state], self.body:getX() - (sprite_size/2), self.body:getY() - (sprite_size/2))
        self.frameCount = 1
        self.frameKeep = maxFrameKeep
    end    

    if debug then
        love.graphics.setLineWidth(1)
        love.graphics.setColor(0.2, 1.0, 0.2)
        love.graphics.circle("line", self.body:getX(), self.body:getY(), characterCollisionSize)

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

function Character:move(dx, dy)
    local contacts = self.body:getContacts()
    local processedOne = false
    local contactIndex = 1
    while not processedOne and contacts[contactIndex] do
        local contact = contacts[contactIndex]
        if contact:isTouching() then
            local x1, y1, x2, y2 = contact:getPositions()
            print("collision", x1, y1, x2, y2)
            local cvx = self.body:getX() - x1
            local cvy = self.body:getY() - y1
            self.body:setPosition(self.body:getX() + cvx, self.body:getY() + cvy)
            processedOne = true
            return
        end

        contactIndex = contactIndex + 1
    end

    if not (dx == 0) then
        if dx > 0 then
            self.state = "moveRight"
        else
            self.state = "moveLeft"
        end
    end

    if not (dy == 0) then
        if dy > 0 then
            self.state = "moveDown"
        else
            self.state = "moveUp"
        end
    end

    if not (dx == 0) or not (dy == 0) then
        self.body:setPosition(self.body:getX() + dx, self.body:getY() + dy)
        return
    end

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