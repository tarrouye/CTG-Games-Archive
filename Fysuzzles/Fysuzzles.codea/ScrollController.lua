-- By @SkyTheCoder
-- Slightly modified by @JakAttak

local mult = function(i)
    if i > 0 then
        return 1
    else
        return -1
    end
end

ScrollController = class()

function ScrollController:init()
    self.offset = {x = 0, y = 0}
    self.mot = {x = 0, y = 0}
    self.lastSigTouch = vec2(0, 0)
    self.lastSigTouchTime = 0
    self.deltaCache = {}
    self.tweenedX = false
    self.tweenedY = false
    self.moving = false -- JA
    self.tid = 0
    self.lastState = BEGAN
    self.minX, self.minY, self.maxX, self.maxY = 0, 0, 0, 0
end

function ScrollController:setMinX(i)
        self.minX = i
        return self
end

function ScrollController:setMinY(i)
        self.minY = i
        return self
end

function ScrollController:setMaxX(i)
        self.maxX = i
        return self
end

function ScrollController:setMaxY(i)
        self.maxY = i
        return self
end

function ScrollController:update()
        while #self.deltaCache > 5 do
            table.remove(self.deltaCache, 1)
        end

        if self.lastState == ENDED or self.lastState == CANCELLED then
            if not self.tweenedX then
                self.mot.x = self.mot.x * 0.96

                self.mot.x = tonumber(string.format("%.3f", tostring(self.mot.x)))

                self.offset.x = self.offset.x + self.mot.x
            end

            if not self.tweenedY then
                self.mot.y = self.mot.y * 0.96

                self.mot.y = tonumber(string.format("%.3f", tostring(self.mot.y)))

                self.offset.y = self.offset.y + self.mot.y
            end

            if not self.tweenedX and self.offset.x < self.minX then
                self.mot.x = 0
                self.moving = tween(0.5, self.offset, {x = self.minX}, tween.easing.quadOut, function()
                    self.tweenedX = false
                    self.moving = nil
                end)
                self.tweenedX = true
            end

            if not self.tweenedY and self.offset.y < self.minY then
                self.mot.y = 0
                self.moving = tween(0.5, self.offset, {y = self.minY}, tween.easing.quadOut, function()
                    self.tweenedY = false
                    self.moving = nil
                end)
                self.tweenedY = true
            end

            if not self.tweenedX and self.offset.x > self.maxX then
                self.mot.x = 0
                self.moving = tween(0.5, self.offset, {x = self.maxX}, tween.easing.quadOut, function()
                    self.tweenedX = false
                    self.moving = nil
                end)
                self.tweenedX = true
            end

            if not self.tweenedY and self.offset.y > self.maxY then
                self.mot.y = 0
                self.moving = tween(0.5, self.offset, {y = self.maxY}, tween.easing.quadOut, function()
                    self.tweenedY = false
                    self.moving = false
                end)
                self.tweenedY = true
            end
        end
        return self
end

function ScrollController:touched(touch)
        if touch.state == BEGAN and self.tid == 0 then
            self.lastSigTouch = vec2(touch.x, touch.y)
            self.lastSigTouchTime = ElapsedTime
            self.tid = touch.id
        end

        if touch.id == self.tid then
            self.lastState = touch.state
            if touch.state ~= ENDED and touch.state ~= CANCELLED then
                if not self.tweenedX then
                    self.offset.x = self.offset.x + touch.deltaX
                end

                if not self.tweenedY then
                    self.offset.y = self.offset.y + touch.deltaY
                end

                table.insert(self.deltaCache, {x = touch.deltaX, y = touch.deltaY})

                if math.abs(touch.x - self.lastSigTouch.x) > 5 or math.abs(touch.y - self.lastSigTouch.y) > 5 then
                    self.lastSigTouch = vec2(touch.x, touch.y)
                    self.lastSigTouchTime = ElapsedTime
                end
            else
                local speed = 0

                for k, v in ipairs(self.deltaCache) do
                    if mult(speed) == mult(v.x) then
                        speed = speed + v.x
                    else
                        speed = v.x
                    end
                end

                speed = speed + touch.deltaX

                speed = speed / (#self.deltaCache + 1)

                if not self.tweenedX and ElapsedTime - self.lastSigTouchTime < 0.25 then
                    if mult(self.mot.x) == mult(touch.deltaX) then
                        self.mot.x = self.mot.x + speed
                    else
                        self.mot.x = speed
                    end
                else
                    self.mot.x = 0
                end

                speed = 0

                for k, v in ipairs(self.deltaCache) do
                    if mult(speed) == mult(v.y) then
                        speed = speed + v.y
                    else
                        speed = v.y
                    end
                end

                speed = speed + touch.deltaY

                speed = speed / (#self.deltaCache + 1)

                self.deltaCache = {}

                if not self.tweenedX and ElapsedTime - self.lastSigTouchTime < 0.25 then
                    if mult(self.mot.y) == mult(touch.deltaY) then
                        self.mot.y = self.mot.y + speed
                    else
                        self.mot.y = speed
                    end
                else
                    self.mot.y = 0
                end

                self.tid = 0
            end
        end
end

function ScrollController:getScrolling()
    return not (self.mot.x == 0 and self.mot.y == 0)
end

            


