Title = class()

function Title:init()
    self.title = {} 
    
    self.name = "scramblers"
    self.fill = color(0, 0, 0, 255)
    self.fontSize = WIDTH / 7
    self.medFS = WIDTH / 40
    self.border = WIDTH / 50
    self.music = "Game Music One:Happy Song"
    
    self.buttons = {}
    
    -- Create play buttons
    local s = HEIGHT / 4.25
    local pmesh = mesh() pmesh.vertices = { vec2(s/3, s/4), vec2(s/3, s*3/4), vec2(s*3/4, s/2) } pmesh:setColors(255,255,255,255)
    local img = image(s, s) setContext(img)
        pmesh:draw() stroke(self.fill) strokeWidth(2)
        for i = 1, #pmesh.vertices do local a = pmesh.vertices[i] local b = pmesh.vertices[(i%#pmesh.vertices) + 1] line(a.x, a.y, b.x, b.y) end
    setContext()

    local img1, img2 = makeButtonImgs(img, s, self.fill)
    self.buttons[1] = Button(img1, img2, WIDTH / 4, HEIGHT / 3 + s/1.5, function() Scene.scenes["Game"]:setMode(1) Scene:change("Game") end, vec2(s, s))

    local simg = image(s, s) setContext(simg) sprite("Dropbox:DSSpeed", s/2, s/2, s/1.25) setContext()
    local simg1, simg2 = makeButtonImgs(simg, s, self.fill)
self.buttons[2] = Button(simg1, simg2, WIDTH / 2, HEIGHT / 3, function() if readLocalData("unlockedspeed") then Scene.scenes["Game"]:setMode(2) Scene:change("Game") elseif not readLocalData("triedspeed") then alert("You get to try it once, then you have to purchase it in the store", "Trial Run") Scene.scenes["Game"]:setMode(2) Scene:change("Game") saveLocalData("triedspeed", true) else alert("You haven't purchased Speed Challenge Mode yet.", "Visit the Store") end end, vec2(s, s))

    local hpimg = image(s, s) setContext(hpimg) sprite("Dropbox:DSParty", s/2, s/2, s*3/4) setContext()
    local hpimg1, hpimg2 = makeButtonImgs(hpimg, s, self.fill)
    self.buttons[3] = Button(hpimg1, hpimg2, WIDTH*3/4, HEIGHT / 3 + s/1.5, function() Scene.scenes["Game"]:setMode(3) Scene:change("Game") end, vec2(s, s))

    -- Create help button
    local himg = image(s, s) setContext(himg) sprite("Dropbox:DSQuestion", s/2, s/1.9, s/1.5) setContext()
    local himg1, himg2 = makeButtonImgs(himg, s, self.fill)
    self.buttons[4] = Button(himg1, himg2, WIDTH*3/4, HEIGHT / 3 - s/1.5, function() Scene:change("Help") end, vec2(s, s))
    
    -- Create store button
    local simg = image(s, s) setContext(simg) sprite("Dropbox:DSStore", s/2, s/2, s/1.5) setContext()
    local simg1, simg2 = makeButtonImgs(simg, s, self.fill)
    self.buttons[5] = Button(simg1, simg2, WIDTH / 4, HEIGHT / 3 - s/1.5, function() Scene:change("Store") end, vec2(s, s))

    -- Create credit button
    local ctit, cbod = "how was scramblers made?", "coding and graphics by théo arrouye\n\nmusic by matthew vecchio\n\nscramblers was made using codea, available now on the appstore\n\ncodea add-ons by nathan flurry (@zoyt)"
    font(STANDARDFONT) fontSize(self.medFS) local w,h = textSize(ctit)
    self.buttons[6] = TextButton(ctit, w/2 + self.border, h/2 + self.border / 2, function() alert(cbod, ctit) end, self.medFS, color(0))
end

function Title:onEnter()
    if music.name ~= self.music then
        music(self.music, true, 0.9)
    end
    
    self:scrambleWord(self.name)
    
    tween.delay(0.5, function() self:unscrambleTitle() end)
end

function Title:scrambleWord(word)
    -- Scramble word into a table
    self.title = {}
    for letter in word:gmatch("%l") do
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

function Title:centerTitle()
    -- Get x position to draw words centered on screen
    font(STANDARDFONT) fontSize(self.fontSize) textWrapWidth(WIDTH) textAlign(CENTER)
    local wordW, wordH = textSize(self.name)
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

function Title:unscrambleTitle()
    local delay, num = 0, 1
    for let in self.name:gmatch("%a") do
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
        delay = delay + 0.2
    end
end

function Title:draw()
    -- Draw title
    fill(self.fill) font(STANDARDFONT) fontSize(self.fontSize) textWrapWidth(WIDTH) textAlign(LEFT)
    for i, letter in ipairs(self.title) do
        text(letter.txt, letter.x, letter.y)
    end
    
    -- Draw buttons
    for i, btn in ipairs(self.buttons) do
        btn:draw()
    end
end

function Title:touched(t)
    for i, btn in ipairs(self.buttons) do
        btn:touched(t)
    end
end
