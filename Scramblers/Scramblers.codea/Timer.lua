Timer = class()

function Timer:init(t, cb, x, y, s)
    self.time = t or 5
    self.callback = cb or function() end
    self.x = x or WIDTH / 2
    self.y = y or HEIGHT / 2
    self.size = s or HEIGHT * 5/6
    
    self.timing = nil
    self.beeping = nil
    self.amnt = 1
    self.beepTime = 10
    
    self.paused = false
    
    self.tMesh = mesh()
    self.tMesh.vertices = triangulate({vec2(-self.size / 2, -self.size / 2),
                        vec2(-self.size / 2, self.size / 2),
                        vec2(self.size / 2, self.size / 2),
                        vec2(self.size / 2, -self.size / 2)})
    self.tMesh.shader = shader("Patterns:Arc")
    self.tMesh.shader.a1 = math.pi
    self.tMesh.shader.a2 = math.pi
    self.tMesh.shader.size = .45
    self.tMesh.shader.color = vec4(0, 1, 0, 1)
    self.tMesh.texCoords = triangulate({vec2(0,0),vec2(0,1),vec2(1,1),vec2(1,0)})
end

function Timer:done()
    return (self.amnt == 1)
end

function Timer:beep()
    sound("Game Sounds One:Menu Select")
    
    self.beepTime = self.beepTime + 2
    
    self.beeping = tween.delay(self.time / self.beepTime, function() self:beep() end)
end

function Timer:start()
    self.amnt = 0
    self.beepTime = 10
    if self.timing == nil then
        self.timing = tween(self.time, self, { amnt = 1 }, tween.easing.linear, self.callback)
    end
    if self.beeping == nil then
        self.beeping = tween.delay(self.time / self.beepTime, function() self:beep() end)
    end
end

function Timer:pause()
    if self.timing ~= nil then
        tween.stop(self.timing)
    end
    if self.beeping ~= nil then
        tween.stop(self.beeping)
    end
    
    self.paused = true
end

function Timer:resume()
    if self.timing ~= nil then
        tween.play(self.timing)
    end
    if self.beeping ~= nil then
        tween.stop(self.beeping)
    end
    
    self.paused = false
end

function Timer:stop()
    if self.timing ~= nil then
        tween.stop(self.timing)
        self.timing = nil
    end
    if self.beeping ~= nil then
        tween.stop(self.beeping)
        self.beeping = nil
    end
end

function Timer:restart()
    self:stop()
    self:start()
end

function Timer:draw()
    -- Update timer
    self.tMesh.shader.color = vec4(1 * self.amnt, 1 - (1 * self.amnt), 0, 1)
    self.tMesh.shader.a2 = -self.amnt * (math.pi * 2) + math.pi
    
    -- Draw timer
    pushMatrix()
    
    translate(self.x, self.y)
    
    rotate(270.1)
    
    self.tMesh:draw()
    
    popMatrix()
end