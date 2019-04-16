-- By @JakAttak

Joystick = class()

function Joystick:init(params)
    -- you can accept and set parameters here
    self.touchedCB = params.touched or function(v) end
    self.releasedCB = params.released or function(v) end
    self.movingCB = params.moving
    self.size = params.size or WIDTH / 4.5 or WIDTH / 3.84
    self.stickSize = params.stickSize or self.size / 3 or WIDTH / 8.77
    self.x1 = params.x1 or 0
    self.x2 = params.x2 or 0
    self.y1 = params.y1 or 0
    self.y2 = params.y2 or 0
    self.col = params.col or color(152, 152, 152)
    self.touched = false
    --self.initialShowing = true
    self.alwaysShow = params.alwaysOn
    self.lockedPos = params.lockPos
    self.x = self.x1 + (self.x2 - self.x1) / 2
    self.y = self.y1 + (self.y2 - self.y1) / 2
    self.tx = self.x
    self.ty = self.y
    
    -- Switch x and y to correct if needed
    if self.x1 > self.x2 then
        local px1 = self.x1
        self.x1 = self.x2
        self.x2 = px1
    end
    if self.y1 > self.y2 then
        local py1 = self.y1
        self.y1 = self.y2
        self.y2 = py1
    end
end

function Joystick:draw()
    -- Codea does not automatically call this method
end

function Joystick:touched(touch)
    -- Codea does not automatically call this method
end

