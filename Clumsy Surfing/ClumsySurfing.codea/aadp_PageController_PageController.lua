PageController = class()
 
function PageController:init(...)
    self.pages = { ... }
    self:managePages()
    
    self.toSwitch = WIDTH / 4
    self.minShor = WIDTH / 50
    self.timePerPage = 1
    self.indicator = math.max(WIDTH, HEIGHT) / 100
    self.page, self.scroll, self.scrollo, self.locked = 1, 0, 0, false
    
    self.touchedTime, self.touchBeganHere = 0, false
end
 
function PageController:managePages()
    for i, page in ipairs(self.pages) do
        if typeOf(page) == "table" then
            page.draw = page.draw or function() end
            page.touched = page.touched or function() end
        elseif typeOf(page) == "class" then
            local dfun = page.draw or function() end
            page.draw = function() dfun(page) end
            page.touched = page.touched or function() end
        elseif typeOf(page) == "function" then
            self.pages[i] = { draw = page, touched = function() end }
        else
            self.pages[i] = nil
        end
    end
end
 
function PageController:draw()
    -- Draw pages that should be shown
    pushMatrix()
    translate(self.scrollo, 0)
    if self.pages[self.page] ~= nil then
        pushStyle()
        self.pages[self.page].draw()
        popStyle()
    end
    
    if self.pages[self.page - 1] ~= nil and self.scroll > 0 then
        pushMatrix()
        translate(-WIDTH, 0)
        pushStyle()
        self.pages[self.page - 1].draw()
        popStyle()
        popMatrix()
    end
    
    if self.pages[self.page + 1] ~= nil and self.scroll < 0 then
        pushMatrix()
        translate(WIDTH, 0)
        pushStyle()
        self.pages[self.page + 1].draw()
        popStyle()
        popMatrix()
    end
    popMatrix()
    
    -- Draw page indicators
    local w = self.indicator * (#self.pages * 2 - 1)
    local x = (WIDTH / 2) - (w / 2) + self.indicator / 2
    for p = 1, #self.pages do
        if p == self.page then fill(255)
        else fill(255, 127) end 
        noStroke()
        
        ellipse(x, self.indicator, self.indicator)
        
        x = x + self.indicator * 2
    end
end
 
function PageController:closestPage()
    local sincet = ElapsedTime - self.touchedTime
    local closest = self.page
    if (self.scrollo > self.toSwitch or (self.scrollo > self.minShor and sincet < 0.25)) and self.page > 1 then
        closest = self.page - 1
        self.scrollo = math.max(self.scrollo, self.toSwitch)
    elseif (self.scrollo < -self.toSwitch or (self.scrollo < -self.minShor and sincet < 0.25)) and self.page < #self.pages then
        closest = self.page + 1
        self.scrollo = math.min(self.scrollo, -self.toSwitch)
    end
    
    return closest
end

function PageController:tweenToPage(page, dur)
    local target = (self.page - page) * WIDTH
        
    if page ~= self.page then
        self.locked = true
        
        if SOUND_EFFECTS and SOUND_EFFECTS.page then
            SOUND_EFFECTS.page()
        end
    end
    
    if self.scrollo ~= target then
        local ndur = (math.abs(self.scrollo) / (self.toSwitch)) / ((WIDTH / self.toSwitch) * self.timePerPage)
        if ndur == 0 then ndur = self.timePerPage end
        self.releasing = tween(dur or ndur, self, { scrollo = target, scroll = target }, tween.easing.cubicOut, function()
            self.page = page
            self.scroll = 0
            self.scrollo = 0
            self.releasing = nil
            self.locked = false
        end)
    else
        self.scroll = 0
    end
end

function PageController:dotTouched(t)
    -- Draw page indicators
    local w = self.indicator * (#self.pages * 2 - 1)
    local x = (WIDTH / 2) - (w / 2) + self.indicator / 2
    local y = self.indicator
    for p = 1, #self.pages do
        if vec2(t.x, t.y):dist(vec2(x, y)) <= self.indicator then
            self:tweenToPage(p, 0.0001)
            
            return true
        end
        
        x = x + self.indicator * 2
    end
end
 
function PageController:scrollTouched(t)
    -- Handle touching on pages
    if self.scrollo == 0 then
        local tparams = { t }
        if typeOf(self.pages[self.page]) == "class" then table.insert(tparams, 1, self.pages[self.page]) end
        if self.pages[self.page] ~= nil and self.pages[self.page].touched(unpack(tparams)) == true then 
            return -- If touched something then no scrolling
        end
    end
    
    -- No scrolling when locked
    if self.locked then return end
    
    if t.state == BEGAN then
        self.touchBeganHere = true
        self.touchedTime = ElapsedTime
    end
    
    -- No scrolling if touch didnt originate on controller
    if not self.touchBeganHere then return end
    
    -- Stop tween when dragging
    if self.releasing ~= nil then
        tween.stop(self.releasing)
    end
    
    -- Scroll from drag
    self.scroll = self.scroll + t.deltaX
    
    local min = self.pages[self.page].pcSlideMin or 0
    local off = math.max(0, math.abs(self.scroll) - min)
    self.scrollo = off * math.sign(self.scroll)

    
    -- Tweens to closest page
    if t.state == ENDED then
        local closestPage = self:closestPage()
        self:tweenToPage(closestPage)
        
        self.touchBeganHere = false
    end
end

function PageController:touched(t)
    if not self:dotTouched(t) then
        self:scrollTouched(t)
    end
end
 
 
 
-- Helper functions
function typeOf(x)
    -- Extended type function
    if x == nil then 
        return 'nil' 
    end
    if type(x) == 'table' and x.is_a then 
        return('class') 
    end
    
    local txt
    
    if typeTable == nil then
        typeTable = {
            [getmetatable(vec2()).__index ] = 'vec2', 
            [getmetatable(vec3()).__index ] = 'vec3',
            [getmetatable(color()).__index ] = 'color', 
            [getmetatable(image(1,1)).__index ] = 'image', 
            [getmetatable(matrix()).__index] = 'matrix', 
            [getmetatable(mesh()).__index ] = 'mesh' ,
            [getmetatable(physics.body(CIRCLE, 1)).__index] = 'physics body',
        }
    end
    
    local i = getmetatable(x)
    if i then 
        txt = typeTable[i.__index] 
    end    
    if txt then 
        return txt 
    end
    
    txt = type(x)
    return txt
end

math.sign = function(n)
    if n < 0 then 
        return -1
    end
    
    return 1
end
 
function pBackground(...)
    -- Called same as background, draws a rect instead so each page can have individual background
    pushStyle()
    rectMode(CORNERS)
    fill(...)
    rect(-WIDTH / 768, -WIDTH / 768, WIDTH + WIDTH / 768, HEIGHT + WIDTH / 768)
    popStyle()
end
 
