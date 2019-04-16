Game = class()

function Game:init()
    self.levels = (levelPacks[1] or { levels = {{{}}} }).levels
     
    self.transition = { cfade = 1, fade = 0, x = WIDTH / 2, y = 0, size = 0 }
    
    self.paused = false

    self.time = 0
    self.currentPack = 1
    self.currentLevel = 1
    
    self.board = Board()
    self.board:setSize(vec2(WIDTH, HEIGHT * 6/7))
    self.board:loadLevel(self.levels[self.currentLevel])
        
    self.buttons = {}
    self.buttons.pause = CircleButton("||", WIDTH * 3/4, HEIGHT / 7, WIDTH / 8, color(255, 0, 0), color(0), 
        function() self:togglePause() end)
    self.buttons.restart = CircleButton("r", WIDTH / 2, HEIGHT / 7, WIDTH / 8, color(255, 0, 0), color(0),
        function() self:restart() end)
    self.buttons.exit = CircleButton("x", WIDTH / 4, HEIGHT / 7, WIDTH / 8, color(255, 0, 0), color(0),
        function() self.finishedPack = true end)
end

function Game:runTransition(target, callback, initial, time)
    callback = callback or function() end
    initial = initial or {}
    
    -- Set intial values
    for id, value in pairs(initial) do
        self.transition[id] = value
    end
    
    -- Set tween in action
    self.transition.running = tween(time or 0.5, self.transition, target, tween.easing.linear, function()
        self.transition.running = nil
        callback()
    end)
end

function Game:restart()
    self:runTransition({ size = math.sqrt(WIDTH^2 + HEIGHT^2) * 2, x = WIDTH / 2, y = HEIGHT / 2 }, function()
        self:loadLevel(true)
        self.paused = true
        self:runTransition({ cfade = 0 }, function() 
            self.transition.cfade = 1 
            self.transition.size = 0
            self.transition.y = 0
            self.paused = false
        end)
    end, { x = WIDTH / 2, y = 0, size = 0, fade = 0, cfade = 1, colour = color(255) })
end

function Game:togglePause()
     if not self.paused then 
        self.buttons.pause:expand()
        self.paused = true
    else 
        self.buttons.pause:unexpand(function() self.paused = false end) 
    end
end

function Game:loadPack(pack)
    self.finishedPack = false
    self.currentPack = pack
    self.levels = levelPacks[pack].levels
end

function Game:loadLevel(donttransition)
    self.board:loadLevel(self.levels[self.currentLevel])
    self.paused = true
    self.time = 0
    
    local cb = function() self.paused = false self.setinmotion = false end
    if not donttransition then
        self:runTransition({ size = 0, fade = 0, y = 0 }, cb)
    else
        cb()
    end
end

function Game:saveLevelCompleted()
    completedLevels["Pack: " .. self.currentPack ..", Level: " .. self.currentLevel] = true
    saveLocalTable("completedLevels", completedLevels)
    
    if self.currentLevel == #self.levels then
        self.finishedPack = true
    end
end

function Game:draw()
    pushStyle()
    
    self.board:draw()
    
    if not self.paused then
        self.time = self.time + DeltaTime
    end
    
    fill(248, 255, 0, 255) noStroke()
    rect(0, 0, WIDTH, HEIGHT / 7)
    
    fill(255, 0, 0) fontSize(WIDTH / 15)
    text(formatTime(self.time), WIDTH / 4, HEIGHT / 14)
    for i, btn in pairs(self.buttons) do
        btn:draw()
    end
    
    if self.board.finished and not self.setinmotion then
        local bcol, btxt
        if self.board.finished == "success" then
            self:saveLevelCompleted()
            bcol = color(17, 255, 0, 255)
            btxt = "Success!"
            if self.currentLevel == #self.levels then
                btxt = btxt .. "\n\nCompleted last level of pack"
            end
        elseif self.board.finished == "failed" then
            bcol = color(255, 0, 0, 255)
            btxt = "Failed."
        end
        self:runTransition({ size = math.sqrt(WIDTH^2 + HEIGHT^2) * 2, y = HEIGHT / 2, fade = 1 }, nil, 
            { colour = bcol, message = btxt, fade = -0.25 })
        
        self.setinmotion = true
    end

    
    if self.transition.size > 0 then
        fill(self.transition.colour.r, self.transition.colour.g, self.transition.colour.b, self.transition.cfade * 255)
        ellipse(self.transition.x, self.transition.y, self.transition.size)
    end
    if self.transition.fade > 0 then
        fill(0, 255 * self.transition.fade) fontSize(WIDTH / 20)
        text(self.transition.message, self.transition.x, self.transition.y)
    end
    
    popStyle()
end

function Game:touched(t)
    if self.transition.size == 0 then
        if not self.paused then
            self.board:touched(t)
        end
        for i, btn in pairs(self.buttons) do
            btn:touched(t)
        end
    end
    
    if t.state == ENDED and self.board.finished and not self.transition.running then
        if self.board.finished == "success" then
            self.currentLevel = math.min(self.currentLevel + 1, #self.levels)
        end
        self:loadLevel()
    end
end


