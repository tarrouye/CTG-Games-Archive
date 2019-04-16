-- juice
juice = {}

juice.move = class()

function juice.move:init(p, a, s)
    self.pos = p or vec2(0,0)
    self.angle = a or 0
    self.scale = s or vec2(1,1)
end

function juice.move:combine(m)
    return juice.move(
        self.pos + m.pos,
        self.angle + m.angle,
        vec2(self.scale.x * m.scale.x,
             self.scale.y * m.scale.y)
        )
end


    
-- juiceobject
juice.object = class()

function juice.object:init()
    -- you can accept and set parameters here
    self.fill = color(255)
    self.stroke = color(0,0,0,0)
    self.strokeWidth = 3
    self.smooth = false
    self.alpha = 1.0
    self.pos = vec2(0,0)
    self.angle = 0
    self.scale = vec2(1,1)
    self.moves = {}
    self.moveKey = 0
    self.lastMoveCache = juice.move()
end

function juice.object:fixAngleRange()
    self.angle = self.angle % 360
end

function juice.object:addMove(p, a, s)
    local m = juice.move(p,a,s)
    local mk = self.moveKey
    
    self.moves[mk] = m
    
    self.moveKey = mk+1
    
    return m, mk
end

function juice.object:startMove()
    return self:addMove()
end

function juice.object:applyMove(m)
    self.pos = self.pos + m.pos
    self.angle = self.angle + m.angle
    self.scale = vec2(self.scale.x * m.scale.x, 
                      self.scale.y * m.scale.y)
end

function juice.object:finishMove(mk)
    local m = self.moves[mk]
    
    self:applyMove(m)
    
    self.moves[mk] = nil
end

function juice.object:setupStyle()
    pushStyle()
    
    if self.tint == nil then
        tint( self.fill.r, self.fill.g, self.fill.b,
              self.fill.a * self.alpha )
    else
        tint(self.tint)
    end
    
    fill( self.fill.r, self.fill.g, self.fill.b, 
          self.fill.a * self.alpha )
        
    stroke( self.stroke.r, self.stroke.g, self.stroke.b,
            self.stroke.a * self.alpha )
            
    strokeWidth(self.strokeWidth)
            
    if self.smooth then
        smooth()
    else
        noSmooth()
    end
    
    blendMode(NORMAL)
    
    spriteMode(CENTER)
    rectMode(CENTER)
    ellipseMode(CENTER)
    textMode(CENTER)
end

function juice.object:finishStyle()
    popStyle()
end

function juice.object:getActualPosition()
    local p = self.pos
    
    for k,v in pairs(self.moves) do
        p = p + v.pos
    end
    
    return p
end

function juice.object:getActualAngle()
    local a = self.angle
    
    for k,v in pairs(self.moves) do
        a = a + v.angle
    end
    
    return a
end

function juice.object:getActualScale()
    local s = self.scale
    
    for k,v in pairs(self.moves) do
        s = vec2(s.x * v.scale.x, s.y * v.scale.y)
    end
    
    return s
end

function juice.object:setupTransform()
    pushMatrix()
    
    local p = self.pos
    local a = self.angle
    local s = self.scale
    
    for k,v in pairs(self.moves) do
        p = p + v.pos
        a = a + v.angle
        s = vec2(s.x * v.scale.x, s.y * v.scale.y)
    end
    
    self.lastMoveCache = juice.move(p,a,s)
    
    translate(p.x, p.y)
    rotate(a)
    scale(s.x, s.y)
end

function juice.object:finishTransform()
    popMatrix()
end

function juice.object:startDraw()
    juice.object.setupTransform(self)
    juice.object.setupStyle(self)
end

function juice.object:finishDraw()
    juice.object.finishStyle(self)
    juice.object.finishTransform(self)
end

function juice.object:draw()
    self:startDraw()
    
    self:drawObject()
    
    self:finishDraw()
end

function juice.object:size()
    return vec2(0,0)
end
-- juicemover
juice.mover = class(juice.object)

function juice.mover:init()
    juice.object.init(self)
    
    self.highlightAmount = 0
end

function juice.mover:spin(rotations, duration, easing, callback)    
    rotations = rotations or 3
    duration = duration or 0.5
    easing = easing or tween.easing.quadOut
    
    local a = self.angle - 360 * rotations
    
    self:rotateTo(a, duration, easing,
        function()
            if callback then callback(self) end
            self:fixAngleRange()            
        end)
end

function juice.mover:bounce(height, hold, call1, call2)
    height = height or 100
    hold = hold or 0.1
    
    local m,mk = self:startMove()
    
    local savedScale = m.scale
    local savedPos = m.pos
    local squash = vec2(m.scale.x * 1.5, m.scale.y * 0.75)
    local moveDown = savedPos.y - self:size().y/2 * (1 - squash.y)
    
    tween(0.15, m, {scale = squash}, tween.easing.quadInOut)
    tween(0.15, m, {pos = vec2(0, moveDown)}, tween.easing.quadInOut, 
        function()
            local moveUp = savedPos.y + height * 0.9
            local unsquash = vec2(savedScale.x * 0.85, savedScale.y * 1.25)
            
            tween(0.15, m, {scale = unsquash}, tween.easing.quadInOut)
            tween(0.2, m, {pos = vec2(0, moveUp)}, tween.easing.quadOut,
                function()
                    -- Reached top of jump
                    if call1 then call1(self) end
                    
                    local holdHeight = savedPos.y + height
                    tween(hold, m, {pos = vec2(0, holdHeight)}, tween.easing.linear,
                     function()
                        tween(0.15, m, {scale = savedScale}, tween.easing.quadInOut)
                        tween(0.15, m, {pos = savedPos}, tween.easing.quadIn,
                            function()
                                self:finishMove(mk)
                                if call2 then call2(self) end
                            end )
                     end)
                end )
            
        end )
end

-- Wobble functionality added by @JakAttak
function juice.mover:wobble(amount, time, speed)
    local m,mk = self:startMove()
    
    local originalSmoothValue = self.smooth
    self.smooth = true
    
    local amount = amount or 2
    
    local t = 0.15 * math.abs((m.angle - -amount))
    if speed ~= nil then
        t = speed / 2
    end
    
    local time = time or math.huge
    local speed = speed or 0.15 * amount

    m.wobbling = tween(t, m, {angle = -amount}, tween.easing.linear, 
    function()
        m.wobbling = tween(speed, m, {angle = amount}, {easing = tween.easing.linear, 
                                                        loop = tween.loop.pingpong})
    end)

    tween.delay(time, 
    function() 
        tween.stop(m.wobbling)
        
        tween(0.025, m, {angle = 0}, tween.easing.linear, 
        function()
            self.smooth = originalSmoothValue
            self:finishMove(mk)
        end)
    end)
end

function juice.mover:pulse(amount, repeats, time, hold, call1, call2)
    local s = self.scale
    if type(amount) == "number" then
        amount = vec2(amount + s.x, amount + s.y)
    else
        amount = amount or vec2(0.3, 0.3)
        amount = amount + s
    end
    
    local originalSmoothValue = self.smooth
    self.smooth = true
    
    local m,mk = self:startMove()
    
    time = time or 0.15
    hold = hold or 0
    repeats = repeats or 1
    call1 = call1 or function() end
    call2 = call2 or call1
    
    tween(time, m, {scale=amount}, tween.easing.quadIn,
        function() 
            call1(self)
            tween.delay(hold, function()
                tween(time, m, {scale=s}, tween.easing.quadOut,
                    function()
                        call2(self)
                        self.smooth = originalSmoothValue
                        self:finishMove(mk)
                        if repeats > 1 or repeats < 0 then
                            self:pulse(amount - vec2(1,1), repeats - 1, 
                                       time, hold, call1, call2)
                        end
                    end)
            end)
        end)
end

function juice.mover:squash(amount, hold, duration, call1, call2)
    duration = duration or 0.3
    local d = duration/2
    amount = amount or 0.5
    hold = hold or 0.1
    
    local m,mk = self:startMove()
    
    local sx = (1 + amount)
    local sy = (1 - amount * 0.5)
    local sz = self:size()
    
    local savedScale = m.scale
    local savedPos = m.pos
    local squash = vec2(sx * 0.9, sy * 0.9)
    
    local diff = (sz.y - (sz.y * squash.y))/2
    local moveDown = savedPos.y - diff
    
    tween(d, m, {pos = vec2(0,moveDown)}, tween.easing.quadOut)
    tween(d, m, {scale = squash}, tween.easing.quadOut,
      function()
        if call1 then call1(self) end
        local diff = (sz.y - (sz.y * sy))/2
        local moveDown = savedPos.y - diff
        tween(hold, m, {pos = vec2(0,moveDown)}, tween.easing.quadOut)
        tween(hold, m, {scale = vec2(sx,sy)}, tween.easing.quadOut,
          function()
            tween(d, m, {pos = savedPos}, tween.easing.backOut)
            tween(d, m, {scale = savedScale}, tween.easing.backOut,
              function()
                self:finishMove(mk)
                if call2 then call2(self) end 
              end )
          end)
      end)
end

function juice.mover:knock(dir, duration, callback)
    duration = duration or 0.4
    dir = dir or vec2(-100, 0)
    self:moveBy(dir, duration, tween.easing.backOut, callback)
end

function juice.mover:fadeTo(a, duration, callback)
    duration = duration or 0.3
    
    tween(duration, self, {alpha = a}, tween.easing.linear,
      function()
        if callback then callback(self) end
      end )
end

function juice.mover:fadeOut(duration, callback)
    self:fadeTo(0, duration, callback)
end

function juice.mover:fadeIn(duration, callback)
    self:fadeTo(1, duration, callback)
end

function juice.mover:rotateTo(a, duration, easing, callback)
    duration = duration or 0.3
    easing = easing or tween.easing.quadInOut
    
    local m,mk = self:startMove()
    
    local dest = a - self.angle
    
    tween(duration, m, {angle=dest}, easing, 
      function()
        self:finishMove(mk)
        if callback then callback(self) end 
      end)
end

function juice.mover:rotateBy(a, duration, easing, callback)
    self:rotateTo(self.angle + a, duration, easing, callback)
end

function juice.mover:moveTo(p, duration, easing, callback)
    duration = duration or 0.3
    easing = easing or tween.easing.quadInOut
    
    local m,mk = self:startMove()
    
    local dest = p - self.pos
    
    tween(duration, m, {pos=dest}, easing,
        function()
            self:finishMove(mk)
            if callback then callback(self) end
        end)
end

function juice.mover:moveBy(p, duration, easing, callback)
    self:moveTo(self.pos + p, duration, easing, callback)
end

function juice.mover:scaleTo(s, duration, easing, callback)
    if type(s) == "number" then
        s = vec2(s, s)
    end
    
    duration = duration or 0.3
    easing = easing or tween.easing.quadInOut
    
    local m,mk = self:startMove()
    
    local as = self.scale
    local dest = vec2(s.x/as.x, s.y/as.y)
    
    tween(duration, m, {scale=dest}, easing,
        function()
            self:finishMove(mk)
            if callback then callback(self) end
        end )
end

function juice.mover:scaleBy(s, duration, easing, callback)
    self:scaleTo(self.scale + s, duration, easing, callback)
end

function juice.mover:flash(hold, repeats, call1, call2)
    hold = hold or 0
    repeats = repeats or 1
    
    local unflash = function()
            tween(0.15, self, {highlightAmount=0}, tween.easing.linear,
                function() 
                    if call2 then call2(self) end
                    if repeats > 1 or repeats < 0 then
                        self:flash(hold, repeats - 1, call1, call2)
                    end
                end)
        end
    
    tween(0.15, self, {highlightAmount=1}, tween.easing.linear,
        function() 
            if call1 then call1(self) end
            tween.delay(hold, unflash)
        end)
end

function juice.mover:draw()
    self:startDraw()
    
    self:drawObject()
    
    if self.highlightAmount > 0 then
        local hc = color(255,255,255,255*self.highlightAmount)
        
        blendMode(ADDITIVE)
        fill(hc)
        tint(hc)
        self:drawObject()
    end
    
    self:finishDraw()
end


-- juicetext
juice.text = class(juice.mover)

function juice.text:init(str, x, y)
    juice.mover.init(self)
    self.pos = vec2(x,y)
    
    self.string = str
    self.font = STANDARDFONT
    self.fontSize = 52
end

function juice.text:drawObject()
    font(self.font)
    fontSize(self.fontSize)
    
    textMode(CENTER)
    
    text(self.string, 0, 0)
end

function juice.text:size()
    pushStyle()
    
    font(self.font)
    fontSize(self.fontSize)
    
    local w,h = textSize(self.string)
    
    popStyle()
    
    return vec2(w,h)
end


-- juicesprite
juice.sprite = class(juice.mover)

function juice.sprite:init(tex, x, y, w, h)
    juice.mover.init(self)
    
    self.texture = tex
    self.pos = vec2(x,y)
    
    local szx,szy = spriteSize(tex)
    local aspect = szy / szx
    
    if w then
        self.w = w
        self.h = h or w * aspect
    else
        self.w = szx or 0
        self.h = szy or 0
    end
end

function juice.sprite:drawObject()
    sprite(self.texture, 0, 0, self.w, self.h)
end

function juice.sprite:size()
    return vec2(self.w, self.h)
end

-- juicerect
juice.rect = class(juice.mover)

function juice.rect:init(x, y, w, h)
    juice.mover.init(self)
    
    self.pos = vec2(x,y)
    
    self.w = w or 0
    self.h = h or w
end

function juice.rect:drawObject()
    rect(0, 0, self.w, self.h)
end

function juice.rect:size()
    return vec2(self.w, self.h)
end


-- juiceellipse
juice.ellipse = class(juice.mover)

function juice.ellipse:init(x, y, w, h)
    juice.mover.init(self)
    
    self.pos = vec2(x,y)
    
    self.w = w or 0
    self.h = h or w
end

function juice.ellipse:drawObject()
    ellipse(0, 0, self.w, self.h)
end

function juice.ellipse:size()
    return vec2(self.w, self.h)
end


