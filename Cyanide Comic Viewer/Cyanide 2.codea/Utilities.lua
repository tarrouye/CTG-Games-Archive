SwipeDetector = class()

function SwipeDetector:init()
    self.beganX, self.beganY = 0, 0
    self.endX, self.endY = 0, 0
    self.swipeID = nil
    self.swipe = nil
    self.swipeLength = 0
    
    self.swipeTime = 0.5
end

function SwipeDetector:touched(touch)
    if touch.state == BEGAN then
        self.swipe = nil
        self.swipeTimer = ElapsedTime
        self.swipeID = touch.id
        self.beganX = touch.x 
        self.beganY = touch.y
    elseif touch.state == ENDED and self.swipeID == touch.id 
        and (ElapsedTime - self.swipeTimer) <= self.swipeTime then
        self.endX = touch.x 
        self.endY = touch.y
        
        if math.abs(self.endX - self.beganX) < 100 then
            if self.beganY - self.endY > 30 then
                self.swipe = vec2(0, -1)
            end
            if self.endY - self.beganY > 30 then 
                self.swipe = vec2(0, 1)
            end
            self.swipeLength = math.abs(self.endY - self.beganY)
        end
        if math.abs(self.endY - self.beganY) < 100 then
            if self.beganX - self.endX > 30 then
                self.swipe = vec2(-1, 0)
            end
            if self.endX - self.beganX > 30 then  
                self.swipe = vec2(1, 0)
            end
            self.swipeLength = math.abs(self.endX - self.beganX)
        end
        
        self.swipeID = nil
    end
end

----- Zoom Class by @Herwig -----

Zoom = class()

function Zoom:init(x,y)
    -- you can accept and set parameters here
    self.touches = {}
    self.initx=x or 0;
    self.inity=y or 0;
    self:clear()
    --self:readLocalData()
    print("Tap and drag to move\nPinch to zoom\nDouble tap to reset zoom")
end

function Zoom:saveLocalData()
    saveLocalData("Zoom_center_x",self.center.x)
    saveLocalData("Zoom_center_y",self.center.y)
    saveLocalData("Zoom_offset_x",self.offset.x)
    saveLocalData("Zoom_offset_y",self.offset.y)
    saveLocalData("Zoom_zoom",self.zoom)
end

function Zoom:readLocalData()
    self.center.x=readLocalData("Zoom_center_x",self.center.x) or self.center.x
    self.center.y=readLocalData("Zoom_center_y",self.center.y) or self.center.y
    self.offset.x=readLocalData("Zoom_offset_x",self.offset.x) or self.offset.x
    self.offset.y=readLocalData("Zoom_offset_y",self.offset.y) or self.offset.y
    self.zoom=readLocalData("Zoom_zoom",self.zoom) or self.zoom
end

function Zoom:clear()
    self.lastPinchDist = 0
    self.pinchDelta = 1.0
    self.center = vec2(self.initx,self.inity)
    self.offset = vec2(0,0)
    self.zoom = 1
    self.started = false
    self.started2 = false
end

function Zoom:touched(touch)
    -- Codea does not automatically call this method
    if touch.state == ENDED or touch.state == CANCELLED then
        self.touches[touch.id] = nil
        self:saveLocalData()
    else
        self.touches[touch.id] = touch
        if (touch.tapCount==2) then
            self:clear()
        end
    end
end

function Zoom:processTouches()
    local touchArr = {}
    for k,touch in pairs(self.touches) do
        -- push touches into array
        table.insert(touchArr,touch)
    end

    if #touchArr == 2 then
        self.started = false
        local t1 = vec2(touchArr[1].x,touchArr[1].y)
        local t2 = vec2(touchArr[2].x,touchArr[2].y)

        local dist = t1:dist(t2)
        if self.started2 then
        --if self.lastPinchDist > 0 then 
            self.pinchDelta = dist/self.lastPinchDist          
        else
            self.offset= self.offset + ((t1 + t2)/2-self.center)/self.zoom
            self.started2 = true
        end
        self.center = (t1 + t2)/2
        self.lastPinchDist = dist
    elseif (#touchArr == 1) then
        self.started2 = false
        local t1 = vec2(touchArr[1].x,touchArr[1].y)
        self.pinchDelta = 1.0
        self.lastPinchDist = 0
        if not(self.started) then
            self.offset = self.offset + (t1-self.center)/self.zoom
            self.started = true
        end
        self.center=t1
    else
        self.pinchDelta = 1.0
        self.lastPinchDist = 0
        self.started = false
        self.started2 = false
    end
end

function Zoom:clip(x,y,w,h)
    clip(x*self.zoom+self.center.x- self.offset.x*self.zoom,
        y*self.zoom+self.center.y- self.offset.y*self.zoom,
        w*self.zoom+1,h*self.zoom+1)
end

function Zoom:text(str,x,y)
    local fSz = fontSize()
    local xt=x*self.zoom+self.center.x- self.offset.x*self.zoom
    local yt=y*self.zoom+self.center.y- self.offset.y*self.zoom
    fontSize(fSz*self.zoom)
    local xtsz,ytsz=textSize(str)
    tsz=xtsz
    if tsz<ytsz then tsz=ytsz end
    if (tsz>2048) then
        local eZoom= tsz/2048.0
        fontSize(fSz*self.zoom/eZoom)
        pushMatrix()
        resetMatrix()
        translate(xt,yt)
        scale(eZoom)
        text(str,0,0)
        popMatrix()
        fontSize(fSz)
    else
        pushMatrix()
        resetMatrix()
        fontSize(fSz*self.zoom)
        text(str,xt,yt)
        popMatrix()
        fontSize(fSz)
    end
end

function Zoom:draw()
    -- compute pinch delta
    self:processTouches()
    -- scale by pinch delta
    self.zoom = math.max( self.zoom*self.pinchDelta, 1 )
    
    local nemant = -WIDTH * (self.zoom - 1)
    local xtrans = math.max(math.min((self.center.x- (self.offset.x*self.zoom)), 0), nemant)
    local hemant = -HEIGHT * (self.zoom - 1)
    local ytrans = math.max(math.min((self.center.y- (self.offset.y*self.zoom)), 0), hemant)
    
    translate(xtrans, ytrans)
    
    scale(self.zoom,self.zoom)

    self.pinchDelta = 1.0
end

function Zoom:getWorldPoint(pt)
    return vec2(self.offset.x-(self.center.x- pt.x)/self.zoom,
        self.offset.y-(self.center.y- pt.y)/self.zoom)
end

function Zoom:getLocalPoint(pt)
    return vec2(pt.x*self.zoom+self.center.x- self.offset.x*self.zoom,
        pt.y*self.zoom+self.center.y- self.offset.y*self.zoom)
end

Button = class()

function Button:init(img, x, y, callback, size)
    self.img = img
    self.x = x
    self.y = y
    self.startX, self.startY = x, y
    self.size = size
    self.drawSize = self.size
    self.callback = callback
    self.pressed = false
    self.tint = color(127)
end

function Button:draw()
    pushStyle()
    --noSmooth()
    if self.pressed then
        tint(self.tint)
    end
    sprite(self.img, self.x, self.y, self.drawSize.x, self.drawSize.y)
    popStyle()
end

function Button:touched(touch)
    if touch.x > self.x - self.size.x/2 and touch.x < self.x + self.size.x/2 and
    touch.y > self.y - self.size.y/2 and touch.y < self.y + self.size.y/2 then
        if touch.state == BEGAN or touch.state == MOVING then
            self.pressed = true
        elseif touch.state == ENDED then
            self.pressed = false
            self.callback()
        end
    else
        self.pressed = false
    end
end