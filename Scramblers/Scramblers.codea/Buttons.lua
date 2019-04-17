Button = class()

function Button:init(img, timg, x, y, callback, size)
    self.img = img
    self.timg = timg
    self.x = x
    self.y = y
    self.size = size
    self.drawSize = self.size
    self.callback = callback
    self.pressed = false
end

function Button:draw()
    pushStyle()
    --noSmooth()
    
    local img = self.img
    if self.pressed then
        img = self.timg
    end
    sprite(img, self.x, self.y, self.drawSize.x, self.drawSize.y)
    
    if self.glow ~= nil then
        for i, glow in ipairs(self.glow) do
            glow:draw()
        end
    end
    popStyle()
end

function Button:touched(touch)
    local rt
    if touch.x > self.x - self.size.x/2 and touch.x < self.x + self.size.x/2 and
    touch.y > self.y - self.size.y/2 and touch.y < self.y + self.size.y/2 then
        if touch.state == BEGAN or touch.state == MOVING then
            self.pressed = true
        elseif touch.state == ENDED then
            self.pressed = false
            self.callback()
            if not self.silent then
                sound("Game Sounds One:Jump")
            end
        end
        rt = true
    else
        self.pressed = false
        rt = false
    end
    
    return rt
end

TextButton = class()

function TextButton:init(txt, x, y, callback, fs, col, silent, hiding, scramble)
    self.txt = txt
    self.x = x
    self.y = y
    self.w = 0
    self.h = 0
    self.callback = callback
    self.pressed = false
    self.fontSize = fs or 100
    self.fill = col or color(255, 255, 255, 255)
    self.tint = color(127, 127, 127, 255)
    self.mode = CENTER
    self.silent = silent or false
    self.hiding = hiding or false
    self.scrollNum = self.txt:len()
    if scramble then
        self:scrambleTxt()
    end
end

function TextButton:scroll(time, cb)
    self.scrollNum = 1
    tween(time, self, { scrollNum = self.txt:len() }, tween.easing.linear, cb or function() end)
end

function TextButton:scrambleTxt()
    -- Scramble word into a table
    self.scramble = {}
    for letter in self.txt:gmatch("[%a%s%p]") do
        local let = string.lower( letter )
        local dir = math.random(-1, 1)
        if dir == 1 then
            table.insert(self.scramble, { txt = let })
        else
            table.insert(self.scramble, 1, { txt = let })
        end
    end

    self:positionScramble()
end


function TextButton:positionScramble()
    -- Get x position to draw words centered on screen
    font(STANDARDFONT) fontSize(self.fontSize) textWrapWidth(WIDTH) textAlign(CENTER)
    local wordW, wordH = textSize(self.txt)
    local prevW, prevH = 0, 0
    local letW, letH = textSize(self.scramble[1])
    local x = (self.x - wordW / 2) - letW / 2
    for i, letter in ipairs(self.scramble) do
        local letW, letH = textSize(letter.txt)
        x = x + prevW / 2 + letW /2

        letter.x = x
        letter.y = self.y
        letter.w = letW
        letter.h = letH

        prevW = letW
    end
end

function TextButton:unscrambleTxt(cb)
    local delay, num = 0, 1
    for let in self.txt:gmatch("[%a%s%p]") do
        tween.delay(delay, function()
            local s
            for i, letter in ipairs(self.scramble) do
                if letter.txt == let then
                    s = i
                end
            end

            local curt = self.scramble[s]
            self.scramble[s] = self.scramble[num]
            self.scramble[num] = curt
            self:positionScramble()

            num = num + 1
        end)
        delay = delay + 0.1
    end

    tween.delay(delay, cb or function() end)
end

function TextButton:left()
    if self.mode == CORNER then
        return self.x
    else
        return self.x - self.w/2
    end
end

function TextButton:right()
    if self.mode == CORNER then
        return self.x + self.w
    else
        return self.x + self.w/2
    end
end

function TextButton:bot()
    if self.mode == CORNER then
        return self.y
    else
        return self.y - self.h/2
    end
end

function TextButton:top()
    if self.mode == CORNER then
        return self.y + self.h
    else
        return self.y + self.h/2
    end
end

function TextButton:draw()
    if self.hiding then return end

    pushStyle()
    
    local tbtc, scol
    if self.pressed then
        fill(self.tint)
        tbtc, scol = self.tint, self.fill
    elseif self.fill ~= nil then
        fill(self.fill)
        tbtc, scol = self.fill, self.tint
    end
    
    textWrapWidth(WIDTH) textAlign(CENTER) textMode(self.mode)
    fontSize(self.fontSize) font(STANDARDFONT)
    self.w, self.h = textSize(self.txt)
    if self.scramble == nil then
        text(self.txt:sub(1, self.scrollNum), self.x, self.y)
    else
        for i, letter in ipairs(self.scramble) do
            text(letter.txt, letter.x, letter.y)
        end
    end

    popStyle()
end

function TextButton:touched(touch)
    if self.hiding then return end

    if touch.x > self:left() and touch.x < self:right() and
    touch.y > self:bot() and touch.y < self:top() then
        if touch.state == BEGAN or touch.state == MOVING then
            self.pressed = true
        elseif touch.state == ENDED then
            self.pressed = false
            self.callback()
            if not self.silent then
                sound("Game Sounds One:Block 1")
            end
        end
    else
        self.pressed = false
    end
end
