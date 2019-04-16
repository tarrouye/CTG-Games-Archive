Popup = class()

function Popup:init(x, y, time)
    self.x, self.y, self.time = x, y, time

    self.txt = ""
    self.size = 0
    self.fullSize = HEIGHT / 12
end

function Popup:initiate(txt)
    self.txt = txt

    self.moving = tween(self.time, self, { size = self.fullSize }, tween.easing.linear)
end

function Popup:dismiss()
    if self.moving ~= nil then
        tween.stop(self.moving)
        self.moving = nil
    end

    self.moving = tween(self.time, self, { size = 0 }, tween.easing.linear)
end

function Popup:draw()
    pushStyle()

    fontSize(self.size) font(STANDARDFONT) fill(255, 0, 0, 255)
    text(self.txt, self.x, self.y)

    popStyle()
end
