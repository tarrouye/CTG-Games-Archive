LevelManager = class()

function LevelManager:init(levels,p,mode)
    -- Load levels and pass parameters to create instances of Game
    self.levels = levels
    self.pack = p
    self.mode = mode
    
    self.scroll = ScrollController()
    
    self.music = "Dropbox:space"
    
    self.buttons, self.games = {}, {}
    
    self:createButtons()
    
    self.scrollBar = GlowLine(vec2(0,0), vec2(0,0), 10)
    self.totalSize = 0
    
    local img, size = readImage("Dropbox:FLBack"), vec2(wScale(143), hScale(50))
    self.backButton = Button(img, size.x/2, HEIGHT - size.y/2, function() SManager:change("Levels") end, size)
end

function LevelManager:createButtons()
    local cols = 4
    local spacing = vec2(WIDTH / 12, HEIGHT/2 - HEIGHT/5)
    local size = ((WIDTH - spacing.x) / cols) - spacing.x
    size = vec2(size, size)
    local startXPos = -size.x/2
    local startYPos = HEIGHT*4/5 + spacing.y/1.25
    
    local rows = math.ceil(math.fmod(#self.levels/cols, cols))
    
    for i, level in ipairs(self.levels) do
        if self.buttons[i] == nil then
            local id = "Pack:"..self.pack.." Level:"..i
                
            local row = math.ceil(i/cols, rows)
            local col = i - (cols * (row - 1))
            self.games[i] = {}
            for li, stuff in pairs(level) do
                self.games[i][li] = stuff
            end
            self.games[i].prevscene = "OpenPack"
            self.games[i].mode = self.mode
            self.games[i].comId = id
                
            local xPos = startXPos + (size.x * col) + (spacing.x * col)
            local yPos = startYPos - (spacing.y * row)
                
            local img = image(wScale(300), wScale(300))
            setContext(img)
            fill(themeColors[selectedTheme].box)
            rect(0,0,img.width,img.height)
            if completedLevels[id] ~= nil and completedLevels[id][self.mode] == true then
                sprite("Dropbox:TDCheck", img.width/2, img.height/2, img.width/1.5, img.height/1.5)
            end
            fill(themeColors[selectedTheme].over) fontSize(hScale(40)) font()
            text("Level "..i, img.width/2, img.height/2)
            setContext()
                
            self.buttons[i] = Button(img, xPos, yPos, function() self:openLevel(self.games[i]) end, size)
            self.buttons[i].tint = color(0)
            local w = 5
            self.buttons[i].glow = {GlowLine(vec2(xPos-size.x/2, yPos-size.y/2),vec2(xPos+size.x/2, yPos-size.y/2),w),
                                    GlowLine(vec2(xPos+size.x/2, yPos-size.y/2),vec2(xPos+size.x/2, yPos+size.y/2),w),
                                    GlowLine(vec2(xPos+size.x/2, yPos+size.y/2),vec2(xPos-size.x/2, yPos+size.y/2),w),
                                    GlowLine(vec2(xPos-size.x/2, yPos+size.y/2),vec2(xPos-size.x/2, yPos-size.y/2),w)}
            
            for _,glow in ipairs(self.buttons[i].glow) do
                -- glow.m.shader.color = vec4(0,1,2,2)
            end
                                        
            if i == #self.levels then
                local ts = yPos - (spacing.y - size.y/2)
                local off = math.max(math.abs(ts), 0)
                    
                self.totalSize = off + HEIGHT
                self.scroll:setMaxY(off)
            end
        end
    end
end

function LevelManager:addCheck()
    -- Adds check to last level if completed
    
    for i, btn in ipairs(self.buttons) do
        local id = "Pack:"..self.pack.." Level:"..i
        if completedLevels[id] ~= nil and completedLevels[id][self.mode] == true then
            local img = image(wScale(300), wScale(300))
            setContext(img)
            fill(themeColors[selectedTheme].box)
            rect(0,0,img.width,img.height)
            
            sprite("Dropbox:TDCheck", img.width/2, img.height/2, img.width/1.5, img.height/1.5)
            
            fill(themeColors[selectedTheme].over) fontSize(hScale(40)) font()
            text("Level "..i, img.width/2, img.height/2)
            setContext()
            
            btn.img = img
        end
    end
end
function LevelManager:onEnter()
    self:addCheck()
    
    self.totalSize = self.scroll.maxY + HEIGHT
    
    if music.name ~= self.music then
        music(self.music, true, 1.0)
    end
    
    self.barFade = 2
    self.stopShowingBar = tween(1, self, {barFade = 0}, {tween.easing.linear})
end

function LevelManager:openLevel(info)
    SManager.scenes["Game"]:loadLevel(info)
    SManager:change("Game")
end

function LevelManager:drawScrollBar()
    -- Scroll bar
    pushStyle()
    pushMatrix()
                        
        local viewable = HEIGHT
        translate(0, -(self.scroll.offset.y * (HEIGHT / self.totalSize)))
                        
        local tpast = (self.scroll.offset.y - self.scroll.maxY)
        local bpast = (self.scroll.minY - self.scroll.offset.y)
        tpast, bpast = math.max(0, tpast), math.max(0, bpast)
        local toff, boff = tpast * (HEIGHT / self.totalSize), bpast * (HEIGHT / self.totalSize)
                        
        local h = viewable * (HEIGHT / self.totalSize) - toff
        local x1, y1, x2, y2 = WIDTH - WIDTH/24, HEIGHT - 2 - boff, WIDTH - WIDTH/24, HEIGHT - h + 2
        
        local c = themeColors[selectedTheme].glow
        self.scrollBar.m.shader.color = vec4(c.x,c.y,c.z,self.barFade)
        self.scrollBar:setPositions(vec2(x1, y1), vec2(x2, y2))
        self.scrollBar:draw()
     
    popMatrix()
    popStyle()
end

function LevelManager:draw()
    fill(themeColors[selectedTheme].over) noStroke()
    rectMode(CENTER) rect(WIDTH/2,HEIGHT/2,WIDTH*1.01, HEIGHT*1.01)
    
    self.scroll:update()
        
    self:drawScrollBar()
        
    pushMatrix()
    translate(0, self.scroll.offset.y)
        
    fontSize(wScale(65)) fill(themeColors[selectedTheme].box) font()
    text(self.pack .. " Levels", WIDTH/2, HEIGHT - fontSize()/2)
        
        
    for id, btn in pairs(self.buttons) do
        btn:draw()
            
        for i, gline in ipairs(btn.glow) do
            gline:draw()
        end
    end
        
    popMatrix()
        
    self.backButton:draw()
end

function LevelManager:touched(touch)
    if touch.state ~= ENDED then
        self.barFade = 2
        if self.stopShowingBar then tween.stop(self.stopShowingBar) end
        else
        self.stopShowingBar = tween(1, self, {barFade = 0}, {tween.easing.linear})
    end
        
    self.scroll:touched(touch)
        
    -- Adjust touch position to match whats being drawn (modify by scroll offset)
    local t = { id = touch.id, state = touch.state, x = touch.x, y = touch.y }
    t.y = t.y - self.scroll.offset.y
                    
    if self.scroll.moving == nil and (ElapsedTime - self.scroll.lastSigTouchTime) > 0.05 
    and self.scroll.lastState == ENDED then
        for id, btn in pairs(self.buttons) do
            btn:touched(t)
        end
    end
        
    self.backButton:touched(touch)
end


