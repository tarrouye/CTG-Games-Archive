PackManager = class()

function PackManager:init(mode)
    self.mode = mode
    
    self.packs = {}
    self.buttons = {}
    
    local img, size = readImage("Dropbox:FLBack"), vec2(wScale(143), hScale(50))
    self.buttons.back = Button(img, size.x/2, HEIGHT - size.y/2, function() SManager:change("Modes") end, size)
    
    self:loadPacks()
end

function PackManager:loadPacks()
    local cols = 2
    local rows = math.ceil(#LevelPacks/cols, cols)
    
    local locked = false
    for i , level in ipairs(LevelPacks[1].levels) do
        local id = "Pack:"..LevelPacks[1].name.." Level:"..i
        if not completedLevels[id] then
            locked = true
            break
        end
    end
    
    for i, pack in ipairs(LevelPacks) do
        self.packs[i] = { info = {pack.levels, pack.name, self.mode}, locked = locked }
        if i == 1 then
            self.packs[i].locked = false
        end
        
        local size = vec2(HEIGHT/3, HEIGHT/3)
        local img = image(size.x, size.y)
            
        setContext(img)
        pushStyle()
        fill(0,0) stroke(topCol) strokeWidth(wScale(15))
        ellipse(size.x/2, size.y/2, size.x, size.y)
            
        fill(topCol) fontSize(HEIGHT/15) font()
        text(pack.name, size.x/2, size.y/2)
        if locked and i ~= 1 then
            fontSize(HEIGHT / 55)
            textAlign(CENTER)
            text("Locked. Beat All Levels In\nTutorial Pack To Unlock", size.x/2, size.y/4)
        end
        popStyle()
        setContext()
            
        local row = math.ceil(i/cols, rows)
        local col = i - (cols * (row - 1))
            
        local x = (WIDTH / (cols + 1)) * col
        local y = HEIGHT - (HEIGHT / (rows + 1)) * row
            
        if self.buttons[i] == nil then
            self.buttons[i] = Button(img, x, y, function() if not self.packs[i].locked then self:openPack(self.packs[i].info) end end, size)
        else
            self.buttons[i].img = img
        end
    end
end

function PackManager:onEnter()
    self:loadPacks()
end

function PackManager:openPack(info)
    SManager:removeScene("OpenPack")
    
    SManager:addScene("OpenPack", LevelManager(unpack(info)), true)
    SManager:change("OpenPack")
end

function PackManager:draw()
    fontSize(wScale(65)) fill(topCol) font()
    text("Level Packs", WIDTH/2, HEIGHT - fontSize()/2)
    
    for id, btn in pairs(self.buttons) do
        btn:draw()
    end
end

function PackManager:touched(touch)
    for id, btn in pairs(self.buttons) do
        btn:touched(touch)
    end
end


