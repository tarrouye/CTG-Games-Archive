Player = class()

function Player:init(x, y)
    self.deathAngle = 90 -- used by WAVES class to determine when the player should fall off his board
    
    self.startX = x
    self.startY = y
    
    self.doll = Ragdoll(x, y, true)
    self.board = self.doll.bones[13]
    
    self.alive = true
    self.touchingWater = false
    
    self.airtime = 0
    self.flips = 0
    
    self.lastFlipAngle = 0
    
    local moveDoll = function(d)
        for i, bone in ipairs(self.doll.bones) do
            bone:applyForce(vec2(d.x * 10, 0))
        end
    end
    
    local rotateDoll = function(d)
        local angle = math.atan(d.y, d.x) / 10
        local angle = -d.x / 2
        for i, bone in ipairs(self.doll.bones) do
            bone:applyAngularImpulse( angle * SCALAR )
        end
    end
    
    local stick1 = Joystick{x1 = 0, x2 = WIDTH / 2, y1 = 0, y2 = HEIGHT,
            moving = function(d) moveDoll(d) end, size = 150,
            col = color(0, 255, 86, 255)}
    local stick2 = Joystick{x1 = WIDTH / 2, x2 = WIDTH, y1 = 0, y2 = HEIGHT,
            moving = function(d) rotateDoll(d) end, size = 150,
            col = color(255, 0, 0, 255)}
    
    JOYSTICKS:addSticks{stick1, stick2}
end

function Player:reset()
    self.doll:remove()
    self.doll = nil
    collectgarbage()
    self.doll = Ragdoll(self.startX, self.startY, true)
    self.board = self.doll.bones[13]
    
    self.alive = true
    self.touchingWater = false
    
    self.airtime = 0
    self.flips = 0
    
    self.lastFlipAngle = 0
end

function Player:wouldDie()
    local ang = weirdReverseModulo(self.board.angle, 180)
    return (math.abs(ang) > self.deathAngle)
end

function Player:checkFlips()
    local ang = self.board.angle - self.lastFlipAngle
    local roundedTo360 = 360 * math.round(self.board.angle / 360)
    if (self.alive and math.abs(ang) >= 290) then
        self.flips = self.flips + 1
        sound("Game Sounds One:Bell 2")
        self.lastFlipAngle = roundedTo360
    end
    
    if (self.touchingWater) then
        self.lastFlipAngle = roundedTo360
    end
end

function Player:kill()
    self.alive = false
    DebugDraw:removeJoint(self.doll.joints[13])
    DebugDraw:removeJoint(self.doll.joints[12])

    if gamecenter.enabled() then
        gamecenter.submitScore(self.flips, "clumsysurfing_flips")
        gamecenter.submitScore(math.round(self.airtime, 1) * 10, "clumsysurfing_airtime")
    end

    JOYSTICKS:releaseAll()
    
    sound("A Hero's Quest:Water Splash")
end

function Player:draw()
    if not self.touchingWater and self.alive then
        self.airtime = self.airtime + DeltaTime
    end
    self:checkFlips()
    
    -- Scores
    fill(0, 0, 0, 200)
    if (self.alive == false or self:wouldDie()) then
        fill(255, 0, 0, 200)
    end
    
    fontSize(MIN_DIMENSION / 4)
    local btw, bth = textSize(math.round(self.airtime, 1))
    text(math.round(self.airtime, 1), WIDTH / 4, HEIGHT * 7/8)
    fontSize(MIN_DIMENSION / 16)
    text("AIR TIME", WIDTH / 4, HEIGHT * 7/8 - bth / 2)
    
    fontSize(MIN_DIMENSION / 4)
    local btw, bth = textSize(self.flips)
    text(self.flips, WIDTH * 3/4, HEIGHT * 7/8)
    fontSize(MIN_DIMENSION / 16)
    text("FLIPS", WIDTH * 3/4, HEIGHT * 7/8 - bth / 2)
end

function Player:touched(touch)
    -- Codea does not automatically call this method
end
