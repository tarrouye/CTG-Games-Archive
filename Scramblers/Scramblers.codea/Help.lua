Help = class()

function Help:init(x)
    self.fill = color(0)
    self.border = WIDTH / 50

    local s = WIDTH / 12
    local hmesh = mesh() hmesh.vertices = { vec2(s/4, s/6), vec2(s/4, s*4/6), vec2(s/2, s*5/6), vec2(s/2, s*5/6), vec2(s*3/4, s*4/6), vec2(s*3/4, s/6), vec2(s*3/4, s/6), vec2(s/2, s*5/6), vec2(s/4, s/6) } 
    hmesh:setColors(255,255,255,255)
    local himg = image(s, s) setContext(himg) 
        hmesh:draw() stroke(self.fill) strokeWidth(2)
        for i = 1, #hmesh.vertices-2 do local a = hmesh.vertices[i] local b = hmesh.vertices[(i%(#hmesh.vertices-2)) + 1] line(a.x, a.y, b.x, b.y) end
    setContext()
    local himg1, himg2 = makeButtonImgs(himg, s, self.fill)
    self.homeButton = Button(himg1, himg2, s / 2 + self.border, s / 2 + self.border, function() Scene:change("Title") end, vec2(s, s))

    local pmesh = mesh() pmesh.vertices = { vec2(s/3, s/4), vec2(s/3, s*3/4), vec2(s*3/4, s/2) } pmesh:setColors(255,255,255,255)
    local pimg = image(s, s) setContext(pimg)
        pmesh:draw() stroke(self.fill) strokeWidth(2)
        for i = 1, #pmesh.vertices do local a = pmesh.vertices[i] local b = pmesh.vertices[(i%#pmesh.vertices) + 1] line(a.x, a.y, b.x, b.y) end
    setContext()
    local pimg1, pimg2 = makeButtonImgs(pimg, s, self.fill)
    local nimg = image(s, s) setContext(nimg)
            sprite(pimg, s/2, s/2, -s, s)
    setContext()
    local nimg1, nimg2 = makeButtonImgs(nimg, s, self.fill)
    self.nextButton = Button(pimg1, pimg2, WIDTH - s / 2 - self.border, HEIGHT / 1.8, function() self.slide = self.slide + 1 self.scrollview:reset() end, vec2(s, s))
    self.prevButton = Button(nimg1, nimg2, s / 2 + self.border, HEIGHT / 1.8, function() self.slide = self.slide - 1 self.scrollview:reset() end, vec2(s, s))

    self.slide = 1

    self.help = {}
    self.help[1] = [[how to play standard mode:
    
drag letters around to form words!
    
as you progress, words will get longer
    
to help you, you will unlock 'skips' as you go
('skips' can also be purchased in the shop)
    
if you're stuck on a word, and you have enough skips, you can use the button in the bottom-right to skip it
    
good luck!
    
p.s. just because you made a word, doesn't always mean it is the solution]]

    self.help[2] = [[how to play speed challenge mode:

speed challenge is a single player mode

in this mode, you can't use skips

if you haven't made a word when the timer goes off, you lose

the timer lasts 15 seconds

everytime you make a word, the timer resets

get as far as you can before you run out of time!

(speed challenge mode available in the store)]]

    self.help[3] = [[how to play party mode:

party mode is a multiplayer mode (ideal for 3+ players)

you pass the iDevice around, and whomever has it when the timer ends loses

the timer lasts between one and two minutes, so each game is a different length

as it gets closer to the end, the beeping will intensify

form words the same way as standard mode, but you can't skip

solve at least one word before passing it on]]

    self.scrollview = ScrollView(vec2(0, 0), function() self:drawContent() end)
end

function Help:drawContent()
    font(STANDARDFONT) fill(self.fill) fontSize(HEIGHT / 16) textWrapWidth(WIDTH*5/6) textAlign(CENTER)
    local w,h = textSize(self.help[self.slide])
    text(self.help[self.slide], WIDTH / 2, HEIGHT - h/2)

    self.scrollview.contentSize.y = math.max(h + self.border, 0)
end

function Help:draw()
    self.scrollview:draw()

    -- Draw the buttons
    self.homeButton:draw()

    if self.slide < #self.help then
        self.nextButton:draw()
    end
    if self.slide > 1 then
        self.prevButton:draw()
    end
end

function Help:touched(t)
    self.scrollview:touched(t)

    -- Touch the buttons
    self.homeButton:touched(t)

    if self.slide < #self.help then
        self.nextButton:touched(t)
    end
    if self.slide > 1 then
        self.prevButton:touched(t)
    end
end
