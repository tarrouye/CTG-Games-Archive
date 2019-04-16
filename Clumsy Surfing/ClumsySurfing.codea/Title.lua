Title = class()

function Title:init(x)
    self.buttons = {
        TextButton("CLUMSY SURFING", WIDTH / 2, HEIGHT * 3/4, function() sound("A Hero's Quest:Water Splash") end, MIN_DIMENSION / 8),

        TextButton("LET'S PLAY", WIDTH / 2, HEIGHT / 2, function() Scene:change("game") end, MIN_DIMENSION / 10)
    }
end

function Title:draw()
    for i,b in ipairs(self.buttons) do
        b:draw()
    end
end

function Title:touched(t)
    local tb = false
    for i,b in ipairs(self.buttons) do
        if (b:touched(t)) then
            tb = true
        end
    end

    return tb
end
