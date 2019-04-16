Waves = class()

function Waves:init(x)
    -- you can accept and set parameters here
    self.parts = {}
    self.rangers = {}
    self.m = mesh()
    for i=1,100 do
        self.parts[i]={}
        self.rangers[i] = nil
        self.parts[i].pos = vec2()
        --self.parts[i].r = self.m:addRect(1,1,1,1)
    end
    --self.col = color(50,50,255,150)
    self.col = color(0, 143, 255, 255)
    
    self.speedMult = 1

    self.usedtobefifty = 50 * SCALAR
end

function Waves:waveCollide(ply)
    for k,v in pairs(self.parts) do
        --if math.abs(ply.board.x-v.pos.x)<120 then
            self.rangers[k] = physics.raycast(vec2(v.pos.x,0),v.pos,1)
        --end
    end
end

function Waves:draw(ply)
    local wh = WIDTH/(#self.parts-1)
    local mv = {}
    mv[0]=vec2(0,0)
    local ptch = false
    for k,v in pairs(self.parts) do
        v.pos = vec2((k-1)*wh,math.sin(k*0.1+ElapsedTime*self.speedMult)*self.usedtobefifty+(self.usedtobefifty*2+k*0.75))
        --self.m:setRect(v.r,v.pos.x,v.pos.y/2,wh,v.pos.y)
        local rc = self.rangers[k]
        if rc and rc.body then
            local bd = rc.body
            local vel = bd:getLinearVelocityFromWorldPoint(rc.point)
            if bd ~= nil and rc.point ~= nil and rc.normal ~= nil and rc.fraction ~= nil and vel ~= nil then
                bd:applyForce(-rc.normal*(1-rc.fraction)*self.usedtobefifty*4-vec2(0,vel.y/20),rc.point)
            end 
            ptch = true
            --self.m:setRect(v.r,v.pos.x,v.pos.y*0.5*rc.fraction,wh,v.pos.y*rc.fraction)
            mv[k]=vec2(v.pos.x,v.pos.y*rc.fraction)
            --bd:applyForce(vec2(Gravity.x*10,0))
            if not self.rangers[k-1] then
                for i=k-1,k-10,-1 do
                    local p = self.parts[i]
                    if not self.rangers[i] and p and mv[i+1] then
                        mv[i]=vec2(p.pos.x,(p.pos.y+mv[i+1].y)/2)
                    end
                end
            end
            if not self.rangers[k+1] then
                for i=k+1,k+10 do
                    local p = self.parts[i]
                    if not self.rangers[i] and p and mv[i-1] then
                        mv[i]=vec2(p.pos.x,(p.pos.y+mv[i-1].y)/2)
                    end
                end
            end
            if ply and ply.alive and ply.board.x<WIDTH*0.3 then
                bd.linearVelocity = vec2(bd.linearVelocity.x+(WIDTH*0.5-bd.x)/400,bd.linearVelocity.y)
            end
            if ply.alive and ply:wouldDie() then
                ply:kill()
            end
        else
            if not mv[k] then
                mv[k]=v.pos
            end
        end
    end
    table.insert(mv,vec2(WIDTH,0))
    table.insert(mv,vec2(0,0))
    ply.touchingWater = ptch
    self.m.vertices = triangulate(mv)
    self.m:setColors(self.col)
    self.m:draw()
     
    self.speedMult = self.speedMult + DeltaTime / 60 -- Speed goes up at a rate of 1 per minute
end

function Waves:touched(touch)
    -- Codea does not automatically call this method
end

