-- By @JakAttak

All_Joysticks = class()

function All_Joysticks:init(sticks)
    self.joysticks = sticks or {}
end

function All_Joysticks:addSticks(sticks)
    for _, s in pairs(sticks) do
        table.insert(self.joysticks, s)
    end
end

function All_Joysticks:clear()
    self.joysticks = {}
    collectgarbage()
end

function All_Joysticks:releaseAll()
    for i,v in ipairs(self.joysticks) do
        v.tx, v.ty = v.x, v.y
        v.releasedCB()
                
        globalTouches[v.touched] = nil
        v.touched = false
    end
end

function All_Joysticks:draw()
    pushStyle()
    for i,v in ipairs(self.joysticks) do
        if not v.hide then
            if v.initialShowing then
                stroke(65) strokeWidth(WIDTH / 300) noFill() rectMode(CORNERS)
                rect(v.x1, v.y1, v.x2, v.y2)
            end
            if v.initialShowing or v.touched or v.alwaysShow then
                noStroke()
                fill(v.col.r, v.col.g, v.col.b, 127)
                ellipse(v.x, v.y, v.size)
                --fill(65, 65, 65, 184)p
                fill(255 - v.col.r, 255 - v.col.g, 255 - v.col.b, 127)
                ellipse(v.tx, v.ty, v.stickSize)
            end
            if v.touched then
                v.movingCB(self:determineMove(i))
            end
        end
    end     
    popStyle()  
end

function All_Joysticks:determineMove(i)
    j = self.joysticks[i]
    offvec = vec2(j.tx, j.ty) - vec2(j.x, j.y)
    offset = clampLen(offvec, j.size)
    if offset:len() > 0 then
        move = offset:normalize()
    else
        move = vec2(0,0)
    end
    return move
end

function All_Joysticks:unlock()
    for i,v in ipairs(self.joysticks) do
        globalTouches[v.touched] = nil
        v.touched = false
        v.tx, v.ty = v.x, v.y
    end
end

function All_Joysticks:touched(touch)
    for i,v in ipairs(self.joysticks) do
        local center = vec2(v.x, v.y)
        local d = center:dist(vec2(touch.x, touch.y))
        
        local rad = v.size / 2
        local inRange = touch.x > v.x1 and touch.x < v.x2 and touch.y > v.y1 and touch.y < v.y2
        if v.lockedPos then
            inRange = d <= rad
        end
        if not v.hide and (touch.id == v.touched or (not globalTouches[touch.id] and (inRange) and not v.touched)) then
            if touch.state == BEGAN then
                globalTouches[touch.id] = true
                
                v.initialShowing = false
                v.touchedCB()
                v.touched = touch.id
                if not v.lockedPos then
                    v.x = touch.x
                    v.y = touch.y
                end
                v.tx = v.x
                v.ty = v.y
            elseif touch.state == MOVING and touch.id == v.touched then
                local center = vec2(v.x, v.y)
                local d = center:dist(vec2(touch.x, touch.y))
                local off = vec2(touch.x - v.x, touch.y - v.y)
                local lockedOff = off:normalize()*math.min(d, rad)
                v.tx, v.ty = v.x + lockedOff.x, v.y + lockedOff.y
            elseif touch.state == ENDED and touch.id == v.touched then
                v.tx, v.ty = v.x, v.y
                v.touched = false
                v.releasedCB()
                
                globalTouches[touch.id] = nil
            end
        end
    end            
end

function clampLen(vec, maxLen)
    if vec == vec2(0,0) then
        return vec
    else
        return vec:normalize() * math.min(vec:len(), maxLen)
    end
end

