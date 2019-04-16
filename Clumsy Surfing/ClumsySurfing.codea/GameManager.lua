GameManager = class()

function GameManager:init()
    self.back = Background()
    
    self.waves = Waves()
    
    self.startButton = TextButton("SURF'S UP", WIDTH / 2, HEIGHT / 2, function() self:surf() end, MIN_DIMENSION / 5)
    self.quitButton = TextButton("I CAN'T TAKE IT ANYMORE", WIDTH / 2, HEIGHT / 64, function() Scene:change("title") end, HEIGHT / 32)
    
    self.player = Player(WIDTH / 2, HEIGHT -25)
        
    self.started = false
end

function GameManager:reset()
    self.player:reset()
    self.waves.speedMult = 1
end

function GameManager:start()
    self.started = true
end

function GameManager:surf()
    if not self.player.alive then
        self:reset()
    end
    
    self:start()
end

function GameManager:draw()
    self.back:draw(self.waves.speedMult)
    
    self.waves:draw(self.player)
    self.waves:waveCollide(self.player)
    
    if self.started then
        self.player:draw()
    end
    
    if not self.player.alive or not self.started then 
        self.startButton:draw()
        self.quitButton:draw()
    end
    
    DebugDraw:draw()
    JOYSTICKS:draw()
end

function GameManager:touched(t)
    local dd = false 
    if self.started then
        if self.player.alive then
            JOYSTICKS:touched(t)
        else
            dd = DebugDraw:touched(t)
        end
    end
    
    if not dd and (not self.player.alive or not self.started) then 
        self.startButton:touched(t)
        self.quitButton:touched(t)
    end
end
