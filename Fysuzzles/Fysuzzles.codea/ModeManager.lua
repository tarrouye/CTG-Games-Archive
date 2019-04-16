ModeManager = class()

function ModeManager:init(x)
    self.modes = { "Standard", "Challenge" }
    
    self.buttons = {}
    
    local img, size = readImage("Dropbox:FLBack"), vec2(wScale(143), hScale(50))
    self.buttons.back = Button(img, size.x/2, HEIGHT - size.y/2, function() SManager:change("Start") end, size)
    
    self:loadModes()
end

function ModeManager:loadModes()
    for i, mode in ipairs(self.modes) do
        if self.buttons[i] == nil then
            local x = (WIDTH/3) * i
            local size = vec2(WIDTH/4, WIDTH/4)
            local img = image(size.x, size.y)
            
            setContext(img)
            pushStyle()
            fill(0,0) stroke(topCol) strokeWidth(wScale(15))
            ellipse(size.x/2, size.y/2, size.x, size.y)
            
            fill(topCol) fontSize(WIDTH/20) font()
            text(mode, size.x/2, size.y/2)
            popStyle()
            setContext()
            
            table.insert(self.buttons, Button(img, x, HEIGHT/2, function() self:openMode(mode) end, size))
        end
    end
end

function ModeManager:openMode(mode)
    SManager:removeScene("Levels")
    
    SManager:addScene("Levels", PackManager(mode), true)
    SManager:change("Levels")
end

function ModeManager:draw()
    fontSize(wScale(65)) fill(topCol) font()
    text("Game Modes", WIDTH/2, HEIGHT - fontSize()/2)
    
    for id, btn in pairs(self.buttons) do
        btn:draw()
    end
end

function ModeManager:touched(touch)
    for id, btn in pairs(self.buttons) do
        btn:touched(touch)
    end
end

