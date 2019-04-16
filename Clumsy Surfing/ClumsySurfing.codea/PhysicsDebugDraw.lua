PhysicsDebugDraw = class()

function PhysicsDebugDraw:init()
    self.bodies = {}
    self.joints = {}
    self.touchMap = {}
    self.contacts = {}
    self.drawJoints = true
    self.drawContacts = true
    self.drawBodies = true
end

function PhysicsDebugDraw:addBody(body, tex)
    tex = tex or body.texture
    
    local m = mesh()
    local cpoints = {}
    if body.shapeType == POLYGON then
        cpoints = body.points
    elseif body.shapeType == CIRCLE then
        for angle = 0, 359, 1 do
            table.insert(cpoints, vec2(math.cos(math.rad(angle)) * body.radius, math.sin(math.rad(angle)) * body.radius))
        end
    end
    
    local tris = triangulate(cpoints)
    local uvs = {}
    local lx, ly = math.huge, math.huge
    local hx, hy = -lx, -ly
    for i = 1,#tris do
        local v = tris[i]
        if v.x < lx then lx = v.x end
        if v.y < ly then ly = v.y end
        if v.x > hx then hx = v.x end
        if v.y > hy then hy = v.y end
    end
    local off = vec2(0 - lx, 0 - ly)
    local w, h = hx - lx, hy - ly
    for i = 1, #tris do
        local v = tris[i]
        table.insert(uvs, vec2((v.x + off.x) / w, (v.y + off.y) / h))
    end
    m.vertices = tris
    m.texCoords = uvs
        
    body.fillMesh = m
        
    if tex then
        body.mesh = mesh()
        body.mesh.texture = tex
        body.mesh.vertices = body.fillMesh.vertices
        body.mesh.texCoords = body.fillMesh.texCoords
        body.mesh:setColors(color(255))
    end
    
    table.insert(self.bodies,body)
end

function PhysicsDebugDraw:removeBody(byebye)
    for i, body in ipairs(self.bodies) do
        if body == byebye then
            body:destroy()
            table.remove(self.bodies, i)
        end
    end
end

function PhysicsDebugDraw:addJoint(joint)
    table.insert(self.joints,joint)
end

function PhysicsDebugDraw:removeJoint(byebye)
    for i, joint in ipairs(self.joints) do
        if joint == byebye then
            joint:destroy()
            table.remove(self.joints, i)
        end
    end
end

function PhysicsDebugDraw:clear()
    -- deactivate all bodies
    
    for i,body in ipairs(self.bodies) do
        body:destroy()
    end
  
    for i,joint in ipairs(self.joints) do
        joint:destroy()
    end      
    
    self.bodies = {}
    self.joints = {}
    self.contacts = {}
    self.touchMap = {}
end

function PhysicsDebugDraw:draw()
    
    pushStyle()
    --smooth()
    strokeWidth(5)
    stroke(128,0,128)
    
    local gain = 2.0
    local damp = 0.5
    for k,v in pairs(self.touchMap) do
        local worldAnchor = v.body:getWorldPoint(v.anchor)
        local touchPoint = v.tp
        local diff = touchPoint - worldAnchor
        local vel = v.body:getLinearVelocityFromWorldPoint(worldAnchor)
        v.body:applyForce( (1/1) * diff * gain - vel * damp, worldAnchor)
        
        line(touchPoint.x, touchPoint.y, worldAnchor.x, worldAnchor.y)
    end
    
    
    stroke(255,255,255,255)
    noFill()
    
    if self.drawBodies then
        for i,body in ipairs(self.bodies) do
            pushMatrix()
            translate(body.x, body.y)
            rotate(body.angle)
            
            if body.colour then
                stroke(body.colour)
            elseif body.type == STATIC then
                stroke(255,255,255,255)
            elseif body.type == DYNAMIC then
                stroke(255, 255, 255, 255)
            elseif body.type == KINEMATIC then
                stroke(150,150,255,255)
            end
            local r, g, b, a = stroke()
            body.fillMesh:setColors(r, g, b, 200)
            
            if not (body.mesh and USE_TEXTURE) then
                body.fillMesh:draw()
            end
            
            if body.mesh and USE_TEXTURE then
                body.mesh:draw()
            elseif body.shapeType == POLYGON then
                strokeWidth(3.0)
                local points = body.points
                for j = 1,#points do
                    a = points[j]
                    b = points[(j % #points)+1]
                    line(a.x, a.y, b.x, b.y)
                end
            elseif body.shapeType == CHAIN or body.shapeType == EDGE then
                strokeWidth(3.0)
                local points = body.points
                for j = 1,#points-1 do
                    a = points[j]
                    b = points[j+1]
                    line(a.x, a.y, b.x, b.y)
                end      
            elseif body.shapeType == CIRCLE then
                strokeWidth(3.0)
                line(0,0,body.radius-3,0)            
                ellipse(0,0,body.radius*2)
            end
            
            popMatrix()
        end 
    end
    
    stroke(255, 75, 0, 255)
    strokeWidth(5)
    
    if self.drawJoints then
        for k,joint in pairs(self.joints) do
            local a = joint.bodyA
            local b = joint.anchorA
            local c = joint.anchorB
            local d = joint.bodyB
            --line(a.x,a.y,b.x,b.y)
            line(b.x,b.y,c.x,c.y)
            --line(c.x,c.y,d.x,d.y)
        end
    end
    
    stroke(255, 0, 0, 255)
    fill(255, 0, 0, 255)

    if self.drawContacts then
        for k,v in pairs(self.contacts) do
            for m,n in ipairs(v.points) do
                ellipse(n.x, n.y, 10, 10)
            end
        end
    end
    
    popStyle()
end

function PhysicsDebugDraw:touched(touch)
    local touchPoint = vec2(touch.x, touch.y)
    if touch.state == BEGAN then
        for i,body in ipairs(self.bodies) do
            if body.type == DYNAMIC and body:testPoint(touchPoint) then
                self.touchMap[touch.id] = {tp = touchPoint, body = body, anchor = body:getLocalPoint(touchPoint)} 
                return true
            end
        end
    elseif touch.state == MOVING and self.touchMap[touch.id] then
        self.touchMap[touch.id].tp = touchPoint
        return true
    elseif touch.state == ENDED and self.touchMap[touch.id] then
        self.touchMap[touch.id] = nil
        return true
    end
    return false
end

function PhysicsDebugDraw:collide(contact)
    if contact.state == BEGAN then
        self.contacts[contact.id] = contact
        sound(SOUND_HIT, 2643)
    elseif contact.state == MOVING then
        self.contacts[contact.id] = contact
    elseif contact.state == ENDED then
        self.contacts[contact.id] = nil
    end
end
