--Created by Briarfox 
StatusBar = class()

function StatusBar:init()
    -- Accept and set parameters here.
    parameter.boolean("ShowStatusBar", self:readState(), self.saveState)
    --parameter.action("ResetStatusBar", self.reset)

    self.x = readProjectData("statusBarX") or WIDTH/2
    self.y = readProjectData("statusBarY") or HEIGHT/2

    self.fps = Fps(-110,0)
    self.clock = Clock(0,0)
    self.mem = Memory(110,0)
end

function StatusBar:readState()
    local state = readProjectData("StatusBarState")
    if state == nil then state = true end
    return state
end

function StatusBar:saveState()
    saveProjectData("StatusBarState", ShowStatusBar)
end

function StatusBar:reset()
    clearProjectData()
    print("ResetStatusBar takes effect after restart.")
end

function StatusBar:draw()
    if ShowStatusBar then 
        pushMatrix()
        translate(self.x, self.y)

        self.fps:draw()
        self.clock:draw()
        -- self.mem:draw()

        popMatrix()
    end
end

function StatusBar:touched(touch)
    if ShowStatusBar then
        if touch.state == BEGAN and touch.x < (self.x + 165) and touch.x > (self.x - 165) then
            if touch.y > (self.y - 15) and touch.y < (self.y + 15) then
                self.moving = true
            end
        end

        if touch.state == MOVING and self.moving then
            if touch.y + 15 < HEIGHT and touch.y - 15 > 0 and touch.x + 165 < WIDTH and touch.x - 165 > 0 then
                self.x = touch.x
                self.y = touch.y
            end
        end

        if touch.state == ENDED then
            if self.moving then self.moving = false end
            saveProjectData("statusBarX",self.x)
            saveProjectData("statusBarY",self.y) 
        end
    end
end




--Original Code from Jvm38
-------------------FPS CLASS
Fps = class()

function Fps:init(x, y)
    -- Accept and set parameters here.
    self.x = x
    self.y = y

    self.curr = 60
    self.currTime = ElapsedTime
    self.min = 60
    self.minTime = ElapsedTime

    self.frac = .05 --framerate smoothing
end

function Fps:draw()
    self:update()

    pushStyle()

    strokeWidth(0)
    fill(102, 108, 104, 193)
    rectMode(CENTER)
    rect(self.x, self.y, 110, 30)

    font("Optima-Regular")
    fontSize(16)
    fill(213, 215, 219, 255)
    text("FPS: "..self.txt, self.x, self.y)

    popStyle()
end

function Fps:update()
    local old = self.curr
    local new = 1 / DeltaTime or old

    if self.min > new then
        self.min = new
        self.minTime = ElapsedTime + 1
    end
    if self.minTime < ElapsedTime then
        self.min = 60
    end

    self.curr = old * (1 - self.frac) + new * self.frac

    self.txt = tostring(math.floor(self.curr)).." (> "..tostring(math.floor(self.min))..")"
end



--Original Code from Jvm38
------CLOCK CLASS

Clock = class()

function Clock:init(x,y)
    -- you can accept and set parameters here
    --parameter.integer("fpsVisible",0,1,1)
    -- you can accept and set parameters here
    self.x = x
    self.y = y
    self.time = self:update()
end

function Clock:draw()
    -- Codea does not automatically call this method
    
    pushStyle()
    rectMode(CENTER)
    strokeWidth(0)
    fill(102, 108, 104, 193)
    rect(self.x,self.y,110,30)
    textMode(CENTER)
    font("Optima-Regular")
    fontSize(16)
    fill(213, 215, 219, 255)
    text(self.time,self.x,self.y)
    
    popStyle()
    
end

function Clock:touched(touch)
    -- Codea does not automatically call this method
end

function Clock:update()
    local t = os.date("*t")
    local txt
    if t.min < 10 then txt = tostring(t.hour)..":0"..tostring(t.min)
    else txt = tostring(t.hour)..":"..tostring(t.min)
    end
    return txt
end

function Clock:setPos(x,y)
    self.x = x
    self.y = y 
end


--Original Code from Jvm38
-----Memory Class
Memory = class()

function Memory:init(x, y)
    -- Accept and set parameters here.
    self.x = x
    self.y = y
end

function Memory:draw()
    self:update()

    pushStyle()

    strokeWidth(0)
    fill(102, 108, 104, 193)
    rectMode(CENTER)
    rect(self.x, self.y, 110, 30)

    font("Optima-Regular")
    fontSize(16)
    fill(213, 215, 219, 255)
    text("Mem: "..self.txt, self.x, self.y)

    popStyle()
end

function Memory:update()
    local kb = math.floor(gcinfo() / 10) * 10
    self.txt = tostring(kb).." kb"
    collectgarbage()
end
