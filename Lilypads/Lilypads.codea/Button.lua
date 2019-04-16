CircleButton = class()

function CircleButton:init(txt, x, y, size, col, col2, cb, fs)
    self.txt, self.x, self.y, self.size, self.bColour, self.tColour = txt, x, y, size or 0, col, col2

    local cbfs = (self.size / 7) fontSize(cbfs)
    local w, h = textSize(self.txt)
    while w > (self.size * 0.85) do
        cbfs = cbfs * 0.9 fontSize(cbfs)
        w, h = textSize(self.txt)
    end
    
    self.alpha = 255
    
    self.fontsize = fs or cbfs
    
    self.touching, self.callback = nil, cb or function() end
end

function CircleButton:expand(tbl)
    self.preExpanding = { x = self.x, y = self.y, size = self.size, fontsize = self.fontsize }
    
    local tbl = tbl or {}
    local target = { x = tbl.x or WIDTH / 2, y = tbl.y or HEIGHT / 2, size = tbl.size or math.sqrt(WIDTH^2 + HEIGHT^2) * 2, fontsize = tbl.fontsize or self.fontsize }
    
    local cb = tbl.callback or function() end
    
    self.expanding = tween(0.35, self, target, tween.easing.linear, function() self.expanded = true self.expanding = nil cb() end)
end

function CircleButton:unexpand(cb)
    if self.exanding then
        tween.stop(self.expanding)
    end
    
    cb = cb or function() end
    
    self.expanding = tween(0.35, self, self.preExpanding, tween.easing.linear, function() self.expanded = false self.expanding = nil cb() end)
end

function CircleButton:draw(alpha, scaleFactor)
    if self.disabled then return end
    
    pushMatrix()
    translate(self.x, self.y)
    
    if self.touching and not self.expanded then
        fill(self.bColour.r / 2, self.bColour.g / 2, self.bColour.b / 2, self.alpha)
    else
        fill(self.bColour.r, self.bColour.g, self.bColour.b, self.alpha)
    end
    ellipse(0, 0, self.size)
    
    fill(self.tColour.r, self.tColour.g, self.tColour.b, self.alpha) fontSize(self.fontsize)
    text(self.txt)
        
    noTint()
    popMatrix()
end

function CircleButton:touched(touch)
    if self.disabled then return end
    
    local t = vec2(touch.x, touch.y)
    if (t:dist(vec2(self.x, self.y)) <= self.size / 2) then
        if touch.state == BEGAN or touch.state == MOVING then
            if not globalTouches[touch.id] then
                globalTouches[touch.id] = true
                self.touching = touch.id
            end
        elseif self.touching then
            self.callback()
            
            if self.touching then
                globalTouches[self.touching] = false
            end
            self.touching = false
        end
    elseif touch.id == self.touching then
        globalTouches[self.touching] = false
        self.touching = false
    end
end

