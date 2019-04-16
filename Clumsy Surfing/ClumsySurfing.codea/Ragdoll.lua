Ragdoll = class()


local bodyBox = function(width, height, x, y, tex)
    local box = physics.body(POLYGON, vec2(-width / 2, -height / 2), vec2(width / 2, -height / 2), vec2(width / 2, height / 2), vec2(-width / 2, height / 2))
    box.restitution = 0.1
    box.friction = 0.4
    box.bullet = true
    box.position = vec2(x, y)
    --box.fixedRotation = true
    box.texture = tex
    box.sleepingAllowed = false

    return box
end

local bodyJoint = function(lower, upper, b1, b2, x, y)
    local joint = physics.joint(REVOLUTE, b1, b2, vec2(x, y))
    joint.enableLimit = true
    joint.lowerLimit = lower
    joint.upperLimit = upper
    
    return joint
end

function Ragdoll:init(x, y, board)
    self.bones, self.joints = {}, {}
    
    -- Sizes
    local scaler = (MAX_DIMENSION / 1024)
    local headSize = 50 * scaler
    local torsoWidth, torsoHeight = 30 * scaler, 20 * scaler
    local upperArmWidth, upperArmHeight = 13 * scaler, 36 * scaler
    local lowerArmWidth, lowerArmHeight = 12 * scaler, 34 * scaler
    local upperLegWidth, upperLegHeight = 15 * scaler, 44 * scaler
    local lowerLegWidth, lowerLegHeight = 12 * scaler, 40 * scaler
    local boardWidth, boardHeight = 120 * scaler, 12 * scaler
    
    -- Textures
    local headTexture = readImage("Cargo Bot:Crate Blue 1")
    local torsoTexture = readImage("Cargo Bot:Crate Yellow 1")
    local upperArmTexture = readImage("Cargo Bot:Crate Yellow 2")
    local lowerArmTexture = readImage("Cargo Bot:Crate Yellow 3")
    local upperLegTexture = readImage("Cargo Bot:Crate Yellow 1")
    local lowerLegTexture = readImage("Cargo Bot:Crate Yellow 1")
    
    
    -- Bones
    -- Head
    local head = physics.body(CIRCLE, headSize / 2)
    head.restitution = 0.300
    head.friction = 0.4
    head.bullet = true
    --head.fixedRotation = true
    head.position = vec2(x, y)
    head.sleepingAllowed = false
    
    head.texture = headTexture
    
    self.bones[1] = head
    
    -- Torso
    self.bones[2] = bodyBox(torsoWidth, torsoHeight, x, y - headSize / 2 - torsoHeight / 2, torsoTexture)

    self.bones[3] = bodyBox(torsoWidth, torsoHeight, x, y - headSize / 2 - torsoHeight * 1.5, torsoTexture)

    self.bones[4] = bodyBox(torsoWidth, torsoHeight, x, y - headSize / 2 - torsoHeight * 2.5, torsoTexture)
    
    -- Arms
    self.bones[5] = bodyBox(upperArmWidth, upperArmHeight, x - torsoWidth / 2 - upperArmWidth / 2, y - headSize / 2 - upperArmHeight / 2, upperArmTexture)
    
    self.bones[6] = bodyBox(upperArmWidth, upperArmHeight, x + torsoWidth / 2 + upperArmWidth / 2, y - headSize / 2 - upperArmHeight / 2, upperArmTexture)
    
    self.bones[7] = bodyBox(lowerArmWidth, lowerArmHeight, x - torsoWidth / 2 - upperArmWidth / 2, y - headSize / 2 - upperArmHeight - lowerArmHeight / 2, lowerArmTexture)
    
    self.bones[8] = bodyBox(lowerArmWidth, lowerArmHeight, x + torsoWidth / 2 + upperArmWidth / 2, y - headSize / 2 - upperArmHeight - lowerArmHeight / 2, lowerArmTexture)
    
    -- Legs
    self.bones[9] = bodyBox(upperLegWidth, upperLegHeight, x - upperLegWidth / 2, y - headSize / 2 - torsoHeight * 3 - upperLegHeight / 2, upperLegTexture)
    
    self.bones[10] = bodyBox(upperLegWidth, upperLegHeight, x + upperLegWidth / 2, y - headSize / 2 - torsoHeight * 3 - upperLegHeight / 2, upperLegTexture)
    
    self.bones[11] = bodyBox(lowerLegWidth, lowerLegHeight, x - upperLegWidth / 2, y - headSize / 2 - torsoHeight * 3 - upperLegHeight - lowerLegHeight / 2, lowerLegTexture)
    
    self.bones[12] = bodyBox(lowerLegWidth, lowerLegHeight, x + upperLegWidth / 2, y - headSize / 2 - torsoHeight * 3 - upperLegHeight - lowerLegHeight / 2, lowerLegTexture)
    
    if board then
        self.bones[13] = bodyBox(boardWidth, boardHeight, x, y - headSize / 2 - torsoHeight * 3 - upperLegHeight - lowerLegHeight - boardHeight / 2)
    end
    
    -- Joints
    
    -- Head to torso
    self.joints[1] = bodyJoint(-40, 40, self.bones[2], self.bones[1], x, y - headSize / 2)
    
    -- Upper arms to torso
    self.joints[2] = bodyJoint(-85, 130, self.bones[2], self.bones[5], x - torsoWidth / 2, y - headSize / 2)
    self.joints[3] = bodyJoint(-130, 85, self.bones[2], self.bones[6], x + torsoWidth / 2, y - headSize / 2)
    
    -- Upper arms to lower arms
    self.joints[4] = bodyJoint(-130, 10, self.bones[5], self.bones[7], x - torsoWidth / 2 - upperArmWidth / 2, y - headSize / 2 - upperArmHeight)
    self.joints[5] = bodyJoint(-10, 130, self.bones[6], self.bones[8], x + torsoWidth / 2 + upperArmWidth / 2, y - headSize / 2 - upperArmHeight)
    
    -- Torsos (Shoulders -> Stomach -> Hips)
    self.joints[6] = bodyJoint(-15, 15, self.bones[2], self.bones[3], x, y - headSize / 2 - torsoHeight)
    self.joints[7] = bodyJoint(-15, 15, self.bones[3], self.bones[4], x, y - headSize / 2 - torsoHeight * 2)
    
    -- Hips to upper legs
    self.joints[8] = bodyJoint(-25, 45, self.bones[4], self.bones[9], x - upperLegWidth / 2, y - headSize / 2 - torsoHeight * 3)
    self.joints[9] = bodyJoint(-45, 25, self.bones[4], self.bones[10], x + upperLegWidth / 2, y - headSize / 2 - torsoHeight * 3)
    
    -- Upper legs to lower legs
    self.joints[10] = bodyJoint(-25, 115, self.bones[9], self.bones[11], x - upperLegWidth / 2, y - headSize / 2 - torsoHeight * 3 - upperLegHeight)
    self.joints[11] = bodyJoint(-115, 25, self.bones[10], self.bones[12], x + upperLegWidth / 2, y - headSize / 2 - torsoHeight * 3 - upperLegHeight)
    
    -- Lower legs to board
    if board then
        self.joints[12] = bodyJoint(0, 0, self.bones[11], self.bones[13], x - upperLegWidth / 2, self.bones[13].y + boardHeight / 2)
        self.joints[13] = bodyJoint(0, 0, self.bones[12], self.bones[13], x + upperLegWidth / 2, self.bones[13].y + boardHeight / 2)
    end
    
    for i, bone in pairs(self.bones) do
        DebugDraw:addBody(bone)
    end
    
    for i, joint in pairs(self.joints) do
        DebugDraw:addJoint(joint)
    end
end

function Ragdoll:remove()
    for i, bone in pairs(self.bones) do
        DebugDraw:removeBody(bone)
    end
    
    for i, joint in pairs(self.joints) do
        DebugDraw:removeJoint(joint)
    end
end
