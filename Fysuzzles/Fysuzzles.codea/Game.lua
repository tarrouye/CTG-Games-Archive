Game = class()

function Game:init()
    self.sounds = { 
        start = function() sound("Game Sounds One:1-2 Go") end,
        collide = function() sound("Game Sounds One:Wall Bounce 1") end,
        patroller = function() sound("Game Sounds One:Pop 1") end,
        trap = function() sound("Game Sounds One:Oldskool Death") end,
        blocked = function() sound("Game Sounds One:Menu Select") end,
        locked = function() sound("Game Sounds One:Radar") end,
        key = function() sound("A Hero's Quest:Drop") end,
        win = function() sound("A Hero's Quest:Level Up") end,
        lost = function() sound("Game Sounds One:Pac Death 2") end,
        gravityFlip = function() sound("A Hero's Quest:Hit Monster 1") end
    }
    
    self.images = {
        back = readImage("Cargo Bot:Game Area"),
        key = {unlocked = readImage("Dropbox:hud_keyGreen"), locked = readImage("Dropbox:hud_keyGreen_disabled"),
               onscreen = readImage("Planet Cute:Key")},
        lock = readImage("Dropbox:FLLock"),
        trap = readImage("Dropbox:FLTrap"),
        goal = readImage("Dropbox:FLGoal"),
        patroller = readImage("Dropbox:FLPatrol"),
        switch = readImage("Cargo Bot:Command Grab"),
        repel = readImage("SpaceCute:Planet"),
        suction = readImage("Space Art:UFO"),
        sticky = readImage("Cargo Bot:Goal Area"),
        icy = readImage("Cargo Bot:Fast Button Active"),
        pause = readImage("Dropbox:FLPause"),
        resume = readImage("Dropbox:FLResume"),
        restart = readImage("Dropbox:FLRestart"),
        exit = readImage("Dropbox:FLExit")
    }   

    self.meshes = { patrollers = mesh(), keys = mesh() }
    self.meshes.patrollers.texture = self.images.patroller
    self.meshes.patrollers.noclear = true
    self.meshes.keys.texture = self.images.key.onscreen

    self.loaded = false
    
    self.size = hScale(100)
    self.lockSize = hScale(150)
    self.goalSize = hScale(50)
    self.patrolSize = hScale(35)
    self.switchSize = hScale(40)
    self.hintSize = hScale(50)
    self.repelSize = hScale(200)
    self.suctionSize = hScale(200)
    
    self.repelForce = wScale(1000)
    self.suctionForce = wScale(1000)
    
    self.goalColors = { active = color(0, 255, 17, 255), hovering = color(255, 246, 0, 255), 
                        inactive = color(255, 0, 0, 255) }
    self.winTime = 3
end

function Game:loadLevel(level)
    self.loaded = false
    
    for i, m in pairs(self.meshes) do
        m:clear()
    end
    
    self.mode = level.mode
    self.comId = level.comId
    
    self.playGameMusic = function() 
        if self.mode == "Challenge" then
            music("Dropbox:Amazing Plan", true, 0.7) 
        else
            music("Dropbox:Main Level theme", true, 0.7)
        end
        music.muted = false 
    end
    
    self.walls = {}
    self.gameWalls = level.walls or {}
    
    self.players = level.players
    if #self.players == 0 then
        self.players = { { startPos = vec2(WIDTH - self.size/2, self.size/2) } }
    end
    
    if level.goal == nil then
        self.goal =  vec2(WIDTH - self.size/2, HEIGHT - self.size/2)
    else
        if level.scaled then
            self.goal = vec2(level.goal.x, level.goal.y)
        end
    end
    
    self.hints = {}
    for g,h in ipairs(level.hints) do self.hints[g] = vec2(h.x, h.y) end
    
    self.blockedZones = level.blocked or {}
    
    self.patrollers = {}
    local patrollers = level.patrols or {}
    for i, stuff in ipairs(patrollers) do
        local pWidth = math.abs(stuff.pos1:dist(stuff.pos2))
        
        table.insert(self.patrollers, { pos = stuff.pos1, angle = 0 })
        
        self.patrollers[#self.patrollers].tweenId = tween(pWidth/(WIDTH/3), self.patrollers[#self.patrollers], { pos = stuff.pos2 }, { easing = tween.easing.linear, loop = tween.loop.pingpong })
        
        self.patrollers[#self.patrollers].meshId = self.meshes.patrollers:addRect(stuff.pos1.x, stuff.pos1.y, self.patrolSize, self.patrolSize)
    end
    
    self.origLocks = level.locks or {}
    self.locks = {}
    
    self.traps = level.traps or {}
    
    self.repels = level.repels or {}
    
    self.suctions = level.suctions or {}
    
    self.stickies = level.stickies or {}
    
    self.icies = level.icies or {}
    
    self.gravSwitches = level.gravswitches or {}
    
    -- Scale (no longer used with new export system)
    if not level.scaled then
        self:scaleLevel(level)
    end
    
    
    self.helpTxt = level.helptxt
    
    self.maxLines = level.maxLines or 3
    
    local ps = vec2(wScale(143), hScale(50))
    local ppos
    if level.pause ~= nil then ppos = vec2(wScale(level.pause.x), hScale(level.pause.y)) else ppos = vec2(ps.x/2, ps.y/2) end
    self.pauseButton = Button(self.images.pause, ppos.x, ppos.y, function() self:pause() end, ps)
        
    self.pauseButtons = {}
    local size = vec2(wScale(300), wScale(100))
    self.pauseButtons[1] = Button(self.images.resume, WIDTH/2, HEIGHT/2 + size.y*2, function() self:resume() end, size)
    self.pauseButtons[2] = Button(self.images.restart, WIDTH/2, HEIGHT/2, function() self:reset() end, size)
    self.pauseButtons[3] = Button(self.images.exit, WIDTH/2, HEIGHT/2 -size.y*2, function() self:resume() SManager:change(self.prevScene) end, size)
    
    self.prevScene = level.prevscene
    
    self:createObjectImage()
end

function Game:scaleLevel(level)
    for i, wall in ipairs(self.gameWalls) do
        if not wall.scaled then
            wall.pos1 = vec2(wScale(wall.pos1.x), hScale(wall.pos1.y))
            wall.pos2 = vec2(wScale(wall.pos2.x), hScale(wall.pos2.y))
            wall.scaled = true
        end
    end
    
    for i, player in ipairs(self.players) do
        if not player.scaled then
            player.startPos = vec2(wScale(player.startPos.x), hScale(player.startPos.y))
            player.scaled = true
        end
    end
    
    self.goal = vec2(wScale(level.goal.x), hScale(level.goal.y))

    for i, hint in ipairs(self.hints) do
        hint.x = wScale(hint.x)
        hint.y = hScale(hint.y)
    end
        
    for i, zone in ipairs(self.blockedZones) do
        if not zone.scaled then
            zone.x1 = wScale(zone.x1)
            zone.x2 = wScale(zone.x2)
            zone.y1 = hScale(zone.y1)
            zone.y2 = hScale(zone.y2)
            zone.scaled = true
        end
    end
        
    for i, lock in ipairs(self.origLocks) do
        if not lock.scaled then
            lock.lock = vec2(wScale(lock.lock.x), hScale(lock.lock.y))
            lock.key = vec2(wScale(lock.key.x), hScale(lock.key.y))
            lock.scaled = true
        end
    end
        
    for i, zone in ipairs(self.traps) do
        if not zone.scaled then
            zone.x1 = wScale(zone.x1)
            zone.x2 = wScale(zone.x2)
            zone.y1 = hScale(zone.y1)
            zone.y2 = hScale(zone.y2)
            zone.scaled = true
        end
    end
    
    for i, repel in ipairs(self.repels) do
        if not repel.scaled then
            repel.pos = vec2(wScale(repel.pos.x), hScale(repel.pos.y))
            repel.scaled = true
        end
    end
    
    for i, suction in ipairs(self.suctions) do
        if not suction.scaled then
            suction.pos = vec2(wScale(suction.pos.x), hScale(suction.pos.y))
            suction.scaled = true
        end
    end
    
    for i, zone in ipairs(self.stickies) do
        if not zone.scaled then
            zone.x1 = wScale(zone.x1)
            zone.x2 = wScale(zone.x2)
            zone.y1 = hScale(zone.y1)
            zone.y2 = hScale(zone.y2)
            zone.scaled = true
        end
    end
    
    for i, zone in ipairs(self.icies) do
        if not zone.scaled then
            zone.x1 = wScale(zone.x1)
            zone.x2 = wScale(zone.x2)
            zone.y1 = hScale(zone.y1)
            zone.y2 = hScale(zone.y2)
            zone.scaled = true
        end
    end
    
    for i, switch in ipairs(self.gravSwitches) do
        if not switch.scaled then
            switch.pos = vec2(wScale(switch.pos.x), hScale(switch.pos.y))
            switch.scaled = true
        end
    end
    
    local patrollers = level.patrols or {}
    for i, stuff in ipairs(patrollers) do
        if not stuff.scaled then
            stuff.pos1 = vec2(wScale(stuff.pos1.x), hScale(stuff.pos1.y))
            stuff.pos2 = vec2(wScale(stuff.pos2.x), hScale(stuff.pos2.y))
            stuff.scaled = true
        end
    
        self.patrollers[i] = { pos = stuff.pos1, angle = 0 }
    end
end

function Game:createObjectImage()
    self.objectImage = image(WIDTH, HEIGHT)
    setContext(self.objectImage)
    pushStyle()

    -- BlockedZones
    for i, blockedZone in ipairs(self.blockedZones) do
        local width = blockedZone.x2 - blockedZone.x1
        local height = blockedZone.y2 - blockedZone.y1
        strokeWidth(2)
        fill(145, 145, 145, 225) rectMode(CORNERS)
        rect(blockedZone.x1 - 1, blockedZone.y1 - 1, blockedZone.x2 + 2, blockedZone.y2 + 2)
        stroke(0, 0, 0, 255)
        local wScale = width / height
        local h = height / 20
        local w = h * wScale
        local numStripes = width / w
        for stripe = 1, numStripes do
            local x1, y1, x2, y2
            x1 = blockedZone.x1 + (w * (stripe - 1))
            y2 = blockedZone.y2 - (h * (stripe - 1))
            x2 = x1 + w
            y1 = y2 - h
                
            line(blockedZone.x1, y1, x2, blockedZone.y2)
            line(x1, blockedZone.y1, blockedZone.x2, y2)
        end
        stroke(0, 0, 0, 255)  strokeWidth(4) noFill()
        rect(blockedZone.x1 - 2, blockedZone.y1 - 2, blockedZone.x2 + 4, blockedZone.y2 + 4)
    end

    spriteMode(CORNERS)
        
    -- sticky zones
    for id, sticky in ipairs(self.stickies) do
        sprite(self.images.sticky, sticky.x1, sticky.y1, sticky.x2, sticky.y2)
    end
        
    -- icy zones
    for id, icy in ipairs(self.icies) do
        sprite(self.images.icy, icy.x1, icy.y1, icy.x2, icy.y2)
    end
    
    spriteMode(CENTER)
    
    -- repels
    for id, repel in ipairs(self.repels) do
        sprite(self.images.repel, repel.pos.x, repel.pos.y, self.repelSize, self.repelSize)
    end
        
    -- suctions
    for id, suction in ipairs(self.suctions) do
        sprite(self.images.suction, suction.pos.x, suction.pos.y, self.suctionSize, self.suctionSize)
    end
    
    spriteMode(CORNERS)
    
    -- traps
    for id, trap in ipairs(self.traps) do
        sprite(self.images.trap, trap.x1, trap.y1, trap.x2, trap.y2)
    end
    
    -- hints
    for id, hint in ipairs(self.hints) do
        stroke(0, 0, 0, 255) strokeWidth(hScale(7))
        line(hint.x - self.hintSize/2, hint.y - self.hintSize/2, hint.x + self.hintSize/2, hint.y + self.hintSize/2)
        line(hint.x - self.hintSize/2, hint.y + self.hintSize/2, hint.x + self.hintSize/2, hint.y - self.hintSize/2)
    end
    
    popStyle()
    setContext()
end

function Game:createGameWalls()
    for i, wall in ipairs(self.gameWalls) do
        table.insert(self.walls, physics.body(EDGE, wall.pos1, wall.pos2))
        
        wall.cline = GlowLine(wall.pos1, wall.pos2, 3)
        wall.cline.m.shader.color = vec4(0,0,0,2)
    end
    

    table.insert(self.walls, physics.body(EDGE, vec2(0, 0), vec2(WIDTH, 0)))
    table.insert(self.walls, physics.body(EDGE, vec2(WIDTH, 0), vec2(WIDTH, HEIGHT)))
    table.insert(self.walls, physics.body(EDGE, vec2(WIDTH, HEIGHT), vec2(0, HEIGHT)))
    table.insert(self.walls, physics.body(EDGE, vec2(0, HEIGHT), vec2(0, 0)))
end

function Game:createLocks()
    self.locks = {}
    
    for id, lock in ipairs(self.origLocks) do
        local pLock = { lock = lock.lock, key = lock.key }
        pLock.col = self.goalColors.inactive
        
        local x1, y1 = pLock.lock.x - self.lockSize/2, pLock.lock.y - self.lockSize/2
        local x2, y2 = pLock.lock.x + self.lockSize/2, pLock.lock.y - self.lockSize/2
        local x3, y3 = pLock.lock.x + self.lockSize/2, pLock.lock.y + self.lockSize/2
        local x4, y4 = pLock.lock.x - self.lockSize/2, pLock.lock.y + self.lockSize/2
        
        pLock.body = {}
        pLock.body[1] = physics.body(EDGE, vec2(x1, y1), vec2(x2, y2))
        pLock.body[2] = physics.body(EDGE, vec2(x2, y2), vec2(x3, y3))
        pLock.body[3] = physics.body(EDGE, vec2(x3, y3), vec2(x4, y4))
        pLock.body[4] = physics.body(EDGE, vec2(x4, y4), vec2(x1, y1))
        
        pLock.unlocked = false
        
        pLock.keyMeshId = self.meshes.keys:addRect(pLock.key.x, pLock.key.y, self.goalSize, self.goalSize*1.5)
        
        table.insert(self.locks, pLock)
    end
end

function Game:onEnter()
    -- music.muted = true
    
    -- self.sounds.start()
    
    self:reset()
    
    -- tween.delay(2, function() self:startChallenge() physics.resume() self:playGameMusic() end)
    
    self:startChallenge()
    self:showHelp()
    self:playGameMusic()
    
    self.loaded = true
end

function Game:showHelp()
    if self.helpTxt ~= nil then
        self.showingHelp = true
        physics.pause()
    end
end

function Game:startChallenge()
    if self.mode == "Challenge" then
        self.challengeTimer = tween.delay(25, function() self:loseChallenge() end)
    end
end

function Game:loseChallenge()
    self.sounds.lost()
    
    SManager:change(self.prevScene)
end

function Game:reset()
    physics.gravity(vec2(physics.gravity().x, -math.abs(physics.gravity().y)))
    physics.continuous = true
    
    self.usedTouches = {}
    
    self:clearMeshes()
    self:destroyBodies()
    
    self:resume()
    
    self.goalColor = self.goalColors.inactive
    
    self:createGameWalls()
    self:createLocks()
    
    for id, player in ipairs(self.players) do
        player.box = physics.body(POLYGON, vec2(-self.size/2, -self.size/2), vec2(-self.size/2, self.size/2),
                            vec2(self.size/2, self.size/2), vec2(self.size/2, -self.size/2))
                            
        player.box.position = player.startPos
        player.box.type = DYNAMIC
        player.box.restitution = 0
        player.boxLines = GlowSquare(player.box, hScale(4))
        player.color = themeColors[selectedTheme].box or color(0, 100, 255, 190)
        
        player.chains = { }
        
        player.goalStatus = "inactive"
        
        if player.unlocks ~= nil then
            for i, t in pairs(player.unlocks) do
                tween.reset(t)
            end
        else
            player.unlocks = { }
        end
        
        player.switchTimes = { }
    end
    
    if self.challengeTimer ~= nil then
        tween.reset(self.challengeTimer)
        tween.play(self.challengeTimer)
    end
    self:showHelp()

    collectgarbage()
end

function Game:clearMeshes()
    for id, m in pairs(self.meshes) do
        if not m.noclear then
            m:clear()
        end
    end
end

function Game:onExit()
    self.loaded = false
    
    self:destroyBodies()
    
    physics.gravity(vec2(physics.gravity().x, -math.abs(physics.gravity().y)))
    
    music.volume = 1.0
end

function Game:win()
    self.sounds.win()
    
    if self.comId ~= nil then
        if completedLevels[self.comId] == nil then
            completedLevels[self.comId] = {}
        end
        
        completedLevels[self.comId][self.mode] = true
        
        saveLocalData("CompletedLevels", tableToString("completedLevels", completedLevels))
    end
    
    if self.challengeTimer ~= nil then
        tween.reset(self.challengeTimer)
        tween.stop(self.challengeTimer)
        self.challengeTimer = nil
    end
    
    SManager:change(self.prevScene)
end

function Game:destroyBodies()
    for i, player in ipairs(self.players) do
        if player.box ~= nil then
            player.box:destroy()
        end
        
        if player.chains ~= nil then
            for i, chain in ipairs(player.chains) do
                table.remove(player.chains, i)
            end
        end
    end
    
    for i, wall in ipairs(self.walls) do
        wall:destroy()
        table.remove(self.walls, i)
    end
    
    for i, lock in ipairs(self.locks) do
        for bi, body in ipairs(lock.body) do
            body:destroy()
        end
        table.remove(self.locks, i)
    end
    
    debugDraw:clear()
    
    collectgarbage()
end

function Game:checkOnLocks()
    for id, player in ipairs(self.players) do
        for lid, lock in ipairs(self.locks) do
            if player.unlocks[lid] == nil then
                player.unlocks[lid] = { status = "inactive" }
            end
            
            if lock.key.x + self.goalSize/2 < player.box.position.x + self.size/2 
            and lock.key.x - self.goalSize/2 > player.box.position.x - self.size/2
            and lock.key.y + self.goalSize/2 < player.box.position.y + self.size/2
            and lock.key.y - self.goalSize/2 > player.box.position.y - self.size/2 then
                local allEnded = true
                for i, chain in ipairs(player.chains) do
                    if chain.state ~= ENDED then 
                        allEnded = false
                    end
                end
                
    
                if allEnded then
                    self:startUnlocking(lid, id)
                else
                    self:hoveringLock(lid, id)
                end
            else
                self:reLock(lid, id)
            end
        end
    end
end

function Game:startUnlocking(lid, id)    
    if self.players[id].unlocks[lid].timer == nil then
        self.players[id].unlocks[lid].timer = tween.delay(self.winTime, function() self:unlock(lid) end)
        self.locks[lid].timer = self.players[id].unlocks[lid].timer
    end
    
    self.players[id].unlocks[lid].status = "active"
        
    self.locks[lid].col = self.goalColors.active
end

function Game:hoveringLock(lid, id)
    self.players[id].unlocks[lid].status = "hovering"
        
    local dont = false
    for i, player in ipairs(self.players) do
        if player.unlocks[lid] == nil or player.unlocks[lid].status == nil then
            break
        end
        
        if player.unlocks[lid].status == "active" then
            dont = true
        end
    end
    if not dont then
        self.locks[lid].col = self.goalColors.hovering
    end
    
    if self.players[id].unlocks[lid].timer ~= nil then
        tween.stop(self.players[id].unlocks[lid].timer)
        self.players[id].unlocks[lid].timer = nil
        self.locks[lid].timer = nil
    end
end

function Game:reLock(lid, id)     
    self.players[id].unlocks[lid].status = "inactive"
        
    local dont = false
    for i, player in ipairs(self.players) do
        if player.unlocks[lid] == nil or player.unlocks[lid].status == nil then
            break
        end
        
        if player.unlocks[lid].status ~= "inactive" then
            dont = true
        end
    end
    if not dont then
        self.locks[lid].col = self.goalColors.inactive
    end
    
    if self.players[id].unlocks[lid].timer ~= nil then
        tween.stop(self.players[id].unlocks[lid].timer)
        self.players[id].unlocks[lid].timer = nil
        self.locks[lid].timer = nil
    end
end

function Game:unlock(lid)
    if self.locks[lid] ~= nil then
        self.sounds.key()
        
        if self.locks[lid].body ~= nil then
            for bi, body in ipairs(self.locks[lid].body) do
                debugDraw:removeBody(body)
                
                body:destroy()
            end
        end
        
        self.locks[lid].unlocked = true
        
        self.meshes.keys:setRect(self.locks[lid].keyMeshId, 0,0,0,0)
    end
end

function Game:checkOnGoal()
    for id, player in ipairs(self.players) do
        if self.goal.x + self.goalSize/2 < player.box.position.x + self.size/2 
        and self.goal.x - self.goalSize/2 > player.box.position.x - self.size/2
        and self.goal.y + self.goalSize/2 < player.box.position.y + self.size/2
        and self.goal.y - self.goalSize/2 > player.box.position.y - self.size/2 then
            local allEnded = true
            for i, chain in ipairs(player.chains) do
                if chain.state ~= ENDED and chain.state ~= CANCELLED then 
                    allEnded = false
                end
            end
            
            if allEnded then
                self:activateGoal(id)
            else
                self:hoveringGoal(id)
            end
        else
            self:deactivateGoal(id)
        end
    end
end

function Game:activateGoal(id)
    self.players[id].goalStatus = "active"
    
    self.goalColor = self.goalColors.active
    
    if self.players[id].winTimer == nil then
        self.players[id].winTimer = tween.delay(self.winTime, function() self:win() end)
    end
end

function Game:hoveringGoal(id)
    self.players[id].goalStatus = "hovering"
    
    local dont = false
    for i, player in ipairs(self.players) do
        if player.goalStatus == "active" then
            dont = true
        end
    end
    if not dont then
        self.goalColor = self.goalColors.hovering
    end
    
    if self.players[id].winTimer ~= nil then
        tween.stop(self.players[id].winTimer)
        self.players[id].winTimer = nil
    end
end

function Game:deactivateGoal(id)
    self.players[id].goalStatus = "inactive"
    
    local dont = false
    for i, player in ipairs(self.players) do
        if player.goalStatus == "active" then
            dont = true
        end
    end
    if not dont then
        self.goalColor = self.goalColors.inactive
    end
    
    if self.players[id].winTimer ~= nil then
        tween.stop(self.players[id].winTimer)
        self.players[id].winTimer = nil
    end
end

function Game:patrollersAct()
    for id, stuff in ipairs(self.patrollers) do
        stuff.angle = stuff.angle + 1
        self.meshes.patrollers:setRect(stuff.meshId, stuff.pos.x, stuff.pos.y, self.patrolSize, self.patrolSize, stuff.angle)
        
        for pid, player in ipairs(self.players) do
            for cid, chain in ipairs(player.chains) do
                if chain.state == ENDED then
                    local check = intersectsCircle(stuff.pos, self.patrolSize/2, vec2(chain.x, chain.y), player.box.position) 
                    if check then
                        self.sounds.patroller()
                        table.remove(player.chains, cid)
                    end
                end
            end
        end
    end
end

function Game:blockZones()
    for pid, player in ipairs(self.players) do
        for cid, chain in ipairs(player.chains) do
            -- Can't lock chain in blocked zone
            for i, blockedZone in ipairs(self.blockedZones) do
                if chain.x > blockedZone.x1 and chain.x < blockedZone.x2
                and chain.y > blockedZone.y1 and chain.y < blockedZone.y2
                and chain.state == ENDED then
                    self.sounds.blocked()
                    table.remove(player.chains, cid)
                end
            end
        end
    end
end

function Game:checkTraps()
    for pid, player in ipairs(self.players) do
        for i, trap in ipairs(self.traps) do
            if player.box.position.x + self.size/2 > trap.x1 and player.box.position.x - self.size/2 < trap.x2
            and player.box.position.y + self.size/2 > trap.y1 and player.box.position.y- self.size/2 < trap.y2 then
                self.sounds.trap()
                local ctime
                if self.challengeTimer ~= nil then
                    ctime = self.challengeTimer.running
                end
                self:reset()
                if self.challengeTimer ~= nil then
                    self.challengeTimer.running = ctime
                end
            end
        end
    end
end

function Game:checkSwitches()
    for id, player in ipairs(self.players) do
        for sid, switch in ipairs(self.gravSwitches) do
            if switch.pos.x + self.switchSize/2 < player.box.position.x + self.size/2 
            and switch.pos.x - self.switchSize/2 > player.box.position.x - self.size/2
            and switch.pos.y + self.switchSize/2 < player.box.position.y + self.size/2
            and switch.pos.y - self.switchSize/2 > player.box.position.y - self.size/2 then
                if player.switchTimes[sid] == nil or ElapsedTime - player.switchTimes[sid] > 1 then
                    self:flipGravity()
                
                    player.switchTimes[sid] = ElapsedTime
                end
            end
        end
    end
end

function Game:flipGravity()
    self.sounds.gravityFlip()
    
    local grav = physics.gravity() 
    physics.gravity(grav.x, -grav.y)
    
    for id, player in ipairs(self.players) do
        player.box:applyForce(vec2(0, -grav.y))
    end
end

function Game:repelPlayers()
    local s = (self.repelSize / 2) + (self.size / 2)
    for id, player in ipairs(self.players) do
        for rid, repel in ipairs(self.repels) do
            if repel.pos:dist(player.box.position) <= s then
                local d = player.box.position - repel.pos
                d = d:normalize()
                
                local f = vec2(self.repelForce * d.x, self.repelForce * d.y)
                
                player.box:applyForce(f)
            end
        end
    end
end

function Game:attractPlayers()
    local s = (self.suctionSize / 2) + (self.size / 2)
    for id, player in ipairs(self.players) do
        for sid, suction in ipairs(self.suctions) do
            if suction.pos:dist(player.box.position) <= s then
                local d = suction.pos - player.box.position
                if d:len() > 10 then
                    d = d:normalize() * self.suctionForce
                end
                
                player.box:applyForce(d)
            end
        end
    end
end

function Game:stickyZones()
    for pid, player in ipairs(self.players) do
        for i, zone in ipairs(self.stickies) do
            if player.box.position.x + self.size/2 > zone.x1 and player.box.position.x - self.size/2 < zone.x2
            and player.box.position.y + self.size/2 > zone.y1 and player.box.position.y - self.size/2 < zone.y2 then
                player.box.linearVelocity = vec2(player.box.linearVelocity.x * 0.9, player.box.linearVelocity.y * 0.9)
            end
        end
    end
end

function Game:icyZones()
    for pid, player in ipairs(self.players) do
        for i, zone in ipairs(self.icies) do
            if player.box.position.x + self.size/2 > zone.x1 and player.box.position.x - self.size/2 < zone.x2
            and player.box.position.y + self.size/2 > zone.y1 and player.box.position.y - self.size/2 < zone.y2 then
                player.box.linearVelocity = vec2(player.box.linearVelocity.x * 1.03, player.box.linearVelocity.y * 1.03)
            end
        end
    end
end

function Game:drawHud()
    fill(0, 0, 0, 226) fontSize(wScale(25))
    
    local activeTxt = "Goal is not active."
    
    for pi, player in ipairs(self.players) do
        local activeChains = 0
        for i, chain in ipairs(player.chains) do
            if chain.state == ENDED or chain.state == CANCELLED then
                activeChains = activeChains + 1
            end
        end
        
        local chainTxt = "Active Chains: " .. activeChains .. " / " .. self.maxLines
        local cw, ch = textSize(chainTxt)
        text(chainTxt, cw/2, HEIGHT + (ch/2) - (ch * pi))
        
        if player.goalStatus == "active" then
            activeTxt = math.ceil(player.winTimer.time - player.winTimer.running) .. " seconds until winning."
        end
    end
    
    local aw, ah = textSize(activeTxt)
    text(activeTxt, WIDTH - aw/2, HEIGHT - ah/2)
    
    local cw, ch = textSize("Active Chains: 20 / 20")
    for id, lock in ipairs(self.locks) do
        local x, y, limg = cw + (ch * id), HEIGHT - ch/2
        if lock.unlocked then
            limg = self.images.key.unlocked
        else
            limg = self.images.key.locked
        end
        
        sprite(limg, x, y, ch, ch)
    end
    
    if self.mode == "Challenge" and self.challengeTimer ~= nil then
        fontSize(wScale(150)) smooth()
        local timeLeft = math.ceil(self.challengeTimer.time - self.challengeTimer.running)
        text(timeLeft, WIDTH/2, HEIGHT/2)
        noSmooth()
    end
    
    -- Show help if it exists
    if self.showingHelp then
        fill(backCol.r, backCol.g, backCol.b, 170) stroke(backCol) strokeWidth(2) rectMode(CORNER)
        rect(0, 0, WIDTH, HEIGHT)
        fill(topCol) fontSize(wScale(30)) textWrapWidth(WIDTH - wScale(5)) textAlign(CENTER) textMode(CENTER)
        text(self.helpTxt .. "\n\n(Tap To Dismiss)", WIDTH/2, HEIGHT/2)
    end
end

function Game:pause()
    self.paused = true
    physics.pause()
    tween.pauseAll()
end

function Game:resume()
    self.paused = false
    physics.resume()
    tween.resumeAll()
end

function Game:draw()
    if self.loaded and not self.paused then
        noSmooth()
        
        -- Draw background
        sprite(self.images.back, WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
        
        -- Draw unchanging objects
        sprite(self.objectImage, WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
        
        -- Draw player box
        for id, player in ipairs(self.players) do
            fill(player.color) rectMode(CENTER) strokeWidth(0)
            pushMatrix() translate(player.box.position.x, player.box.position.y)
            rotate(player.box.angle)
            rect(0, 0, self.size, self.size)
            popMatrix()
            
            player.boxLines:setPositions(player.box)
            player.boxLines:draw()
            
            -- Draw chains
            for cid, chain in pairs(player.chains) do
                local dist = vec2(chain.x, chain.y):dist(player.box.position)
                player.box:applyForce((vec2(chain.x, chain.y)-player.box.position)*(dist/250)-player.box.linearVelocity/10)
                chain.cline:setPositions(player.box.position,vec2(chain.x, chain.y))
                chain.cline:draw()
                
                fill(player.color) stroke(fill())
                ellipse(chain.x, chain.y, wScale(25))
            end
        end
        
        -- Draw goal
        tint(self.goalColor) noStroke()
        sprite(self.images.goal, self.goal.x, self.goal.y, self.goalSize)
        noTint()
        
        -- Draw walls
        for id, wall in ipairs(self.gameWalls) do
            wall.cline:draw()
        end
        
        -- Draw meshes
        for id, m in pairs(self.meshes) do
            m:draw()
        end
        
        -- Draw gravity switches
        for id, switch in ipairs(self.gravSwitches) do
            local w,h = self.switchSize, self.switchSize
            if physics.gravity().y > 0 then
                w,h = -w, -h
            end
            sprite(self.images.switch, switch.pos.x, switch.pos.y, w, h)
        end
        
        -- Draw locks
        for id, lock in ipairs(self.locks) do
            if not lock.unlocked then
                tint(lock.col)
                sprite(self.images.lock, lock.lock.x, lock.lock.y, self.lockSize, self.lockSize)
                noTint()
            
                fill(255, 0, 0, 255)
                if lock.timer then
                    fontSize(self.size)
                    text(math.ceil(lock.timer.time - lock.timer.running), lock.lock.x, lock.lock.y)
                end
            end
        end
        
        -- Draw hud
        self:drawHud()
        
        self:checkOnGoal()
        self:checkOnLocks()
        self:checkTraps()
        self:checkSwitches()
        self:blockZones()
        self:repelPlayers()
        self:attractPlayers()
        self:stickyZones()
        self:icyZones()
        self:patrollersAct()
        
        
        self.pauseButton:draw()
    else
        for i, btn in ipairs(self.pauseButtons) do
            btn:draw()
        end
    end
end

function Game:collide(contact)
    for id, player in ipairs(self.players) do
        if contact.bodyA == player.box or contact.bodyB == player.box then
            if math.abs(player.box.linearVelocity.x) > 2 or math.abs(player.box.linearVelocity.y) > 2 then
                -- self.sounds.collide()
            end
        end
    end
end

function Game:touchTaken(t)
    for _, touch in ipairs(self.usedTouches) do
        if touch.id == t.id then
            return true
        end
    end
    
    return false
end

function Game:touched(touch)
    if not self.paused then
        if self.showingHelp then
            if touch.state == ENDED then
                self.showingHelp = false
                physics.resume()
            end
            
            return
        end
        
        local allEnded = true
        for id, player in ipairs(self.players) do
            if touch.state == BEGAN and player.box:testPoint(vec2(touch.x, touch.y)) and not self:touchTaken(touch) then
                if #player.chains < self.maxLines then
                    table.insert(player.chains, { x = touch.x, y = touch.y, state = touch.state, id = touch.id,
                                            cline = GlowLine(player.box.position, vec2(touch.x, touch.y),3) })
                    -- player.chains[#player.chains].cline.m.shader.color = vec4(0, 1.5, 2, 2)
                else
                    self.sounds.blocked()
                end
            end
            
            for cid, chain in ipairs(player.chains) do
                if vec2(chain.x, chain.y):dist(vec2(touch.x, touch.y)) < wScale(30) and not self:touchTaken(touch) then
                    chain.id = touch.id
                    table.insert(self.usedTouches, touch)
                end
                
                if touch.id == chain.id then
                    if (chain.state ~= ENDED and touch.state == ENDED) or (chain.state ~= CANCELLED and touch.state == CANCELLED) then
                        self.sounds.locked()
                    end
                    
                    if chain.state ~= ENDED and chain.state ~= CANCELLED then
                        allEnded = false
                    end
                    
                    chain.x, chain.y, chain.state = touch.x, touch.y, touch.state
                end
            end
        end
        
        if allEnded then
            self.pauseButton:touched(touch)
            
            return false
        else
            return true
        end
    else
        for i, btn in ipairs(self.pauseButtons) do
            btn:touched(touch)
        end
        
        return false
    end
end


