StartScreen = class()

function StartScreen:init(x)
    self.music = "Dropbox:space"
    
    self.settings = Settings()
    self.settingsOff = WIDTH
    
    self.sounds = {
        settings = function() sound("Game Sounds One:Whoosh 1") end
    }
    
    self.fontsize = wScale(50)
    self.name = juice.text("Fysuzzles", WIDTH/2, HEIGHT - self.fontsize/2)
    self.name.fill = topCol
    self.name.fontSize = self.fontsize
    self.name.font = STANDARDFONT
    -- self.name:pulse(0.3, math.huge, 0.5)
    
    self.images = {
        play = readImage("Dropbox:FLSPlay"),
        editor = readImage("Dropbox:FLSEditor"),
        musicOn = readImage("Dropbox:Speaker&Waves"),
        musicOff = readImage("Dropbox:Speaker"),
        credits = readImage("Dropbox:FLCredits"),
        settings = readImage("Cargo Bot:Condition Any")
    }
    
    self:createButtons()
end

function StartScreen:createButtons()
    local make = { "Play", "Editor" }
    for i, n in ipairs(make) do
        self.images[string.lower(n)] = image(WIDTH/4, WIDTH/4)
        setContext(self.images[string.lower(n)])
        pushStyle()
        fill(0,0) stroke(self.name.fill) strokeWidth(wScale(10))
        ellipse(WIDTH/8,WIDTH/8,WIDTH/4,WIDTH/4)
        
        fill(self.name.fill) fontSize(WIDTH/20) font()
        text(n, WIDTH/8,WIDTH/8)
        popStyle()
        setContext()
    end
    
    self.buttons = {}
    local size = vec2(self.images.play.width, self.images.play.height)
    self.buttons[1] = Button(self.images.play, WIDTH/4, HEIGHT/2, function() SManager:change("Modes") end, size)
    self.buttons[2] = Button(self.images.editor, WIDTH*3/4, HEIGHT/2, function() if not editorLocked then SManager:change("Edit") end end, size)
    local fs = WIDTH/25
    font() fontSize(fs) local cw, ch = textSize("Credits")
    self.buttons[3] = TextButton("Credits", WIDTH - cw/2, ch/2, function() SManager:change("Credits") end)
    self.buttons[3].fontSize = fs
    local sw, sh = textSize("Settings")
    self.buttons[4] = TextButton("Settings", WIDTH - sw/2, HEIGHT - sh/2, function() self:toggleSettings() end)
    self.buttons[4].fontSize = fs
    self.buttons[4].silent = true
end

function StartScreen:toggleSettings()
    if self.movingSettings == nil then
        self.sounds.settings()
        
        if self.settingsOff < WIDTH then
            self.movingSettings = tween(0.5, self, { settingsOff = WIDTH }, tween.easing.linear, function() self.movingSettings = nil end)
            else
            self.movingSettings = tween(0.5, self, { settingsOff = WIDTH - self.settings.width }, tween.easing.linear, function() self.movingSettings = nil end)
        end
    end
end

function StartScreen:onEnter()
    if music.name ~= self.music then
        music(self.music, true, 1.0)
    end
end

function StartScreen:draw()
    smooth()
    self.name:draw()
        
    for i, btn in ipairs(self.buttons) do
        btn:draw()
    end
    
    if self.settingsOff < WIDTH then
        pushMatrix()
        translate(self.settingsOff, 0)
        self.settings:draw()
        popMatrix()
    end
end

function StartScreen:touched(touch)
    if self.settingsOff >= WIDTH then
        for i, btn in ipairs(self.buttons) do
            btn:touched(touch)
        end
    else
        local t = { id = touch.id, state = touch.state, x = touch.x - self.settingsOff, y = touch.y, prevX = touch.prevX, prevY = touch.prevY, deltaX = touch.deltaX, deltaY = touch.deltaY }
        self.settings:touched(t)
        
        if touch.x < self.settingsOff and touch.state == ENDED then
            self:toggleSettings()
        end
    end
end


