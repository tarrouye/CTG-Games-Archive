SceneManager = class()

function SceneManager:init(tran, time)
    self.viewx, self.fade = 0, 0
    self.transitioning = false
    
    self.transitionType = tran or 1
    self.transitionTime = time
    
    self.transitions = { { func = self.slideTransition, time = 0.75 } , 
                         { func = self.fadeTransition, time = 2 } 
                       }

    self:addScene("__i", {})    -- Create blank instance in case no scenes are added
end

function SceneManager:addScene(id, inst, alreadyInitiated)
    if not self.scenes then self.scenes = {} end
    
    self.scenes[id] = inst
    
    if self.scenes[id].init and not alreadyInitiated then
        self.scenes[id]:init()
    end
    
    if self.currentScene == nil then
        self.currentScene = id
    end
end

function SceneManager:removeScene(id)
    self.scenes[id] = nil
    
    collectgarbage()
end


--Change scene
function SceneManager:change(name, type)
    if self.scenes[name] ~= nil and not self.transitioning then
        self:transition(name, type)
    end
end

function SceneManager:transition(name, type)
    if self.scenes[name] ~= nil then
        self.nextScene = name
        self.transitioning = true
        
        local tranType = type or self.transitionType
           
        local time = self.transitionTime or self.transitions[tranType].time
        self.transitions[tranType].func(self, time)
    end
end

function SceneManager:slideTransition(time)
    if self.scenes[self.nextScene].onEnter then
        self.scenes[self.nextScene]:onEnter()
    end
    
    tween(time, self, {viewx = -WIDTH}, tween.easing.bounceOut, 
    function()
        self:trueChange()
    end)
end

function SceneManager:fadeTransition(time)
    --[[local prevVolume = music.volume
    tween(time/2, music, {volume = 0}, tween.easing.linear,
    function() tween(time/2, music, {volume = prevVolume}, tween.easing.linear) end)--]]
    
    tween(time/2, self, {fade = 1}, tween.easing.linear,
    function()
        self:trueChange()
        
        if self.scenes[self.currentScene].onEnter then
            self.scenes[self.currentScene]:onEnter()
        end
        
        tween(time/2, self, {fade = 0}, tween.easing.linear)
    end)
end

function SceneManager:trueChange()
    if self.scenes[self.currentScene].onExit then
        self.scenes[self.currentScene]:onExit()
    end
    
    collectgarbage()
    
    self.currentScene = self.nextScene

    self.nextScene = nil
    self.transitioning = false
    
    self.viewx = 0
    
    collectgarbage()
end


function SceneManager:draw()
    pushStyle()
    pushMatrix()
    
    translate(self.viewx, 0)
    
    if self.scenes[self.currentScene].draw then
        self.scenes[self.currentScene]:draw()
    end
    
    translate(WIDTH, 0)
    
    if self.nextScene ~= nil and self.scenes[self.nextScene].draw then
        self.scenes[self.nextScene]:draw()
    end
    
    pushStyle()
    strokeWidth(5) stroke(0)
    line(0, 0, 0, HEIGHT)
    popStyle()
    
    popMatrix()
    popStyle()
    
    pushStyle()
    fill(0, 255*self.fade) noStroke()
    rect(-1, -1, WIDTH + 2, HEIGHT + 2)
    popStyle()
end

function SceneManager:touched(t)
    if not self.transitioning and self.scenes[self.currentScene].touched then
        self.scenes[self.currentScene]:touched(t)
    end
end

function SceneManager:keyboard(k)
    if self.scenes[self.currentScene].keyboard then
        self.scenes[self.currentScene]:keyboard(k)
    end
end

function SceneManager:orientationChanged(o)
    if self.scenes[self.currentScene].orientationChanged then
        self.scenes[self.currentScene]:orientationChanged(o)
    end
end

function SceneManager:collide(c)
    if self.scenes[self.currentScene].collide then
        self.scenes[self.currentScene]:collide(c)
    end
end


function maxn(t)
    local amnt = 0
    if type(t) == "table" then
        for i,v in pairs(t) do
            amnt = amnt + 1
        end
    end
    
    return amnt
end



