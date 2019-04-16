TextButton = class()

function TextButton:init(txt, x, y, callback, fs, col1, col2)
    self.txt = txt or "button"
    self.x = x or 0
    self.y = y or 0
    self.callback = callback or function() end
    self.pressed = false
    self.fontSize = fs or fontSize()
    self.fill = col1 or color(40, 200)
    self.tint = col2 or color(255, 200)
end

function TextButton:draw()
    pushStyle()
    if self.pressed then
        fill(self.tint)
    elseif self.fill ~= nil then
        fill(self.fill)
    end
    fontSize(self.fontSize)
    self.w, self.h = textSize(self.txt)
    text(self.txt, self.x, self.y)
    popStyle()
end

function TextButton:touched(touch)
    if touch.x > self.x - self.w/2 and touch.x < self.x + self.w/2 and
    touch.y > self.y - self.h/2 and touch.y < self.y + self.h/2 then
        if touch.state == BEGAN or touch.state == MOVING then
            self.pressed = true
        elseif touch.state == ENDED then
            self.pressed = false
            self.callback(self)
        end
    else
        self.pressed = false
    end
    
    return self.pressed
end
