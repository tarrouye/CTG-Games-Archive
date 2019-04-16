Selection = class()

function Selection:init()
    self.game = Game()
    self.editor = LevelEditor()
    
    self.state = "pack"
    self.drawState = {}
    self.drawState["pack"] = self.drawPack
    self.drawState["level"] = self.drawLevel
    self.drawState["game"] = function() self.game:draw() end
    self.drawState["editor"] = self.drawEditor
    
    self.transition = { fade = 0, x = WIDTH / 2, y = HEIGHT / 2, size = math.sqrt(WIDTH^2 + HEIGHT^2) * 2,
        colour = color(255), fontsize = 0, message = "" }
    
    self.bubbleSize = WIDTH / 5
    
    self:makeButtons()
end

function Selection:makeButtons()
    self.buttons = {}
    for i, pack in ipairs(levelPacks) do
        local x, y = (-WIDTH / 6) + ((WIDTH / 3) * i), HEIGHT / 2
            
        local btn = CircleButton(pack.name, x, y, self.bubbleSize, color(0, 194, 255, 255), color(0))
        btn.callback = function() if not btn.expanded then self:selectPack(i) else self:deselectPack() end end
        self.buttons[i] = { main = btn, name = pack.name, sub = {} }
        
        local beatAllLevs = true
        for ii, level in ipairs(pack.levels) do
            local x = self.bubbleSize + (self.bubbleSize * 1.5)*(specialModulo(ii, 3)-1)
            local y = HEIGHT / 2 + self.bubbleSize * 1.5 - (self.bubbleSize * 1.5 * math.floor((ii-1) / 3))
            
            local btn = CircleButton(ii, x, y, self.bubbleSize, color(255, 255, 255, 255), color(0))
            btn.callback = function() self:selectLevel(ii) end

            local completed = (completedLevels["Pack: " .. i ..", Level: " .. ii] == true)
            if not completed then
                beatAllLevs = false
            end
            
            self.buttons[i].sub[ii] = { btn = btn, completed = completed }
        end
        
        self.buttons[i].completed = beatAllLevs
        
        local y = HEIGHT / 2 - self.bubbleSize * 1.5 * 2
        local xbutton = CircleButton("x", WIDTH / 2, y, self.bubbleSize / 2, color(255), color(0))
        xbutton.callback = function() self:deselectPack() end
        self.buttons[i].sub[#self.buttons[i].sub + 1] = { btn = xbutton }
    end
        
    local ebtn = CircleButton("Editor", WIDTH / 2, self.bubbleSize, self.bubbleSize, color(0, 194, 255, 255), color(0))
    ebtn.callback = function() self:loadEditor() end
    table.insert(self.buttons, { main = ebtn })
end

function Selection:updateCompleted()
    for i, pack in ipairs(levelPacks) do
        local allCompleted = true
        for ii, level in ipairs(pack.levels) do
            local completed = (completedLevels["Pack: " .. i ..", Level: " .. ii] == true)
            if not completed then
                allCompleted = false
            end
            
            self.buttons[i].sub[ii].completed = completed
        end
        
        if self.buttons[i].sub ~= nil then
            self.buttons[i].completed = allCompleted
        else
            self.buttons[i].completed = nil
        end
    end
end

function Selection:runTransition(target, callback, initial, time)
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

function Selection:reset()
    self.selectedPack = nil
    
    for i, tbl in ipairs(self.buttons) do
        if tbl.main.expanded then
            tbl.main:unexpand()
        end
        if tbl.sub then
            for ii, btn in ipairs(tbl.sub) do
                if btn.expanded then
                    btn:unexpand()
                end
            end
        end
    end
end

function Selection:deselectPack()
    tween(0.3, self.selectedPack, { fade = 0 }, tween.easing.linear)
    
    self.state = "pack"
    
    local exb = self.selectedPack.main
    self:runTransition({ x = exb.x, y = exb.y, size = exb.size }, function() self.selectedPack = nil end,
        { x = WIDTH / 2, y = HEIGHT * 19/20, fontsize = exb.fontsize, message = exb.txt, 
        size = math.sqrt(WIDTH^2 + HEIGHT^2) * 2 })
end

function Selection:selectPack(id)
    self.game:loadPack(id)
    
    local exb = self.buttons[id].main
    self:runTransition({ x = WIDTH / 2, y = HEIGHT * 19/20, size = math.sqrt(WIDTH^2 + HEIGHT^2) * 2 }, function()
        self.selectedPack = self.buttons[id]
        self.selectedPack.fade = 0
        tween(0.5, self.selectedPack, { fade = 1 })
                    
        self.state = "level"
    end, { fade = 1, x = exb.x, y = exb.y, fontsize = exb.fontsize, size = exb.size, colour = exb.bColour, message = exb.txt })
end

function Selection:selectLevel(level)
    self.game.currentLevel = level
    self.game:loadLevel()
    
    local exb = self.selectedPack.sub[level].btn
    self:runTransition({ x = WIDTH / 2, y = HEIGHT / 2, size = math.sqrt(WIDTH^2 + HEIGHT^2) * 2 }, function()
        self.state = "game"
        self:runTransition({ fade = 0 }, function()
            self:reset()
        end)
    end, { fade = 1, x = exb.x, y = exb.y, size = exb.size, colour = exb.bColour, fontsize = 0 })
end
    
function Selection:loadEditor()
    self.editor:reset()
    
    local exb = self.buttons[#self.buttons].main
    self:runTransition({ x = WIDTH / 2, y = HEIGHT / 2, size = math.sqrt(WIDTH^2 + HEIGHT^2) * 2 }, function()
        self.state = "editor"
        self:runTransition({ fade = 0 }, function()
            self:reset()
        end)
    end, { fade = 1, x = exb.x, y = exb.y, size = exb.size, colour = exb.bColour, fontsize = 0 })
end

function Selection:drawPack()
    fill(0) fontSize(WIDTH / 20)
    text("Menu", WIDTH / 2, HEIGHT * 19/20)
        
    for i, pack in ipairs(self.buttons) do
        if self.selectedPack ~= pack then
            if pack.completed ~= nil then
                if pack.completed then
                    fill(0, 255, 24, 255) noStroke()
                else
                    fill(255, 0, 0)
                end
                ellipse(pack.main.x, pack.main.y, pack.main.size * 1.05)
            end
            
            pack.main:draw()
        end
    end
    
    fill(0) fontSize(WIDTH / 40)
    text("A JakAttak Game", WIDTH / 2, WIDTH / 35)
    
end

function Selection:drawLevel()
    fill(self.selectedPack.main.bColour) rect(-1, -1, WIDTH + 2, HEIGHT + 2)
    fill(0) fontSize(self.selectedPack.main.fontsize)
    text(self.selectedPack.name, WIDTH / 2, HEIGHT * 19/20)
    
    for i, subt in ipairs(self.selectedPack.sub) do
        local alpha = self.selectedPack.fade * 255
        if subt.completed ~= nil then
            if subt.completed then
                fill(255 - alpha, 255, 255 - alpha, alpha)
            else
                fill(255, 255 - alpha, 255 - alpha, alpha)
            end noStroke()
            ellipse(subt.btn.x, subt.btn.y, subt.btn.size * 1.05)
        end
            
        subt.btn.alpha = alpha
        subt.btn:draw()
    end
end

function Selection:drawEditor()
    self.editor:draw()
    
    if self.editor.finished then
        self:runTransition({ size = math.sqrt(WIDTH^2 + HEIGHT^2) * 2 }, function() 
            self.state = "pack"
            self:runTransition({ fade = 0 })
        end, { y = 0, size = 0, fade = 1, fontsize = 0, colour = color(255) } ) 
        
        self.editor.finished = false
    end
end

function Selection:draw()
    pushStyle()

    self.drawState[self.state](self)
    
    if self.transition.running then
        noStroke()
        fill(self.transition.colour.r, self.transition.colour.g, self.transition.colour.b, (self.transition.fade * 255))
        ellipse(self.transition.x, self.transition.y, self.transition.size)
        
        if self.transition.fontsize > 0 then
            fill(0, self.transition.fade * 255) fontSize(self.transition.fontsize)
            text(self.transition.message, self.transition.x, self.transition.y)
        end
    end
    
    popStyle()
end

function Selection:touched(t)
    if self.transition.running then return end
    
    if self.state == "pack" then
        for i, btn in ipairs(self.buttons) do
            btn.main:touched(t)
        end
    elseif self.state == "level" then
        for i, subt in ipairs(self.selectedPack.sub) do
            subt.btn:touched(t)
        end
    elseif self.state == "game" then
        self.game:touched(t)
        if self.game.finishedPack and not self.game.transition.running then
            self:updateCompleted()
            self:runTransition({ size = math.sqrt(WIDTH^2 + HEIGHT^2) * 2 }, function() 
                self.state = "pack"
                self:runTransition({ fade = 0 })
            end, { y = 0, size = 0, fade = 1, fontsize = 0, colour = color(255) } ) 
        end
    elseif self.state == "editor" then
        self.editor:touched(t)
    end
end


