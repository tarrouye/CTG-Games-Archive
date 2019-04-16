SceneManager = class()

function SceneManager:init(tran, time)
    self.viewx, self.fade = 0, 0
    self.touchAllowed = true
    
    self.transitionType = tran or 1
    self.transitionTime = time
    
    self.transitions = { { func = self.slideTransition, time = 0.85 } , 
                         { func = self.fadeTransition, time = 2 } 
                       }

    --self:addScene("__i", function() end)    -- Create blank instance in case no scenes are added
end

function SceneManager:addScene(id, inst, track, alreadyInitiated)
    if not self.scenes then self.scenes = {} self.musics = {} end
    --print(id, inst)
    if not alreadyInitiated then
        self.scenes[id] = inst()
    else
        self.scenes[id] = inst
    end
    if track then
        self.musics[id] = track
    end
    
    if self.currentScene == nil then
        self.currentScene = id
    end
end

function SceneManager:start(name)
    self.currentScene = name
    if self.scenes[self.currentScene].onEnter then
        self.scenes[self.currentScene]:onEnter()
    end
    self.touchAllowed = true
    if self.musics[name] then
        music(self.musics[name], true)
    end
end


--Change scene
function SceneManager:change(name, type, time)
    if self.scenes[name] ~= nil then
        self:transition(name, type, time)
    end
end

function SceneManager:transition(name, type, tim)
    if self.scenes[name] ~= nil then
        if self.scenes[self.currentScene].onStartExit then
            self.scenes[self.currentScene]:onStartExit()
        end
        
        self.nextScene = name
        self.touchAllowed = false
        
        local tranType = type or self.transitionType
           
        local time = tim or self.transitionTime or self.transitions[tranType].time
        self:musicTransition(time)
        --print("Change to: ", name, type, time)
        self.transitions[tranType].func(self, time)
    end
end

function SceneManager:musicTransition(time)
    --print("music", time)
    local new = self.nextScene
    local prevVolume = music.volume
    if self.musics[new] and music.name ~= self.musics[new] then
        tween(time/2, music, {volume = 0}, tween.easing.linear, function() 
            if self.musics[new] and music.name ~= self.musics[new] then
                --print("actually changing music", self.musics[new])
                music(self.musics[new], true)
            end
            
            tween(time/2, music, {volume = prevVolume}, tween.easing.linear) 
        end)
    end
end

function SceneManager:slideTransition(time)
    if self.scenes[self.nextScene].onEnter then
        self.scenes[self.nextScene]:onEnter()
    end
    
    tween(time, self, {viewx = -WIDTH}, tween.easing.sineInOut, 
    function()
        self:trueChange()
        if self.scenes[self.currentScene].onFinishTrans then
            self.scenes[self.currentScene]:onFinishTrans()
        end
    end)
end

function SceneManager:fadeTransition(time)
    --print("Time: ", time)
    tween(time/2, self, {fade = 1}, tween.easing.linear,
    function()
        self:trueChange()
        
        --print("Current after true: ", self.currentScene)
        if self.scenes[self.currentScene].onEnter then
            self.scenes[self.currentScene]:onEnter()
        end
        
        --print("Time again: ", time / 2)
        tween(time/2, self, {fade = 0}, tween.easing.linear, function()
            --print("Inb4")
            if self.scenes[self.currentScene].onFinishTrans then
                self.scenes[self.currentScene]:onFinishTrans()
            end
        end)
    end)
end

function SceneManager:trueChange()
    if self.scenes[self.currentScene].onExit then
        self.scenes[self.currentScene]:onExit()
    end
    
    collectgarbage()
    
    --print("Next: ", self.nextScene, self.currentScene)
    self.currentScene = self.nextScene
    --print("Current: ", self.currentScene)

    self.nextScene = nil
    self.touchAllowed = true
    
    self.viewx = 0
    
    collectgarbage()
end


function SceneManager:draw()
    pushStyle()
    pushMatrix()
    
    translate(self.viewx, 0)
    clip(0, 0, WIDTH, HEIGHT)
    if self.scenes[self.currentScene].draw then
        self.scenes[self.currentScene]:draw()
    end
    clip()
    
    translate(WIDTH, 0)
    clip(0, 0, WIDTH, HEIGHT)
    if self.nextScene ~= nil and self.scenes[self.nextScene].draw then
        self.scenes[self.nextScene]:draw()
    end
    clip()
    
    popMatrix()
    popStyle()
    
    pushStyle() rectMode(CORNER)
    fill(0, 255*self.fade) noStroke()
    rect(-1, -1, WIDTH + 2, HEIGHT + 2)
    popStyle()
end

function SceneManager:touched(t)
    if self.touchAllowed and self.scenes[self.currentScene].touched then
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


