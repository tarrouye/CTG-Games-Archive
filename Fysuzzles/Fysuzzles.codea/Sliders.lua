Slider = class()

function Slider:init(variable, min, max, init, initN, x, y, callback, label)
    self.touch = CurrentTouch
    self.off = vec2(0,0)
    self.variable = variable
    self.label = label or variable
    self.x, self.y = x, y
    self.min, self.max = min, max
    self.prevValue, self.curValue = init, init
    self.curVN = initN
    self.callback = callback
    self.length = 250
    self.circleSize, self.botSize, self.topSize, self.circleStrokeSize = wScale(30), wScale(10), wScale(15), 2
    self.sliderX = (self.x - self.length/2) + (self.length / (self.max - 1)) * (self.curValue - 1)
    self.textFill = color(255, 255, 255, 255)
    self.baseFill, self.filledFill, self.circleFill = color(127), color(255), color(40)
    self.fontSize, self.font = wScale(20), STANDARDFONT
    self:updateValue()
end

function Slider:draw()
    pushStyle()
    strokeWidth(self.botSize) stroke(self.baseFill)
    line(self.x - self.length/2 - 10 + strokeWidth()/2, self.y, self.x + self.length/2 + 10 - strokeWidth()/2, self.y)
    strokeWidth(self.topSize) stroke(self.filledFill)
    line(self.x - self.length/2 - 10 + strokeWidth()/2, self.y, self.sliderX, self.y)
    strokeWidth(self.circleStrokeSize) stroke(self.filledFill) 
    if self.touching then fill(self.filledFill) else fill(self.circleFill) end
    ellipse(self.sliderX, self.y, self.circleSize)
    fill(self.textFill) fontSize(self.fontSize) font(self.font)
    local w,h = textSize(self.curVN)
    text(self.curVN, self.x + self.length/2 + self.circleSize/2 - w/2, self.y + self.circleSize/2 + h/2)
    local w,h = textSize(self.label)
    text(self.label, self.x - self.length/2 - self.circleSize/2 + w/2, self.y + self.circleSize/2 + h/2)
    local w,h = textSize(self.first)
    text(self.first, self.x - self.length/2 - w/2 - self.circleSize/2, self.y)
    local w,h = textSize(self.last)
    text(self.last, self.x + self.length/2 + w/2 + self.circleSize/2, self.y)
    popStyle()

    if self.touching then
        local t = { x = CurrentTouch.x + self.off.x, y = CurrentTouch.y }
        self:moveSlider(t)
    end
end

function Slider:touched(touch)
    if touch.x > self.sliderX - self.circleSize/2 and touch.x < self.sliderX + self.circleSize/2
    and touch.y > self.y - self.circleSize/2 and touch.y < self.y + self.circleSize/2 then
        self.touching = true
    end
    
    if touch.state == ENDED then
        self.touching = false
        self.sliderX = (self.x - self.length/2) + 
            (self.length / (self.max - 1)) * (self.curValue - 1)
    end
end



TableSlider = class()

function TableSlider:init(variable, table, init, x, y, callback, show, label)
    self.table = table
    if show then self.first, self.last = table[1], table[#table]
    else self.first, self.last = "", "" end
    Slider.init(self, variable, 1, #table, init, table[1], x, y, callback, label)
end

function TableSlider:draw()
    Slider.draw(self)
end

function TableSlider:touched(touch)
    Slider.touched(self, touch)
end

function TableSlider:moveSlider(touch)
    touch = touch or CurrentTouch
    self.sliderX = math.max(math.min(touch.x, self.x + self.length/2), self.x - self.length/2)
    self.curValue = math.floor((((self.sliderX - (self.x - self.length/2)) / self.length) 
            * (self.max - 1) + 1) + 0.49)
    if self.curValue ~= self.prevValue then
        self:updateValue()
        self.prevValue = self.curValue
        if self.callback ~= nil then
            self.callback()
        end
    end
end

function TableSlider:updateValue()
    self.curVN = self.table[self.curValue]
    _G[self.variable] = self.table[self.curValue]
end



IntegerSlider = class()

function IntegerSlider:init(variable, min, max, init, x, y, callback, show, label)
    if show then self.first, self.last = min, max
    else self.first, self.last = "", "" end
    Slider.init(self, variable, min, max, init, init, x, y, callback, label)
end

function IntegerSlider:draw()
    Slider.draw(self)
end

function IntegerSlider:touched(touch)
    Slider.touched(self, touch)
end

function IntegerSlider:moveSlider(touch)
    touch = touch or CurrentTouch
    self.sliderX = math.max(math.min(touch.x, self.x + self.length/2), self.x - self.length/2)
    self.curValue = math.floor((((self.sliderX - (self.x - self.length/2)) / self.length) 
            * (self.max - 1) + 1) + 0.49)
    if self.curValue ~= self.prevValue then
        self:updateValue()
        self.prevValue = self.curValue
        if self.callback ~= nil then
            self.callback()
        end
    end
end

function IntegerSlider:updateValue()
    self.curVN = self.curValue
    _G[self.variable] = self.curValue
end



