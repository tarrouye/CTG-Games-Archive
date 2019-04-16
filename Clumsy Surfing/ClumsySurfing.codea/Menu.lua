Menu = class()

function Menu:init()
    self.pages = PageController(Title(), Settings())
end

function Menu:draw()
    self.pages:draw()
    DebugDraw:draw()
end

function Menu:touched(t)
    if not DebugDraw:touched(t) then
        self.pages:touched(t)
    end
end
