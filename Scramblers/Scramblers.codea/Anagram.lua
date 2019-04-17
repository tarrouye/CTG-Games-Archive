Anagram = class()

function Anagram:init()
    self.word = ""
    self.scramble = {}
    self.fireworks = {}
    self.possible = ""
    self.holding = false
    self.stage = 1
    self.score = 0
    self.skips = readLocalData("AmntSkips") or 0
    self.transition = {}
    self.lost = false
    self.prevword = ""
    self.showingprev = false
    self.showingconf = false

    NORMAL = 1
    SPEED = 2
    PARTY = 3
    self.mode = NORMAL

    self.tlocked = false
    
    self.fill = color(0, 0, 0, 255)
    self.selectFill = color(255, 0, 0, 255)
    self.winFill = color(0, 204, 255, 255)
    self.fontSize = WIDTH / 6
    self.smallFS = WIDTH / 25
    self.border = WIDTH / 50
    self.perStage = 5
    self.numPossible = (HEIGHT / (self.smallFS * 1.2))
    self.transitionSound = function() sound("Game Sounds One:Whoosh 1") end
    self.blockSound = function() sound("Game Sounds One:Menu Select") end
    self.fireSound = function() sound("Game Sounds One:Pistol") end
    self.music = "Game Music One:Smoothie"
    self.popup = Popup(WIDTH / 2, HEIGHT / 2 + self.fontSize / 1.5, 0.5)
    self.realbutwrong = "that's a word, but not the right one"

    self.timer = Timer(0, function() self:lose() end)

    self.buttons = {}
    local s = WIDTH / 12
    local hmesh = mesh() hmesh.vertices = { vec2(s/4, s/6), vec2(s/4, s*4/6), vec2(s/2, s*5/6), vec2(s/2, s*5/6), vec2(s*3/4, s*4/6), vec2(s*3/4, s/6), vec2(s*3/4, s/6), vec2(s/2, s*5/6), vec2(s/4, s/6) } 
    hmesh:setColors(255,255,255,255)
    local himg = image(s, s) setContext(himg) 
        hmesh:draw() stroke(self.fill) strokeWidth(1)
        for i = 1, #hmesh.vertices-2 do local a = hmesh.vertices[i] local b = hmesh.vertices[(i%(#hmesh.vertices-2)) + 1] line(a.x, a.y, b.x, b.y) end
    setContext()
    local himg1, himg2 = makeButtonImgs(himg, s, self.fill)
    self.buttons[1] = Button(himg1, himg2, s / 2 + self.border, s / 2 + self.border, function() if not self.lost then self.timer:pause() end Scene:change("Title") self.lastMode = self.mode end, vec2(s, s))

    local rimg = image(s, s) setContext(rimg) sprite("Dropbox:DSRestart", s/2, s/2, s/1.2) setContext()
    local rimg1, rimg2 = makeButtonImgs(rimg, s, self.fill)
    self.buttons[2] = Button(rimg1, rimg2, WIDTH - s / 2 - self.border, s / 2 + self.border, function() self:prestart() end, vec2(s, s))

    local smesh = mesh() smesh.vertices = { vec2(s/4, s/6), vec2(s/4, s*5/6), vec2(s*1.1/2, s/2) } smesh:setColors(255,255,255,255)
    local simg = image(s, s) setContext(simg)
        smesh:draw() stroke(self.fill) strokeWidth(1)
        for i = 1, #smesh.vertices do local a = smesh.vertices[i] local b = smesh.vertices[(i%#smesh.vertices) + 1] line(a.x, a.y, b.x, b.y) end
        pushMatrix() translate(s*1.1/2 - s/4, 0)
        smesh:draw() stroke(self.fill) strokeWidth(1)
        for i = 1, #smesh.vertices do local a = smesh.vertices[i] local b = smesh.vertices[(i%#smesh.vertices) + 1] line(a.x, a.y, b.x, b.y) end popMatrix()
    setContext()
    local simg1, simg2 = makeButtonImgs(simg, s, self.fill)
    self.buttons[3] = Button(simg1, simg2, WIDTH / 2, s / 2 + self.border, function() self:skipWord() end, vec2(s, s))

    local bs = s * 1.5
    local yimg = image(bs, bs) setContext(yimg) _strokeWidth(HEIGHT / 55)
        line(bs/4, bs/2, bs/2.5, bs/4) line(bs/2.5, bs/4, bs*3/4, bs*3/4)
    setContext()
    local yimg1, yimg2 = makeButtonImgs(yimg, bs, color(255, 0, 0))
    self.yesButton = Button(yimg1, yimg2, WIDTH / 2 - bs*1.5, HEIGHT / 2 - bs, function() self:restart() end, vec2(bs, bs))

    local nimg = image(bs, bs) setContext(nimg) stroke(self.fill) _strokeWidth(HEIGHT / 55)
        line(bs/4, bs*3/4, bs*3/4, bs/4) line(bs/4, bs/4, bs*3/4, bs*3/4)
    setContext()
    local nimg1, nimg2 = makeButtonImgs(nimg, bs, color(0, 255, 0))
    self.noButton = Button(nimg1, nimg2, WIDTH / 2 + bs*1.5 , HEIGHT / 2 - bs, function() self.showingconf = false end, vec2(bs, bs))

    strokeWidth()

    self:changeSkips(0)
    
    parameter.action("Unlimited Skips", function() self.skips = math.huge displayMode(FULLSCREEN_NO_BUTTONS) end)
    parameter.action("Free Win", function() displayMode(FULLSCREEN_NO_BUTTONS) tween.delay(0.2, function() self:win() end) end)
    parameter.action("Print Word", function() print(self.word) end)
    
    self:getNew()
end

function Anagram:setMode(m)
    self.mode = m
end

function Anagram:onEnter()
    self.lost = false
    self.tlocked = false
    self.holding = false

    if music.name ~= self.music then
        music(self.music, true, 0.9)
    end
    
    self.skips = readLocalData("AmntSkips") or 0

    self:adjustWordPositions()

    if self.mode == SPEED then
        self.timer.time = 15
    elseif self.mode == PARTY then
        self.timer.time = math.random(60, 120)
    end
    if self.mode == SPEED or self.mode == PARTY then
        if self.timer:done() then
            self.timer:restart()
        elseif self.timer.paused then
            self.timer:resume()
        end
    end
    if self.lastMode ~= self.mode then
        self:restart()
    end
end

function Anagram:prestart()
    if self.mode == SPEED and not readLocalData("unlockedspeed") then
        alert("Trial is over. You haven't unlocked speed challenge mode yet.", "Visit the Store")
        Scene:change("Title")
        return
    end

    if self.lost then
        self:restart()
    else
        self.showingconf = true
    end
end

function Anagram:restart()
    self.lost = false
    self.tlocked = false
    self.holding = false
    self.showingconf = false
    self.showingprev = false
    self.popup:dismiss()
    self.setHighscore = false
    self.setHighstage = false

    self.stage = 1
    self.score = 0

    self:getNew()

    if self.mode == PARTY or self.mode == SPEED then
        self.timer:restart()
        self.timer:pause()
    end
end

function Anagram:getNew()
    -- Get a random word and scramble it
    self:getRandomWord()
    self:scrambleWord(self.word)
end

function Anagram:lockThings()
    -- Lock touching
    self.tlocked = true
end

function Anagram:unlockThings()
    -- Unlock touching
    self.tlocked = false
    
    -- No longer winning
    self.winning = false
    
    -- No longer transitioning
    self.transitioning = false
end

function Anagram:getRandomWord()
    -- Pick a random word from the list
    local num = math.floor( self.stage ) + 2
    self.word = string.lower( WordList[num][math.random( 1, #WordList[num])] )
end

function Anagram:scrambleWord(word)
    -- Scramble word into a table
    self.scramble = {}
    for letter in word:gmatch("%l") do
        local let = string.lower( letter )
        local dir = math.random(-1, 1)
        if dir == 1 then
            table.insert(self.scramble, { txt = let })
        else
            table.insert(self.scramble, 1, { txt = let })
        end
    end
    
    if self:arrangedRight() then
        -- Switch it up if still correct
        self:scrambleWord(self.word)
    end
    
    self:adjustWordPositions()
end

function Anagram:adjustWordPositions()
    -- Get x position to draw words centered on screen
    font(WORDFONT) fontSize(self.fontSize) textWrapWidth(WIDTH) textAlign(CENTER)
    local wordW, wordH = textSize(self:getScrambleString())
    local prevW, prevH = 0, 0
    local letW, letH = textSize(self.scramble[1])
    local x = (WIDTH / 2 - wordW / 2) - letW / 2
    for i, letter in ipairs(self.scramble) do
        local letW, letH = textSize(letter.txt)
        x = x + prevW / 2 + letW /2
        
        letter.x = x
        letter.y = HEIGHT / 2
        letter.w = letW
        letter.h = letH
        
        prevW = letW
    end
end

function Anagram:getScrambleString()
    -- Returns the scrambled word as a string from the table
    local str = ""
    for i, letter in ipairs(self.scramble) do
        str = str .. letter.txt
    end
    
    return str
end

function Anagram:arrangedRight()
    local correct = true
    for i, letter in ipairs(self.scramble) do
        if letter.txt ~= self.word:sub(i, i) then
            correct = false
        end
    end
    
    return correct
end

function Anagram:wordExists(word)
    for i, t in ipairs(WordList) do
        for _, w in ipairs(t) do
            if string.lower( w ) == string.lower( word ) then
                return true
            end
        end
    end

    return false
end

function Anagram:checkWordOrder()
    -- Check if scrambled word has been changed to correct order
    if self:arrangedRight() then
        -- If yes, activate win sequence
        self:win()
    elseif self:wordExists(self:getScrambleString()) then
        -- If not right, but word exists, notify user
        self.popup:initiate(self.realbutwrong)
    end
end

function Anagram:win()
    -- Set winning state
    self.winning = true

    self.showingprev = false

    self:lockThings()

    if self.mode ~= PARTY then
        -- Increase score
        self:changeScore(math.floor(self.stage))

        -- Increase skips
        self:changeSkips(1 / self.perStage)
    end

    if self.mode == SPEED then
        self.timer:restart()
    end

    -- Increase stage
    self:changeStage(1 / self.perStage)
    
    -- Transition to new word
    tween.delay(0.0001, function() self:transitionToNew() end)
end

function Anagram:transitionToNew()
    -- Slide transition to new word
    self.transitioning = true

    self.prevword = self.word
    
    self.transition[1] = self:getScrambleString()
    self:getNew()
    self.transition[2] = self:getScrambleString()
    self.transition.off = WIDTH / 2
    tween(0.75, self.transition, { off = -WIDTH * 0.75 }, tween.easing.linear, function()
        self:unlockThings()
    end)
    
    self.transitionSound()
end

function Anagram:skipWord()
    -- Skips to a new word if allowed
    if self.skips < 1 then self.blockSound() return end

    self.showingprev = true

    if self.mode == SPEED then
        self.timer:restart()
    end

    self:changeStage(-1)
    
    self:lockThings()
    self:transitionToNew()
    
    self:changeSkips(-1)
    self:changeScore(-1)
end

function Anagram:changeScore(amnt)
    self.score = math.max(0, self.score + amnt)

    local h = "highscore"
    if self.mode == SPEED then h = "speedhighscore" end
    local l = readLocalData(h) or 0
    if self.score > l then
        self.setHighscore = true
        saveLocalData(h, self.score)
    end
end

function Anagram:changeStage(amnt)
    self.stage = math.min( math.max( self.stage + amnt, 1 ), 10 )
    
    self.fontSize = WIDTH / 6 - ( WIDTH / 350 ) * ( math.floor( self.stage ) - 1 )

    local h = "highstage"
    if self.mode == SPEED then h = "speedhighstage" end
    local l = readLocalData(h) or 0
    if math.floor( self.stage ) > l then
        self.setHighstage = true
        saveLocalData(h, math.floor( self.stage ))
    end
end

function Anagram:changeSkips(amnt)
    self.skips = self.skips + amnt
    
    saveLocalData("AmntSkips", math.floor( self.skips ))
end

function Anagram:lose()
    self.lost = true
    self.timer:pause()
    self.popup:dismiss()

    tween.delay(1.0, function()
        self.score = 0
        self.stage = 1
        self:getNew()
    end)
end

function Anagram:draw()
    if self.showingconf then
        fill(0) font(STANDARDFONT) fontSize(HEIGHT / 15) textAlign(CENTER)
        text("are you sure you want to restart?", WIDTH / 2, HEIGHT / 2)

        self.yesButton:draw()
        self.noButton:draw()
    else
        textWrapWidth(WIDTH) textAlign(LEFT)
        if self.lost then
            fill(255, 0, 0, 255) font(STANDARDFONT) fontSize(HEIGHT / 10) textAlign(CENTER)
            text("you lost\n\nbetter luck next time", WIDTH / 2, HEIGHT / 2)
            textAlign(LEFT)
        else
            font(WORDFONT) fontSize(self.fontSize)
            -- Draw the transition or the word depending on if transitioning
            if self.transitioning then
                -- Draw the winning transition
                if self.winning then fill(self.winFill)
                else fill(self.selectFill) end
                pushMatrix()
                translate(self.transition.off, HEIGHT / 2)
                text(self.transition[1], 0, 0)
                if self.mode == PARTY then
                    pushStyle() pushMatrix() translate(-self.transition.off, -HEIGHT / 2)
                    font(STANDARDFONT) fontSize(self.fontSize / 2) text("pass it!", WIDTH / 2, HEIGHT / 4)
                    popMatrix() popStyle()
                end
                translate(WIDTH * 1.25, 0)
                text(self.transition[2], 0, 0)
                popMatrix()
            else
                font(WORDFONT) fontSize(self.fontSize)
                -- Draw the word
                for i, letter in ipairs(self.scramble) do
                    if letter.selected then
                        fill(self.selectFill)
                    else
                        fill(self.fill)
                    end
            
                    text(letter.txt, letter.x, letter.y)
                end
            end

            font(STANDARDFONT)

            fontSize(self.smallFS) fill(self.fill)

            if self.showingprev then
                text("previous word: " .. self.prevword, WIDTH / 2, HEIGHT / 4)
            end
        end
    end

    font(STANDARDFONT)

    fontSize(self.smallFS) fill(self.fill)

    local infoStr
    if self.mode == NORMAL then
        -- Draw info in top-left corner
        local stage = math.floor( self.stage )

        infoStr = "mode: standard\nscore: " .. self.score .. "\nstage: " .. stage .. "\nskips: " .. math.floor(self.skips)

        -- Draw best stats in top-right corner
        local highscore = readLocalData("highscore") or "not yet played"
        local highstage = readLocalData("highstage") or "not yet played"

        local bestScore, bestWord = "highest score: " .. highscore, "highest stage: " .. highstage
        local bsw, bsh = textSize(bestScore)
        local bww, bwh = textSize(bestWord)
        local bw, bh = math.max(bsw, bww), math.max(bsh, bwh)

        pushStyle() smooth() textMode(CORNER)

        fill(self.fill) if self.setHighscore then fill(self.winFill) end
        text(bestScore, WIDTH - bw - self.border, HEIGHT - bh - self.border / 2)
        fill(self.fill) if self.setHighstage then fill(self.winFill) end
        text(bestWord,  WIDTH - bw - self.border, HEIGHT - bh * 2 - self.border / 2)

        popStyle()
    elseif self.mode == SPEED then
        if not self.showingconf then
            self.timer:draw()
        end

        infoStr = "mode: speed challenge\nscore: " .. self.score .. "\nstage: " .. math.floor( self.stage ) .. "\nskips: " .. math.floor( self.skips )
        -- Draw best stats in top-right corner
        local highscore = readLocalData("speedhighscore") or "not yet played"
        local highstage = readLocalData("speedhighstage") or "not yet played"

        local bestScore, bestWord = "highest score: " .. highscore, "highest stage: " .. highstage
        local bsw, bsh = textSize(bestScore)
        local bww, bwh = textSize(bestWord)
        local bw, bh = math.max(bsw, bww), math.max(bsh, bwh)

        pushStyle() smooth() textMode(CORNER)

        fill(self.fill) if self.setHighscore then fill(self.winFill) end
        text(bestScore, WIDTH - bw - self.border, HEIGHT - bh - self.border / 2)
        fill(self.fill) if self.setHighstage then fill(self.winFill) end
        text(bestWord,  WIDTH - bw - self.border, HEIGHT - bh * 2 - self.border / 2)

        popStyle()
    elseif self.mode == PARTY then
        infoStr = "mode: party\nstage: " .. math.floor( self.stage)
    end

    textMode(CENTER) textAlign(LEFT)
    local iw, ih = textSize(infoStr)
    text(infoStr, iw / 2 + self.border, HEIGHT - ih / 2 - self.border / 2)

    -- Draw the buttons
    for i, btn in ipairs(self.buttons) do
        if self.mode ~= PARTY or i == 1 or (self.lost and i == 2) then
            btn:draw()
        end
    end

    -- Draw popup
    if not self.showingconf then
        self.popup:draw()
    end
end

function Anagram:touched(t)
    if self.timer.paused then
        self.timer:resume()
    end

    -- If touch is locked, stop
    if self.tlocked then return end
    
    -- Allow letter to be dragged to new position
    if not self.lost or self.showingconf then
        for i, letter in ipairs(self.scramble) do
            if t.x >= letter.x - letter.w / 2 and t.x <= letter.x + letter.w / 2
            and t.y >= letter.y - letter.h / 2 and t.y <= letter.y + letter.h / 2
            and t.state == BEGAN and not self.holding then
                -- Make popup go away
                self.popup:dismiss()

                -- Select the letter
                letter.selected = true
                self.holding = true
            elseif t.state == MOVING and letter.selected then
                local prevLet = self.scramble[math.max(1, i - 1)]
                local nextLet = self.scramble[math.min(#self.scramble, i + 1)]
                if t.x > nextLet.x and nextLet ~= letter then
                    -- Switch the letters
                    self.scramble[i + 1] = letter
                    self.scramble[i] = nextLet

                    -- Adjust the positions
                    self:adjustWordPositions()
                elseif t.x < prevLet.x and prevLet ~= letter then
                    -- Switch the letters
                    self.scramble[i - 1] = letter
                    self.scramble[i] = prevLet
                
                    -- Adjust the positions
                    self:adjustWordPositions()
                end
            elseif t.state == ENDED and letter.selected then
                -- De-select the letter
                letter.selected = false
                self.holding = false

                -- Check if won
                self:checkWordOrder()
            end
        end
    end

    -- Buttons
    for i, btn in ipairs(self.buttons) do
        if self.mode ~= PARTY or i == 1 or (self.lost and i == 2) then
            btn:touched(t)
        end
    end

    if self.showingconf then
        self.yesButton:touched(t)
        self.noButton:touched(t)
    end
end
