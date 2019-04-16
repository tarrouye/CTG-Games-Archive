IntroScreen = class()

function IntroScreen:init()
    self.sequenceOver = false
    
    self.rippling = true
    self.fade = 0
    
    self.logo = mesh()
    self.logo.shader = shader("Effects:Ripple")
    self.logo.texture = readImage("Documents:GSTnlogy")
    self.logo:addRect(WIDTH/2, HEIGHT/2, WIDTH/2, WIDTH/4)
    self.logo.shader.freq = .3
    
    local col1 = color(0, 168, 255, 255)
    self.messageColor = col1
    self.messageColor.a = 0
    
    self.easing = tween.easing.cubicOut
    
    tween(2, self.logo.shader, { freq = 0.1 }, self.easing, function()
        self.rippling = false
        self.swirlTime = 0
        self.logo.shader = shader("Effects:Swirl")
        self.logo.shader.texSize = vec2(WIDTH/2, WIDTH/4)
        self.logo.shader.radius = 200.0
        tween(1.0, self, { swirlTime = 3.15, fade = 255 }, self.easing, function ()
            self.logo.texture = readImage("Documents:GSLogo")
            tween(1.0, self, { swirlTime = 0, fade = 0 }, self.easing, 
                function()
                    self.rippling = true
                    self.logo.shader = shader("Effects:Ripple")
                    self.logo.shader.freq = 0.1
                end)
        end)
    end)
end

function IntroScreen:loaded()
    local col2 = color(255, 0, 192, 255)
    tween(1.75, self, { messageColor = col2 }, { easing = self.easing, loop = tween.loop.pingpong })
                
    tween(1, self.messageColor, { a = 255 }, self.easing,
    function()       
        self.sequenceOver = true
    end)
end

function IntroScreen:draw()
    --[[pushStyle()
    noSmooth()
    fill(0) stroke(0)
    rect(-1, -1, WIDTH + 2, HEIGHT + 2)
    popStyle()--]]
    
    if self.rippling then
        self.logo.shader.time = ElapsedTime
    else
        self.logo.shader.angle = math.tan(self.swirlTime)
    end
    self.logo:draw()
    
    fill(0, self.fade)
    rectMode(CENTER)
    rect(WIDTH/2, HEIGHT/2, WIDTH*1.01, HEIGHT*1.01)
    
    
    if self.messageColor.a > 0 then
        fill(self.messageColor) fontSize(hScale(35))
        font(STANDARDFONT)
        text("tap to start", WIDTH/2, HEIGHT/4)
    end
end

function IntroScreen:touched(touch)
    if self.sequenceOver and touch.state == ENDED then
        tween.delay(0.8, function() SManager:change("Start") end)
        tween(3, self.logo.shader, { freq = 2 }, self.easing)
    end
end
