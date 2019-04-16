GlowLine = class()

function GlowLine:init(pos1,pos2,width)
    -- you can accept and set parameters here
    local width = wScale(width)
    self.m = mesh()
    self.pos1 = pos1
    self.pos2 = pos2
    self.m.shader = shader(shadr.vS,shadr.fS)
    self.m.shader.color = themeColors[selectedTheme].glow or vec4(0, 2, 2, 2)
    local d = (pos1-pos2)
    self.m.shader.len = d:len()/5
    self.r = self.m:addRect(pos1.x-d.x/2,pos1.y-d.y/2,d:len(),width*5,angleOfPoint(d)/mp)
    self.width = width
end

function GlowLine:setPositions(pos1,pos2)
    self.pos1 = pos1
    self.pos2 = pos2
    local d = (pos1-pos2)
    self.m.shader.len = d:len()/5
    self.m:setRect(self.r,pos1.x-d.x/2,pos1.y-d.y/2,d:len(),self.width*5,angleOfPoint(d)/mp)
end

function GlowLine:draw()
    self.m.shader.time = ElapsedTime*5
    self.m:draw()
end

function GlowLine:touched(touch)
    -- Codea does not automatically call this method
end



