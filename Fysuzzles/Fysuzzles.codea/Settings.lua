Settings = class()

function Settings:init(x)
    self.width = WIDTH/4
    
    -- Theme Slider
    local ist = selectedTheme
    self.themeSlider = IntegerSlider("selectedTheme", 1, #themeColors, ist, self.width/2, HEIGHT*6/7, function() self:saveTheme() end, true, "Theme")
    self.themeSlider.off = vec2(-(WIDTH - self.width), 0)
    self.themeSlider.length = self.width/1.5
    self.themeSlider.textFill = color(0, 0, 0, 255)
    local c = themeColors[selectedTheme].box
    self.themeSlider.baseFill, self.themeSlider.filledFill, self.themeSlider.circleFill = color(182, 182, 182, 255), color(0), color(c.r, c.g, c.b, 255)
    local t = vec2(0,0)
    t.x = (self.themeSlider.x - self.themeSlider.length/2) + ((self.themeSlider.length / (self.themeSlider.max - 1)) * (ist - 1))
    self.themeSlider:moveSlider(t)
    
    self.buttons = {}
    
    local fs = hScale(30)
    local c, fc = color(0), color(185, 185, 185, 255)
    -- Sound button
    local s
    if soundAllowed then s = "Sound: On" else s = "Sound: Off" end
    self.buttons.sound = TextButton(s, wScale(10), HEIGHT*3/4, function() self:toggleSound() end)
    self.buttons.sound.fontSize = fs
    self.buttons.sound.fill = c
    self.buttons.sound.tint = fc
    self.buttons.sound.mode = CORNER
    
    -- Music button
    local m
    if musicAllowed then m = "Music: On" else m = "Music: Off" end
    self.buttons.music = TextButton(m, wScale(10), HEIGHT*3/4 - fs*1.5, function() self:toggleMusic() end)
    self.buttons.music.fontSize = fs
    self.buttons.music.fill = c
    self.buttons.music.tint = fc
    self.buttons.music.mode = CORNER

end

function Settings:saveTheme()
    local c = themeColors[selectedTheme].box
    self.themeSlider.circleFill = color(c.r, c.g, c.b, 255)
    
    -- backCol = themeColors[selectedTheme].over
    -- topCol = color(c.r, c.g, c.b, 255)
    
    -- SManager.scenes["Start"].name.fill = topCol
    -- SManager.scenes["Start"]:createButtons()
    -- SManager.scenes["Modes"]:loadModes()
    
    saveLocalData("SelectedTheme", selectedTheme)
end

function Settings:toggleSound()
    toggleSound()
    
    local s
    if soundAllowed then s = "Sound: On" else s = "Sound: Off" end
    self.buttons.sound.txt = s
    
    saveLocalData("SoundAllowed", soundAllowed)
end

function Settings:toggleMusic()
    toggleMusic()
    
    local m
    if musicAllowed then m = "Music: On" else m = "Music: Off" end
    self.buttons.music.txt = m
    
    saveLocalData("MusicAllowed", musicAllowed)
end

function Settings:draw()
    pushStyle()
    fill(255) stroke(topCol) strokeWidth(hScale(5))
    rect(0, 0, self.width, HEIGHT)
    
    fill(0) fontSize(hScale(50))
    text("Settings", self.width/2, HEIGHT - fontSize()/2)
    
    -- Theme Slider
    fill(themeColors[selectedTheme].box) stroke(0) strokeWidth(2)
    rectMode(CORNER)
    rect(self.themeSlider.x - self.width/2.2, self.themeSlider.y - self.themeSlider.circleSize/1.5, self.width/1.1, self.themeSlider.circleSize*1.5 + self.themeSlider.fontSize)
    
    self.themeSlider:draw()
    
    -- Buttons
    for i, btn in pairs(self.buttons) do
        btn:draw()
    end
    popStyle()
end

function Settings:touched(touch)
    -- Theme Slider
    self.themeSlider:touched(touch)
    
    -- Buttons
    for i, btn in pairs(self.buttons) do
        btn:touched(touch)
    end
end
