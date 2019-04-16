Welcome = class()

function Welcome:init()
    self.fill = color(0)
    self.border = WIDTH / 50

    self.str = "welcome to scramblers"
    self.title = {}


    self.fontSize = WIDTH / 12
    local fs = HEIGHT / 14

    self.buttons = {}
    self.buttons[1] = TextButton("teach me how to play!", WIDTH / 2, HEIGHT / 4 + fs + self.border / 2, function() Scene:change("Help") end, fs, color(0, 255, 0), false, true, true)
    self.buttons[2] = TextButton("i already know how!", WIDTH / 2, HEIGHT / 4 - fs - self.border / 2, function() Scene:change("Title") end, fs, color(255, 0, 0), false, true, true)

    self:scrambleString()
end

function Welcome:scrambleString()
    -- Scramble word into a table
    self.title = {}
    for letter in self.str:gmatch("[%a%s%p]") do
        local let = string.lower( letter )
        local dir = math.random(-1, 1)
        if dir == 1 then
            table.insert(self.title, { txt = let })
        else
            table.insert(self.title, 1, { txt = let })
        end
    end

    self:centerTitle()
end

function Welcome:centerTitle()
    -- Get x position to draw words centered on screen
    font(STANDARDFONT) fontSize(self.fontSize) textWrapWidth(WIDTH) textAlign(CENTER)
    local wordW, wordH = textSize(self.str)
    local prevW, prevH = 0, 0
    local letW, letH = textSize(self.title[1])
    local x = (WIDTH / 2 - wordW / 2) - letW / 2
    for i, letter in ipairs(self.title) do
        local letW, letH = textSize(letter.txt)
        x = x + prevW / 2 + letW /2

        letter.x = x
        letter.y = HEIGHT - self.fontSize / 1.5
        letter.w = letW
        letter.h = letH

        prevW = letW
    end
end

function Welcome:unscrambleTitle(cb)
    local delay, num = 0, 1
    for let in self.str:gmatch("[%a%s%p]") do
        tween.delay(delay, function()
            local s
            for i, letter in ipairs(self.title) do
                if letter.txt == let then
                    s = i
                end
            end

            local curt = self.title[s]
            self.title[s] = self.title[num]
            self.title[num] = curt
            self:centerTitle()

            num = num + 1
        end)
        delay = delay + 0.1
    end

    tween.delay(delay, cb or function() end)
end

function Welcome:onEnter()
    tween.delay(0.5, function()
        self:unscrambleTitle(function()
            self.buttons[1].hiding = false
            self.buttons[1]:unscrambleTxt(function()
                self.buttons[2].hiding = false
                self.buttons[2]:unscrambleTxt()
            end)
        end)
    end)
end

function Welcome:draw()
    font(STANDARDFONT) fill(self.fill) fontSize(self.fontSize) textWrapWidth(WIDTH*7/8) textAlign(CENTER)
    for i, letter in ipairs(self.title) do
        text(letter.txt, letter.x, letter.y)
    end


    -- Draw the buttons
    for i, btn in ipairs(self.buttons) do
        btn:draw()
    end
end

function Welcome:touched(t)
    -- Touch the buttons
    for i, btn in ipairs(self.buttons) do
        btn:touched(t)
    end
end
