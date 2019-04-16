Credits = class()

function Credits:init()
    local bs = vec2(wScale(143), hScale(50))
    self.backButton = Button("Dropbox:FLBack", bs.x/2, HEIGHT - bs.y/2, function() SManager:change("Start") end,bs)
    
    self.credits = {
        { title = "Coding",
          body = [[Coding by Théo Arrouye
    
Scroll Controller Class (Level Selection Screen) by @SkyTheCoder
    
Fysuzzles was coded using Codea for iPad]]
        },
    
        { title = "Music",
          body = [[All music designed exclusively for Fysuzzles by Kai Levidow.]],
        bodyFs = wScale(25)
        },
    
        { title = "Graphics",
          body = [[Graphics by Théo Arrouye
    
Glowing Line Shader by @Luatee
    
Platformer Art by Kenney.nl
(www.kenney.nl)]]
        },
    
        { title = "Level Design",
          body = [[Levels designed by Théo Arrouye, Kai Levidow and Dylan Rank
    
All levels were made using the same level editor available in-game]]
        },
    
        { title = "Thanks",
          body = [[Thanks to all the beta testers:
George Song
Kohl Reddy
Jack Densmore
    
Thanks to the TwoLivesLeft for the amazing environment that is Codea
    
Finally, thanks to you for playing Fysuzzles. We hope you enjoy!]]
        }
    }
    
    self.titleFs = wScale(75)
    self.bodyFs = wScale(35)
    
    self.dotSize = { empty = 20, filled = 13 }

    self.slide = 1
    self.nextSlide = 1
    self.drawSlide = 1
    self.slideSpeed = 0.65
end

function Credits:onEnter()
    self.slide = 1
    self.nextSlide = 1
    self.drawSlide = 1
end

function Credits:draw()
    pushStyle()
    
    self.backButton:draw()
    
    fill(topCol)font(STANDARDFONT)
    textWrapWidth(WIDTH - 10) textAlign(CENTER)
    
    pushMatrix()
    
    translate(-self.drawSlide *(WIDTH*3), 0)
    
    for id, credit in ipairs(self.credits) do
        pushMatrix()
        
        translate(id * (WIDTH*3), 0)
        
        if self.slide == id or self.nextSlide == id then
            fontSize(self.titleFs)
            text(credit.title,WIDTH/2, HEIGHT - self.titleFs/2)
            
            fontSize(credit.bodyFs or self.bodyFs)
            text(credit.body,WIDTH/2, HEIGHT/2)
        end
        
        popMatrix()
    end
    
    popMatrix()
    
    for i = 1, #self.credits do
        local x = (WIDTH / 6) * i
        
        stroke(topCol) strokeWidth(2) noFill()
        
        ellipse(x, self.dotSize.empty, self.dotSize.empty)
    end
    
    fill(topCol) ellipse((WIDTH/6) * self.drawSlide, self.dotSize.empty, self.dotSize.filled)
    
    popStyle()
end

function Credits:touched(touch)
    if self.backButton:touched(touch) then return end
    
    local easing = tween.easing.sineInOut
    
    local slide
    if touch.state == ENDED and not self.sliding then
        if touch.x >= WIDTH / 2 then
            slide = self.slide + 1
        else
            slide = self.slide - 1 
        end
        
        if slide < 1 then slide = #self.credits end
        if slide > #self.credits then slide = 1 end
        
        self.nextSlide = slide
        self.sliding = true
        tween(self.slideSpeed, self, { drawSlide = slide }, easing, function() self.slide = slide self.sliding = false end)
        tween(self.slideSpeed/2, self.dotSize, { filled = 25 }, tween.easing.linear, 
        function() tween(self.slideSpeed/2, self.dotSize, { filled = 13 }, tween.easing.linear) end)
    end
end

