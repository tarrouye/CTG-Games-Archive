Button = class()

function Button:init(img, x, y, callback, size)
    self.img = img
    self.x = x
    self.y = y
    self.size = size
    self.drawSize = self.size
    self.callback = callback
    self.pressed = false
    self.tint = color(127, 127, 127, 255)
end

function Button:draw()
    pushStyle()
    --noSmooth()
    
    if self.pressed then
        tint(self.tint)
    end
        
    sprite(self.img, self.x, self.y, self.drawSize.x, self.drawSize.y)
    
    if self.glow ~= nil then
        for i, glow in ipairs(self.glow) do
            glow:draw()
        end
    end
    popStyle()
end

function Button:touched(touch)
    local rt
    if touch.x > self.x - self.size.x/2 and touch.x < self.x + self.size.x/2 and
    touch.y > self.y - self.size.y/2 and touch.y < self.y + self.size.y/2 then
        if touch.state == BEGAN or touch.state == MOVING then
            self.pressed = true
        elseif touch.state == ENDED then
            self.pressed = false
            self.callback()
            if not self.silent then
                sound("Game Sounds One:Block 1")
            end
        end
        rt = true
    else
        self.pressed = false
        rt = false
    end
    
    return rt
end


JuiceButton = class(Button)

function JuiceButton:init(img, x, y, callback, size)
    self.juiceObj = juice.sprite(img, x, y, size.x, size.y)
    
    Button.init(self, img, x, y, callback, size)
end

function JuiceButton:wobble(amnt, time, speed)
    local a, t, s = (amnt or 5), (time or math.huge), (speed or 0.25)
    self.juiceObj:wobble(a, t, s)
end

function JuiceButton:pulse(amnt, time, speed)
    local a, t, s = (amnt or 0.3), (time or math.huge), (speed or 0.5)
    self.juiceObj:pulse(a, t, s)
end

function JuiceButton:update(tbl)
    if tbl ~= nil then
        self.juiceObj.pos = tbl.pos or vec2(self.x, self.y)
        
        self.size = tbl.size or self.size
        
        if tbl.updateDrawSize then
            self.juiceObj.w, self.juiceObj.h = (tbl.size.x or self.size.x), (tbl.size.y or self.size.y)
        end
    end
end

function JuiceButton:draw()
    pushStyle()
    
    if self.pressed then
        self.juiceObj.tint = self.tint
    else
        self.juiceObj.tint = nil
    end
    
    self.juiceObj:draw()
    
    if self.glow ~= nil then
        for i, glow in ipairs(self.glow) do
            glow:draw()
        end
    end
    
    if self.juiceObj.pos ~= vec2(self.x, self.y) then
        self:update{ pos = vec2(self.x, self.y) }
    end
    
    popStyle()
end


TextButton = class()

function TextButton:init(txt, x, y, callback)
    self.txt = txt
    self.x = x
    self.y = y
    self.callback = callback
    self.pressed = false
    self.fontSize = 100
    self.fill = topCol
    self.tint = color(185, 185, 185, 255)
    self.mode = CENTER
end

function TextButton:left()
    if self.mode == CORNER then
        return self.x
    else
        return self.x - self.w/2
    end
end

function TextButton:right()
    if self.mode == CORNER then
        return self.x + self.w
    else
        return self.x + self.w/2
    end
end

function TextButton:bot()
    if self.mode == CORNER then
        return self.y
    else
        return self.y - self.h/2
    end
end

function TextButton:top()
    if self.mode == CORNER then
        return self.y + self.h
    else
        return self.y + self.h/2
    end
end

function TextButton:draw()
    pushStyle()
    
    local tbtc, scol
    if self.pressed then
        fill(self.tint)
        tbtc, scol = self.tint, self.fill
    elseif self.fill ~= nil then
        fill(self.fill)
        tbtc, scol = self.fill, self.tint
    end
    
    textWrapWidth(WIDTH) textAlign(CENTER) textMode(self.mode)
    fontSize(self.fontSize) font(STANDARDFONT)
    self.w, self.h = textSize(self.txt)
    text(self.txt, self.x, self.y)

    popStyle()
end

function TextButton:touched(touch)
    if touch.x > self:left() and touch.x < self:right() and
    touch.y > self:bot() and touch.y < self:top() then
        if touch.state == BEGAN or touch.state == MOVING then
            self.pressed = true
        elseif touch.state == ENDED then
            self.pressed = false
            self.callback()
            if not self.silent then
                sound("Game Sounds One:Block 1")
            end
        end
    else
        self.pressed = false
    end
end


