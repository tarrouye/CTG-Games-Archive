LevelEditor = class()

function LevelEditor:init(x)
    self.music = "Dropbox:Cut and Run"
    
    self.toolSize = hScale(100)
    self.lockSize = hScale(150)
    self.keySize = vec2(hScale(50), hScale(75))
    self.goalSize = hScale(50)
    self.patrolSize = hScale(35)
    self.switchSize = hScale(40)
    self.hintSize = hScale(50)
    self.repelSize = hScale(200)
    self.suctionSize = hScale(200)
    
    
    self.holding = nil
    self.testing = false
    
    self.buttons = {}
    
    local size = vec2(wScale(141), hScale(50))
    local img = readImage("Dropbox:FLTools")
    self.buttons[1] = Button(img, size.x/2, size.y/2, function() self:toggleToolsDrawer() end, size)
    
    local img = readImage("Dropbox:FLPlay")
    self.buttons[2] = Button(img, size.x*1.5, size.y/2, function() self:testLevel() end, size)

    local img = readImage("Dropbox:FLExport")
    self.buttons[3] = Button(img, size.x*2.5, size.y/2, function() self:saveLevel() end, size)
        
    local img = readImage("Dropbox:FLBack")
    self.buttons[4] = Button(img, size.x*3.5, size.y/2, function() SManager:change("Start") end, size)
    
    local img = readImage("Cargo Bot:Claw Right")
    self.buttons[5] = Button(img, size.x*4 + size.y, size.y/2, function() self:toggleShowingButtons() end, vec2(size.y, size.y))
    
    self.btnPos = { showing = 0, hiding = -size.x*4 }
    self.btnTranslate = self.btnPos.showing
        
    local img = readImage("Dropbox:FLStop")
    self.stopBtn = Button(img, WIDTH - size.x/2, size.y/2, function() self:endTesting() end, size)
    
    self.images = {
        back = readImage("Cargo Bot:Game Area"),
        toolbox = readImage("Dropbox:FLToolbox"),
        key = readImage("Planet Cute:Key"),
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
        
    }

    self.showingTools = true
    self:setupTools()   
    self:createGrid()
end

function LevelEditor:toggleShowingButtons()
    local dist
    if self.btnTranslate == self.btnPos.showing then
        self.btnTranslate = self.btnPos.hiding
        dist = self.btnPos.hiding
    else
        self.btnTranslate = self.btnPos.showing
        dist = -self.btnPos.hiding
    end
    
    for i, btn in ipairs(self.buttons) do
        tween(0.2, btn, { x = btn.x + dist }, tween.easing.linear)
    end
end

function LevelEditor:createGrid()
    self.images.grid = image(WIDTH, HEIGHT)
    setContext(self.images.grid)
    pushStyle()
    
    local space = wScale(20)
    
    stroke(127, 127, 127, 255) strokeWidth(2)
    for y = 1, HEIGHT, space do
        line(0, y, WIDTH, y)
    end
    for x = 1, WIDTH, space do
        line(x, 0, x, HEIGHT)
    end
    
    popStyle()
    setContext()
end

function LevelEditor:openLevel(level)
    self.objects.players = level.players or {}
    for i, stuff in ipairs(self.objects.players) do
        local x1, x2, y1, y2 = stuff.startPos.x - self.toolSize/2, stuff.startPos.x + self.toolSize/2, stuff.startPos.y - self.toolSize/2, stuff.startPos.y + self.toolSize/2
        stuff.glow = {
            GlowLine(vec2(x1, y1), vec2(x2, y1),3),
            GlowLine(vec2(x2, y1), vec2(x2, y2),3),
            GlowLine(vec2(x2, y2), vec2(x1, y2),3),
            GlowLine(vec2(x1, y2), vec2(x1, y1),3)
        }
    end
    
    self.objects.positionObjects = {}
    
    if level.goal then
        table.insert(self.objects.positionObjects, { id = "goal", pos = level.goal, size = self.tools[2].size })
    end
    if level.pause then
        table.insert(self.objects.positionObjects, { id = "pause", pos = level.pause, size = self.tools[14].size })
    end
    
    self.objects.blockedZones = level.blocked or {}
    self.objects.patrollers = level.patrols or {}
    self.objects.hints = level.hints or {}
    
    self.objects.walls = level.walls or {}
    for i, stuff in ipairs(self.objects.walls) do
        stuff.cline = GlowLine(stuff.pos1, stuff.pos2, 3)
        stuff.cline.m.shader.color = vec4(0,0,0,1)
    end
    
    self.objects.locks = level.locks or {}
    for i, stuff in ipairs(self.objects.locks) do
        stuff.keyMeshId = self.meshes.keys:addRect(stuff.key.x, stuff.key.y, self.keySize.x, self.keySize.y)
    end
    
    self.objects.traps = level.traps or {}
    self.objects.gravSwitches = level.gravswitches or {}
    self.objects.repels = level.repels or {}
    self.objects.suctions = level.suctions or {}
    self.objects.stickies = level.stickies or {}
    self.objects.icies = level.icies or {}

    local maxLines = level.maxLines or 1
    self.maxLinesSlider = IntegerSlider("lvlmxlines", 1, 20, maxLines, WIDTH/1.3, hScale(160), function() end, false, "Maximum Chains Allowed")
    self.maxLinesSlider.length = WIDTH/2 - wScale(180)
    self.maxLinesSlider:moveSlider()
    
    self.difficultySlider = TableSlider("lvldifficulty", {"Tutorial", "Easy", "Medium", "Hard"}, 1, WIDTH/1.3, hScale(100),
        function() end, false, "Difficulty")
    self.difficultySlider.length = WIDTH/2 - wScale(180)
    self.difficultySlider:moveSlider()
end

function LevelEditor:onEnter()
    self:endTesting()
    
    music(self.music, true)
    
    self.erasing = false
    self.showingGrid = false
    
    self.colours.player = themeColors[selectedTheme].box
    for i, p in ipairs(self.objects.players) do
        for o, g in ipairs(p.glow) do
            g.m.shader.color = themeColors[selectedTheme].glow
        end
    end
end

function LevelEditor:testLevel()
    local level = loadstring("return " .. self:packToString())()
    level.prevscene = "Edit"
    level.mode = "Standard"

    self.testGame = Game()
    self.testGame:loadLevel(level)
                    
    self.testGame:onEnter()
    
    self.testing = true
end

function LevelEditor:endTesting()
    self.testing = false
    
    music(self.music, true)
    
    if self.testGame ~= nil then
        self.testGame = nil
    end
end

function LevelEditor:toggleToolsDrawer()
    self.showingTools = not self.showingTools
end

function LevelEditor:showToolsDrawer()
    self.showingTools = true
end

function LevelEditor:hideToolsDrawer()
    self.showingTools = false
end

function LevelEditor:setupTools()
    self.tools = {
        { name = "Player Start", type = "players", total = 5, used = 0 },
        
        { name = "Goal", id = "goal", type = "positionObjects", size = vec2(wScale(50), wScale(50)), total = 1, used = 0 },
        
        { name = "Blocked Zone", type = "blockedZones", used = 0 },
        
        { name = "Patrol", type = "patrollers", used = 0 },
        
        { name = "Hint Marker", type = "hints", used = 0 },
        
        { name = "Wall", type = "walls", used = 0 },
        
        { name = "Lock and Key", type = "locks", used = 0 },
        
        { name = "Trap", type = "traps", used = 0 },
        
        { name = "Gravity Switch", type = "gravSwitches", used = 0 },
    
        { name = "Repel", type = "repels", used = 0 },
    
        { name = "Suction", type = "suctions", used = 0 },
        
        { name = "Sticky Zone", type = "stickies", used = 0 },
        
        { name = "Icy Zone", type = "icies", used = 0 },
        
        { name = "Pause Button", id = "pause", type = "positionObjects", size = vec2(wScale(143), hScale(50)), total = 1, used = 0 },
        
        { name = "Toggle Eraser", type = "eraser", used = 0 },
        
        { name = "Toggle Grid", type = "grid", used = 0 },
        
        { name = "Undo Erase", type = "undo", used = 0 }
    }
    
    self.colours = { player = themeColors[selectedTheme].box, goal = color(255, 0, 0, 255), 
        pause = color(164, 255, 0, 255),
        blockedZones = color(147,180), patrollers = color(0, 154, 255, 255), hints = color(0, 0, 0, 255),
        walls = color(0, 0, 0, 255), locks = color(0, 255, 109, 255), traps = color(0, 255, 109, 255) }
    
    self.meshes = { keys = mesh() }
    self.meshes.keys.texture = self.images.key
    
    self.maxLinesSlider = IntegerSlider("lvlmxlines", 1, 20, 1, WIDTH/1.3, hScale(160), function() end, false, "Maximum Chains Allowed")
    self.maxLinesSlider.length = WIDTH/2 - wScale(180)
    self.maxLinesSlider:moveSlider()
    
    self.difficultySlider = TableSlider("lvldifficulty", {"Tutorial", "Easy", "Medium", "Hard"}, 1, WIDTH/1.3, hScale(100),
        function() end, false, "Difficulty")
    self.difficultySlider.length = WIDTH/2 - wScale(180)
    self.difficultySlider:moveSlider()
    
    self.objects = {}
    self.objects['players'] = {}
    self.objects['positionObjects'] = {}
    self.objects['blockedZones'] = {}
    self.objects['patrollers'] = {}
    self.objects['hints'] = {}
    self.objects['walls'] = {}
    self.objects['locks'] = {}
    self.objects['traps'] = {}
    self.objects['gravSwitches'] = {}
    self.objects['repels'] = {}
    self.objects['suctions'] = {}
    self.objects['stickies'] = {}
    self.objects['icies'] = {}
    
    self.undos = {}
end

function LevelEditor:resetLevel()
    for i, m in pairs(self.meshes) do
        m:clear()
    end
    
    self.holding = nil

    self:setupTools()
    
    self.showingTools = true
end

function LevelEditor:packToString()
    local exportStr = "{ "
    
    exportStr = exportStr .. "  players = { "
    for id, stuff in ipairs(self.objects.players) do
        exportStr = exportStr .. "{ startPos = vec2(" .. owScale(stuff.startPos.x) .. ", " .. ohScale(stuff.startPos.y) .. ") }"
        
        if id ~= #self.objects.players then
            exportStr = exportStr .. ",\n            "
        end
    end
    exportStr = exportStr .. " },\n    "
    
    for id, stuff in ipairs(self.objects.positionObjects) do
        exportStr = exportStr .. stuff.id .. " = " .. "vec2(" .. owScale(stuff.pos.x) .. ", " .. ohScale(stuff.pos.y) .. ")"
        
        exportStr = exportStr .. ",\n   "
    end
    
    exportStr = exportStr .. "  hints = { "
    for id, stuff in ipairs(self.objects.hints) do
        exportStr = exportStr .. "vec2(" .. owScale(stuff.x) .. ", " .. ohScale(stuff.y) ..")"
        
        if id ~= #self.objects.hints then
            exportStr = exportStr .. ",\n           "
        end
    end
    exportStr = exportStr .. " }"
    
    exportStr = exportStr .. ",\n  blocked = { "
    for id, stuff in ipairs(self.objects.blockedZones) do
        exportStr = exportStr .. "{x1 = " .. owScale(stuff.x1) .. ", y1 = " .. ohScale(stuff.y1)
        exportStr = exportStr .. ", x2 = " .. owScale(stuff.x2) .. ", y2 = " .. ohScale(stuff.y2) .. "}"
        
        if id ~= #self.objects.blockedZones then
            exportStr = exportStr .. ",\n             "
        end
    end
    exportStr = exportStr .. " }"
    
    exportStr = exportStr .. ",\n  patrols = { "
    for id, stuff in ipairs(self.objects.patrollers) do
        exportStr = exportStr .. "{pos1 = vec2(" .. owScale(stuff.pos1.x) .. ", " .. ohScale(stuff.pos1.y) .. "), "
        exportStr = exportStr .. "pos2 = vec2(" .. owScale(stuff.pos2.x) .. ", " .. ohScale(stuff.pos2.y) .. ")}"
        
        if id ~= #self.objects.patrollers then
            exportStr = exportStr .. ",\n              "
        end
    end
    exportStr = exportStr .. " }"
    
    exportStr = exportStr .. ",\n  walls = { "
    for id, stuff in ipairs(self.objects.walls) do
        exportStr = exportStr .. "{pos1 = vec2(" .. owScale(stuff.pos1.x) .. ", " .. ohScale(stuff.pos1.y) .. "), "
        exportStr = exportStr .. "pos2 = vec2(" .. owScale(stuff.pos2.x) .. ", " .. ohScale(stuff.pos2.y) .. ")}"
        
        if id ~= #self.objects.walls then
            exportStr = exportStr .. ",\n            "
        end
    end
    exportStr = exportStr .. " }"
    
    exportStr = exportStr .. ",\n  locks = { "
    for id, stuff in ipairs(self.objects.locks) do
        exportStr = exportStr .. "{lock = vec2(" .. owScale(stuff.lock.x) .. ", " .. ohScale(stuff.lock.y) .. "), "
        exportStr = exportStr .. "key = vec2(" .. owScale(stuff.key.x) .. ", " .. ohScale(stuff.key.y) .. ")}"
        
        if id ~= #self.objects.locks then
            exportStr = exportStr .. ",\n            "
        end
    end
    exportStr = exportStr .. " }"
    
    exportStr = exportStr .. ",\n  traps = { "
    for id, stuff in ipairs(self.objects.traps) do
        exportStr = exportStr .. "{x1 = " .. owScale(stuff.x1) .. ", y1 = " .. ohScale(stuff.y1)
        exportStr = exportStr .. ", x2 = " .. owScale(stuff.x2) .. ", y2 = " .. ohScale(stuff.y2) .. "}"
        
        if id ~= #self.objects.traps then
            exportStr = exportStr .. ",\n          "
        end
    end
    exportStr = exportStr .. " }"
    
    exportStr = exportStr .. ",\n  gravswitches = { "
    for id, stuff in ipairs(self.objects.gravSwitches) do
        exportStr = exportStr .. "{pos = vec2(" .. owScale(stuff.pos.x) .. ", " .. ohScale(stuff.pos.y) .. ")}"
        
        if id ~= #self.objects.gravSwitches then
            exportStr = exportStr .. ",\n              "
        end
    end
    exportStr = exportStr .. " }"
    
    exportStr = exportStr .. ",\n  repels = { "
    for id, stuff in ipairs(self.objects.repels) do
        exportStr = exportStr .. "{pos = vec2(" .. owScale(stuff.pos.x) .. ", " .. ohScale(stuff.pos.y) .. ")}"
        
        if id ~= #self.objects.repels then
            exportStr = exportStr .. ",\n              "
        end
    end
    exportStr = exportStr .. " }"
    
    exportStr = exportStr .. ",\n  suctions = { "
    for id, stuff in ipairs(self.objects.suctions) do
        exportStr = exportStr .. "{pos = vec2(" .. owScale(stuff.pos.x) .. ", " .. ohScale(stuff.pos.y) .. ")}"
        
        if id ~= #self.objects.suctions then
            exportStr = exportStr .. ",\n              "
        end
    end
    exportStr = exportStr .. " }"
    
    exportStr = exportStr .. ",\n  stickies = { "
    for id, stuff in ipairs(self.objects.stickies) do
        exportStr = exportStr .. "{x1 = " .. owScale(stuff.x1) .. ", y1 = " .. ohScale(stuff.y1)
        exportStr = exportStr .. ", x2 = " .. owScale(stuff.x2) .. ", y2 = " .. ohScale(stuff.y2) .. "}"
        
        if id ~= #self.objects.stickies then
            exportStr = exportStr .. ",\n          "
        end
    end
    exportStr = exportStr .. " }"
    
    exportStr = exportStr .. ",\n  icies = { "
    for id, stuff in ipairs(self.objects.icies) do
        exportStr = exportStr .. "{x1 = " .. owScale(stuff.x1) .. ", y1 = " .. ohScale(stuff.y1)
        exportStr = exportStr .. ", x2 = " .. owScale(stuff.x2) .. ", y2 = " .. ohScale(stuff.y2) .. "}"
        
        if id ~= #self.objects.icies then
            exportStr = exportStr .. ",\n          "
        end
    end
    exportStr = exportStr .. " }"
    
    
    exportStr = exportStr .. ", maxLines = " .. tostring(self.maxLinesSlider.curVN)
    
    -- Add statement saying all levels exported using new method (owScale and ohScale) don't need to be rescaled
    exportStr = exportStr .. ", scaled = true"
    
    exportStr = exportStr .. " }"
    
    return exportStr
end

function LevelEditor:saveLevel()
    local exportStr = self:packToString()
    
    local alreadySaved = readLocalData("LevelData")
    local difficulty = self.difficultySlider.curVN
    local find = '{ name = "'..difficulty..'", levels = {(.-)}%s*},\n\n'
    
    local a, b = alreadySaved:find(find)
    local c, d = alreadySaved:sub(a + 1, b - 4):find("levels = {(.*)}")
    local pl, ed = d - 1 + a, d + a
    
    local before = alreadySaved:sub(1, pl)
    local after = alreadySaved:sub(ed-1, alreadySaved:len())
    
    local newLevelData = before .. "\n" .. exportStr .. ",\n" .. after
    
    saveLocalData("LevelData", newLevelData)
    
    -- Load new levels into Level Manager
    loadstring(newLevelData)()
    -- SManager.scenes['Levels']:loadPacks()
    
    self:resetLevel()
end

function LevelEditor:erase(tbl, id, contents, tid)
    table.insert(self.undos, { tbl = tbl, id = id, stuff = contents, tid = tid })
    
    table.remove(self.objects[tbl], id)
    self.tools[tid].used = self.tools[tid].used - 1
end

function LevelEditor:undoLastDelete()
    if #self.undos > 0 then
        local undoInfo = self.undos[#self.undos]
        
        table.remove(self.undos, #self.undos)
        
        table.insert(self.objects[undoInfo.tbl], undoInfo.id, undoInfo.stuff)
        self.tools[undoInfo.tid].used = self.tools[undoInfo.tid].used + 1
        
        self:hideToolsDrawer()
    end
end

function LevelEditor:draw()
    if not self.testing then
        sprite(self.images.back, WIDTH/2, HEIGHT/2, WIDTH, HEIGHT)
        
        self:drawObjects()
        
        if self.showingTools then
            self:drawToolsDrawer()
        end
        
        self:drawButtons()
    else
        self.testGame:draw()
        self.stopBtn:draw()
    end
end

function LevelEditor:drawObjects()
    pushStyle()
    noSmooth()
    
    spriteMode(CORNERS)
    if self.showingGrid then
        sprite(self.images.grid, 0,0, WIDTH,HEIGHT)
    end
    
    
    for i, trap in ipairs(self.objects.traps) do
        sprite(self.images.trap, trap.x1, trap.y1, trap.x2, trap.y2)
        
        noFill() stroke(0) strokeWidth(2)
        ellipse(trap.x1, trap.y1, wScale(35))
        ellipse(trap.x2, trap.y2, wScale(35))
    end
    
    for i, stuff in ipairs(self.objects.stickies) do
        sprite(self.images.sticky, stuff.x1, stuff.y1, stuff.x2, stuff.y2)
        
        noFill() stroke(0) strokeWidth(2)
        ellipse(stuff.x1, stuff.y1, wScale(35))
        ellipse(stuff.x2, stuff.y2, wScale(35))
    end
    
    for i, stuff in ipairs(self.objects.icies) do
        sprite(self.images.icy, stuff.x1, stuff.y1, stuff.x2, stuff.y2)
        
        noFill() stroke(0) strokeWidth(2)
        ellipse(stuff.x1, stuff.y1, wScale(35))
        ellipse(stuff.x2, stuff.y2, wScale(35))
    end
    spriteMode(CENTER)
    
    for i, blockedZone in ipairs(self.objects.blockedZones) do
        local width = blockedZone.x2 - blockedZone.x1
        local height = blockedZone.y2 - blockedZone.y1
        strokeWidth(2)
        fill(145, 145, 145, 225) rectMode(CORNERS)
        rect(blockedZone.x1 - wScale(1), blockedZone.y1 - wScale(1), blockedZone.x2 + wScale(2), blockedZone.y2 + wScale(2))
        stroke(0, 0, 0, 255)
        local wale = width / height
        local h = height / 20
        local w = h * wale
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
        rect(blockedZone.x1 - wScale(1), blockedZone.y1 - wScale(1), blockedZone.x2 + wScale(2), blockedZone.y2 + wScale(2))
        
        noFill() stroke(0) strokeWidth(2)
        ellipse(blockedZone.x1, blockedZone.y1, wScale(35))
        ellipse(blockedZone.x2, blockedZone.y2, wScale(35))
    end
    
    for id, stuff in ipairs(self.objects.repels) do
        sprite(self.images.repel, stuff.pos.x, stuff.pos.y, self.repelSize, self.repelSize)
    end
    
    for id, stuff in ipairs(self.objects.suctions) do
        sprite(self.images.suction, stuff.pos.x, stuff.pos.y, self.suctionSize, self.suctionSize)
    end
    
    for id, stuff in ipairs(self.objects.players) do
        fill(self.colours.player) noStroke() rectMode(CENTER)
        rect(stuff.startPos.x, stuff.startPos.y, self.toolSize, self.toolSize)
        for i, glow in ipairs(stuff.glow) do
            glow:draw()
        end
    end
    
    for id, stuff in ipairs(self.objects.positionObjects) do
        if stuff.id == "goal" then
            tint(self.colours.goal)
        else
            noTint()
        end
        sprite(self.images[stuff.id], stuff.pos.x, stuff.pos.y, stuff.size.x, stuff.size.y)
    end
    noTint()
    
    for id, stuff in ipairs(self.objects.patrollers) do
        spriteMode(CENTER)
        sprite(self.images.patroller, stuff.pos1.x, stuff.pos1.y, self.patrolSize)
        sprite(self.images.patroller, stuff.pos2.x, stuff.pos2.y, self.patrolSize)
        stroke(self.colours.patrollers) strokeWidth(2)
        line(stuff.pos1.x, stuff.pos1.y, stuff.pos2.x, stuff.pos2.y)
    end
    
    for id, hint in ipairs(self.objects.hints) do
        stroke(self.colours.hints) strokeWidth(5)
        line(hint.x - self.hintSize/2, hint.y - self.hintSize/2, hint.x + self.hintSize/2, hint.y + self.hintSize/2)
        line(hint.x - self.hintSize/2, hint.y + self.hintSize/2, hint.x + self.hintSize/2, hint.y - self.hintSize/2)
    end
    
    for id, wall in ipairs(self.objects.walls) do
        wall.cline:draw()
        
        fill(self.colours.walls) noStroke()
        ellipse(wall.pos1.x, wall.pos1.y, wScale(20))
        ellipse(wall.pos2.x, wall.pos2.y, wScale(20))
    end
    
    for i, m in pairs(self.meshes) do
        m:draw()
    end

    for id, stuff in ipairs(self.objects.gravSwitches) do
        sprite(self.images.switch, stuff.pos.x, stuff.pos.y, self.switchSize, self.switchSize)
    end
    
    for id, stuff in ipairs(self.objects.locks) do
        tint(255,0,0,255)
        sprite(self.images.lock, stuff.lock.x, stuff.lock.y, self.lockSize, self.lockSize)
        noTint()
        
        fontSize(17)
        fill(0) text("L"..id, stuff.lock.x, stuff.lock.y)
    
        fill(0) text("K"..id, stuff.key.x, stuff.key.y)
    end
    
    popStyle()
end

function LevelEditor:drawButtons()
    for id, btn in ipairs(self.buttons) do
        btn:draw()
    end
end

function LevelEditor:drawToolsDrawer()
    pushStyle()
    
    local cols = 7
    local rows = math.ceil(math.fmod(#self.tools/cols, cols))
    local size = self.toolSize
    local spacing = vec2(wScale(40), hScale(20))
    local barSize = vec2(cols * size + (cols+1) * spacing.x, HEIGHT)
    local startPos = vec2(WIDTH - barSize.x + size/2 + spacing.x, HEIGHT + spacing.y)
    
    spriteMode(CORNER)
    sprite(self.images.toolbox, 0, 0, WIDTH, barSize.y)
    spriteMode(CENTER)
    
    for id, tool in ipairs(self.tools) do
        local row = math.ceil(id/cols, rows)
        local col = id - (cols * (row - 1))
        
        local x = startPos.x + ((col-1) * size) + ((col-1) * spacing.x)
        local y = startPos.y - (row * size) - (row * spacing.y)
        
        fill(255)
        rect(x - size/2, y - size/2, size, size)
        
        fill(0, 0, 0, 255) fontSize(wScale(15))
        text(tool.name, x, y)
        if tool.total ~= nil and tool.used >= tool.total then
            text("MAXED", x, y - size/4)
        end
    end
    
    self.maxLinesSlider:draw()
    self.difficultySlider:draw()
    
    popStyle()
end

function LevelEditor:touched(touch)
    if not self.testing then
        if self.showingTools then
            self:touchToolsDrawer(touch)
            
            self:touchButtons(touch)
        else
            if not self:touchToolsOnBoard(touch) then
                self:touchButtons(touch)
            end
        end
    else
        if not self.testGame:touched(touch) then
            self.stopBtn:touched(touch)
        end
    end
end

function LevelEditor:touchButtons(touch)
    for id, btn in ipairs(self.buttons) do
        btn:touched(touch)
    end
end

function LevelEditor:touchToolsOnBoard(touch)
     for id, stuff in ipairs(self.objects.players) do
        local hid = "PLA: " .. id
        if vec2(stuff.startPos.x, stuff.startPos.y):dist(vec2(touch.x, touch.y)) < self.toolSize / 1.75 then
            if self.erasing then
                self:erase("players", id, stuff, 1)
                
                break
            else
                
                local setglow = function()
                    local x1, x2, y1, y2 = stuff.startPos.x - self.toolSize/2, stuff.startPos.x + self.toolSize/2, stuff.startPos.y - self.toolSize/2, stuff.startPos.y + self.toolSize/2
                    stuff.glow[1]:setPositions(vec2(x1, y1), vec2(x2, y1))
                    stuff.glow[2]:setPositions(vec2(x2, y1), vec2(x2, y2))
                    stuff.glow[3]:setPositions(vec2(x2, y2), vec2(x1, y2))
                    stuff.glow[4]:setPositions(vec2(x1, y2), vec2(x1, y1))
                end
                
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    stuff.toff = vec2(stuff.startPos.x - touch.x, stuff.startPos.y - touch.y)
                    
                    stuff.startPos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    setglow()
                    
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    stuff.startPos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    setglow()
                    
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    stuff.startPos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    self.holding = nil
                    
                    setglow()
                    
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
    end
    
    for id, stuff in ipairs(self.objects.positionObjects) do
        local hid = "PO: " .. id
        local size = stuff.size or vec2(self.toolSize, self.toolSize)
        size = math.max(size.x, size.y)
        if vec2(stuff.pos.x, stuff.pos.y):dist(vec2(touch.x, touch.y)) < size / 2 then
            if self.erasing then
                self:erase("positionObjects", id, stuff, 2)
                
                break
            else
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    
                    stuff.toff = vec2(stuff.pos.x - touch.x, stuff.pos.y - touch.y)
                    
                    stuff.pos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    stuff.pos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    stuff.pos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    self.holding = nil
                    
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
    end
    
    for id, stuff in ipairs(self.objects.blockedZones) do
        local pos = { { check = vec2(stuff.x1, stuff.y1), change = { x = "x1", y = "y1" },
                        max = { x = stuff.x2, y = stuff.y2 }, min = { x = 0, y = 0 } }, 
                      { check = vec2(stuff.x2, stuff.y2), change = {x = "x2", y = "y2" },
                        max = { x = WIDTH, y = HEIGHT }, min = { x = stuff.x1, y = stuff.y1 } } }
        for i, p in ipairs(pos) do
            local hid = "BZ: " .. id .. ", " .. i
            if vec2(p.check.x, p.check.y):dist(vec2(touch.x, touch.y)) < wScale(20) then
                if self.erasing then
                    self:erase("blockedZones", id, stuff, 3)
                
                    break
                else
                    if touch.state == BEGAN and self.holding == nil then
                        self.holding = hid
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        
                        return true
                    elseif touch.state == MOVING and self.holding == hid then
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        
                        return true
                    elseif touch.state == ENDED and self.holding == hid then
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        self.holding = nil
                        
                        return true
                    end
                end
            elseif self.holding == hid then
                self.holding = nil
                
                return true
            end
        end
        
        local hid = "BZ: "..id..", mid"
        local width, height = stuff.x2 - stuff.x1, stuff.y2 - stuff.y1
        if touch.x > stuff.x1 and touch.x < stuff.x2 and touch.y > stuff.y1 and touch.y < stuff.y2 then
            if self.erasing then
                self:erase("blockedZones", id, stuff, 3)
                
                break
            else
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    stuff.toff = vec2((stuff.x1 + width/2) - touch.x, (stuff.y1 + height/2) - touch.y)
                    
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    self.holding = hid
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    self.holding = nil
                    
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
    end
    
    for id, stuff in ipairs(self.objects.traps) do
        local pos = { { check = vec2(stuff.x1, stuff.y1), change = { x = "x1", y = "y1" },
                        max = { x = stuff.x2, y = stuff.y2 }, min = { x = 0, y = 0 } }, 
                      { check = vec2(stuff.x2, stuff.y2), change = {x = "x2", y = "y2" },
                        max = { x = WIDTH, y = HEIGHT }, min = { x = stuff.x1, y = stuff.y1 } } }
        for i, p in ipairs(pos) do
            local hid = "TR: " .. id .. ", " .. i
            if vec2(p.check.x, p.check.y):dist(vec2(touch.x, touch.y)) < wScale(20) then
                if self.erasing then
                    self:erase("traps", id, stuff, 8)
                    
                    break
                else
                    if touch.state == BEGAN and self.holding == nil then
                        self.holding = hid
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        
                        return true
                    elseif touch.state == MOVING and self.holding == hid then
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        
                        return true
                    elseif touch.state == ENDED and self.holding == hid then
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        self.holding = nil
                        
                        return true
                    end
                end
            elseif self.holding == hid then
                self.holding = nil
                
                return true
            end
        end
        
        local hid = "TR: "..id..", mid"
        local width, height = stuff.x2 - stuff.x1, stuff.y2 - stuff.y1
        if touch.x > stuff.x1 and touch.x < stuff.x2 and touch.y > stuff.y1 and touch.y < stuff.y2 then
            if self.erasing then
                self:erase("traps", id, stuff, 8)
                    
                break
            else
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    stuff.toff = vec2((stuff.x1 + width/2) - touch.x, (stuff.y1 + height/2) - touch.y)
                    
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    self.holding = hid
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    self.holding = nil
                    
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
    end
    
    for id, stuff in ipairs(self.objects.patrollers) do
        local pos = { { check = stuff.pos1, change = "pos1", hid = "PA: "..id..", 1" }, 
                      { check = stuff.pos2, change = "pos2", hid = "PA: "..id..", 2" } }
        for i, p in ipairs(pos) do
            if vec2(p.check.x, p.check.y):dist(vec2(touch.x, touch.y)) < self.patrolSize/1.5 then
                if self.erasing then
                    self:erase("patrollers", id, stuff, 4)
                    
                    break
                else
                    if touch.state == BEGAN and self.holding == nil then
                        self.holding = p.hid
                        stuff[p.change] = vec2(touch.x, touch.y)
                        
                        return true
                    elseif touch.state == MOVING and self.holding == p.hid then
                        stuff[p.change] = vec2(touch.x, touch.y)
                        
                        return true
                    elseif touch.state == ENDED and self.holding == p.hid then
                        stuff[p.change] = vec2(touch.x, touch.y)
                        self.holding = nil
                        
                        return true
                    end
                end
            elseif self.holding == p.hid then
                self.holding = nil
                
                return true
            end
        end
    end
    
    for id, hint in ipairs(self.objects.hints) do
        local hid = "HI: " .. id
        if vec2(touch.x, touch.y):dist(hint) < self.hintSize then
            if self.erasing then
                self:erase("hints", id, hint, 5)
                    
                break
            else
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    
                    hint.x, hint.y = touch.x, touch.y
                    
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    hint.x, hint.y = touch.x, touch.y
                     
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    self.holding = nil
                    
                    hint.x, hint.y = touch.x, touch.y
                    
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
    end
    
    for id, stuff in ipairs(self.objects.walls) do
        local pos = { { check = stuff.pos1, change = "pos1", hid = "WA: "..id..", 1" }, 
                      { check = stuff.pos2, change = "pos2", hid = "WA: "..id..", 2" } }
        for i, p in ipairs(pos) do
            if vec2(p.check.x, p.check.y):dist(vec2(touch.x, touch.y)) < wScale(17.5) then
                if self.erasing then
                    self:erase("walls", id, stuff, 6)
                    
                    break
                else
                    if touch.state == BEGAN and self.holding == nil then
                        self.holding = p.hid
                        stuff[p.change] = vec2(touch.x, touch.y)
                        stuff.cline:setPositions(stuff.pos1, stuff.pos2)
                
                        return true
                    elseif touch.state == MOVING and self.holding == p.hid then
                        stuff[p.change] = vec2(touch.x, touch.y)
                        stuff.cline:setPositions(stuff.pos1, stuff.pos2)
                
                        return true
                    elseif touch.state == ENDED and self.holding == p.hid then
                        stuff[p.change] = vec2(touch.x, touch.y)
                        self.holding = nil
                        stuff.cline:setPositions(stuff.pos1, stuff.pos2)
                
                        return true
                    end
                end
            elseif self.holding == p.hid then
                self.holding = nil
                
                return true
            end
        end
    end
    
    for id, stuff in ipairs(self.objects.locks) do
        local hid = "LO: "..id..", lock"
        local s = self.lockSize/1.5
        if touch.x > stuff.lock.x - s and touch.x < stuff.lock.x + s
        and touch.y > stuff.lock.y - s and touch.y < stuff.lock.y + s then
            if self.erasing then
                self:erase("locks", id, stuff, 7)
                
                self.meshes.keys:setRect(stuff.keyMeshId, 0,0,0,0)
                    
                break
            else
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    stuff.ltoff = vec2(stuff.lock.x - touch.x, stuff.lock.y - touch.y)
                    
                    stuff.lock = vec2(touch.x + stuff.ltoff.x, touch.y + stuff.ltoff.y)
                    
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    stuff.lock = vec2(touch.x + stuff.ltoff.x, touch.y + stuff.ltoff.y)
                    
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    stuff.lock = vec2(touch.x + stuff.ltoff.x, touch.y + stuff.ltoff.y)
                    self.holding = nil
                    
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
        
        local hid = "LO: "..id..", key"
        local r = wScale(30)
        if stuff.key:dist(vec2(touch.x, touch.y)) < r then
            if self.erasing then
                self:erase("locks", id, stuff, 7)
                    
                self.meshes.keys:setRect(stuff.keyMeshId, 0,0,0,0)
                
                break
            else
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    stuff.ktoff = vec2(stuff.key.x - touch.x, stuff.key.y - touch.y)
                    
                    stuff.key = vec2(touch.x + stuff.ktoff.x, touch.y + stuff.ktoff.y)
                    
                    self.meshes.keys:setRect(stuff.keyMeshId, stuff.key.x, stuff.key.y, self.keySize.x, self.keySize.y)
            
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    stuff.key = vec2(touch.x + stuff.ktoff.x, touch.y + stuff.ktoff.y)
                    
                    self.meshes.keys:setRect(stuff.keyMeshId, stuff.key.x, stuff.key.y, self.keySize.x, self.keySize.y)
            
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    stuff.key = vec2(touch.x + stuff.ktoff.x, touch.y + stuff.ktoff.y)
                    
                    self.holding = nil
                    self.meshes.keys:setRect(stuff.keyMeshId, stuff.key.x, stuff.key.y, self.keySize.x, self.keySize.y)
            
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
    end
    
    for id, stuff in ipairs(self.objects.gravSwitches) do
        local hid = "GS: " .. id
        if vec2(touch.x, touch.y):dist(stuff.pos) < self.switchSize then
            if self.erasing then
                self:erase("gravSwitches", id, stuff, 9)
                    
                break
            else
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    
                    stuff.pos = vec2(touch.x, touch.y)
                    
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    stuff.pos = vec2(touch.x, touch.y)
                     
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    self.holding = nil
                    
                    stuff.pos = vec2(touch.x, touch.y)
                    
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
    end
    
    for id, stuff in ipairs(self.objects.repels) do
        local hid = "RPL: " .. id
        local size = self.repelSize
        if vec2(stuff.pos.x, stuff.pos.y):dist(vec2(touch.x, touch.y)) < size / 2 then
            if self.erasing then
                self:erase("repels", id, stuff, 10)
                
                break
            else
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    
                    stuff.toff = vec2(stuff.pos.x - touch.x, stuff.pos.y - touch.y)
                    
                    stuff.pos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    stuff.pos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    stuff.pos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    self.holding = nil
                    
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
    end
    
    for id, stuff in ipairs(self.objects.suctions) do
        local hid = "SUC: " .. id
        local size = self.suctionSize
        if vec2(stuff.pos.x, stuff.pos.y):dist(vec2(touch.x, touch.y)) < size / 2 then
            if self.erasing then
                self:erase("suctions", id, stuff, 11)
                
                break
            else
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    
                    stuff.toff = vec2(stuff.pos.x - touch.x, stuff.pos.y - touch.y)
                    
                    stuff.pos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    stuff.pos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    stuff.pos = vec2(touch.x + stuff.toff.x, touch.y + stuff.toff.y)
                    
                    self.holding = nil
                    
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
    end
    
    for id, stuff in ipairs(self.objects.stickies) do
        local pos = { { check = vec2(stuff.x1, stuff.y1), change = { x = "x1", y = "y1" },
                        max = { x = stuff.x2, y = stuff.y2 }, min = { x = 0, y = 0 } }, 
                      { check = vec2(stuff.x2, stuff.y2), change = {x = "x2", y = "y2" },
                        max = { x = WIDTH, y = HEIGHT }, min = { x = stuff.x1, y = stuff.y1 } } }
        for i, p in ipairs(pos) do
            local hid = "STZ: " .. id .. ", " .. i
            if vec2(p.check.x, p.check.y):dist(vec2(touch.x, touch.y)) < wScale(20) then
                if self.erasing then
                    self:erase("stickies", id, stuff, 12)
                    
                    break
                else
                    if touch.state == BEGAN and self.holding == nil then
                        self.holding = hid
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        
                        return true
                    elseif touch.state == MOVING and self.holding == hid then
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        
                        return true
                    elseif touch.state == ENDED and self.holding == hid then
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        self.holding = nil
                        
                        return true
                    end
                end
            elseif self.holding == hid then
                self.holding = nil
                
                return true
            end
        end
        
        local hid = "STZ: "..id..", mid"
        local width, height = stuff.x2 - stuff.x1, stuff.y2 - stuff.y1
        if touch.x > stuff.x1 and touch.x < stuff.x2 and touch.y > stuff.y1 and touch.y < stuff.y2 then
            if self.erasing then
                self:erase("stickies", id, stuff, 12)
                    
                break
            else
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    stuff.toff = vec2((stuff.x1 + width/2) - touch.x, (stuff.y1 + height/2) - touch.y)
                    
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    self.holding = hid
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    self.holding = nil
                    
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
    end
    
    
    for id, stuff in ipairs(self.objects.icies) do
        local pos = { { check = vec2(stuff.x1, stuff.y1), change = { x = "x1", y = "y1" },
                        max = { x = stuff.x2, y = stuff.y2 }, min = { x = 0, y = 0 } }, 
                      { check = vec2(stuff.x2, stuff.y2), change = {x = "x2", y = "y2" },
                        max = { x = WIDTH, y = HEIGHT }, min = { x = stuff.x1, y = stuff.y1 } } }
        for i, p in ipairs(pos) do
            local hid = "ICY: " .. id .. ", " .. i
            if vec2(p.check.x, p.check.y):dist(vec2(touch.x, touch.y)) < wScale(20) then
                if self.erasing then
                    self:erase("icies", id, stuff, 13)
                    
                    break
                else
                    if touch.state == BEGAN and self.holding == nil then
                        self.holding = hid
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        
                        return true
                    elseif touch.state == MOVING and self.holding == hid then
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        
                        return true
                    elseif touch.state == ENDED and self.holding == hid then
                        stuff[p.change.x] = math.min(math.max(touch.x, p.min.x), p.max.x)
                        stuff[p.change.y] = math.min(math.max(touch.y, p.min.y), p.max.y)
                        self.holding = nil
                        
                        return true
                    end
                end
            elseif self.holding == hid then
                self.holding = nil
                
                return true
            end
        end
        
        local hid = "ICY: "..id..", mid"
        local width, height = stuff.x2 - stuff.x1, stuff.y2 - stuff.y1
        if touch.x > stuff.x1 and touch.x < stuff.x2 and touch.y > stuff.y1 and touch.y < stuff.y2 then
            if self.erasing then
                self:erase("stickies", id, stuff, 13)
                    
                break
            else
                if touch.state == BEGAN and self.holding == nil then
                    self.holding = hid
                    stuff.toff = vec2((stuff.x1 + width/2) - touch.x, (stuff.y1 + height/2) - touch.y)
                    
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    return true
                elseif touch.state == MOVING and self.holding == hid then
                    self.holding = hid
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    return true
                elseif touch.state == ENDED and self.holding == hid then
                    stuff.x1 = touch.x - width/2 + stuff.toff.x
                    stuff.x2 = touch.x + width/2 + stuff.toff.x
                    stuff.y1 = touch.y - height/2 + stuff.toff.y
                    stuff.y2 = touch.y + height/2 + stuff.toff.y
                    
                    self.holding = nil
                    
                    return true
                end
            end
        elseif self.holding == hid then
            self.holding = nil
            
            return true
        end
    end
 end
        
function LevelEditor:touchToolsDrawer(touch)
    local cols = 7
    local rows = math.ceil(math.fmod(#self.tools/cols, cols))
    local size = self.toolSize
    local spacing = vec2(wScale(40), hScale(20))
    local barSize = vec2(cols * size + (cols+1) * spacing.x, HEIGHT)
    local startPos = vec2(WIDTH - barSize.x + size/2 + spacing.x, HEIGHT + spacing.y)
    
    for id, tool in ipairs(self.tools) do
        local row = math.ceil(id/cols, rows)
        local col = id - (cols * (row - 1))
        
        local x = startPos.x + ((col-1) * size) + ((col-1) * spacing.x)
        local y = startPos.y - (row * size) - (row * spacing.y)
        
        if vec2(x,y):dist(vec2(touch.x, touch.y)) < size / 2 and (tool.total == nil or tool.used < tool.total) and touch.state == ENDED then
            tool.used = tool.used + 1
            if tool.type == "players" then
                stuff = { startPos = vec2(touch.x, touch.y) }
                local x1, x2, y1, y2 = stuff.startPos.x - self.toolSize/2, stuff.startPos.x + self.toolSize/2, stuff.startPos.y - self.toolSize/2, stuff.startPos.y + self.toolSize/2
                stuff.glow = {
                    GlowLine(vec2(x1, y1), vec2(x2, y1),hScale(4)),
                    GlowLine(vec2(x2, y1), vec2(x2, y2),hScale(4)),
                    GlowLine(vec2(x2, y2), vec2(x1, y2),hScale(4)),
                    GlowLine(vec2(x1, y2), vec2(x1, y1),hScale(4))
                }
            elseif tool.type == "positionObjects" then
                stuff = { id = tool.id, pos = vec2(touch.x, touch.y), size = tool.size }
            elseif tool.type == "blockedZones" or tool.type == "traps" or tool.type == "stickies" or tool.type == "icies" then
                stuff = { x1 = touch.x - self.toolSize, y1 = touch.y - self.toolSize, 
                          x2 = touch.x + self.toolSize/2, y2 = touch.y + self.toolSize/2 }
            elseif tool.type == "patrollers" then
                stuff = { pos1 = vec2(touch.x - wScale(150), touch.y), pos2 = vec2(touch.x, touch.y) }
            elseif tool.type == "hints" then
                stuff = vec2(touch.x, touch.y)
            elseif tool.type == "walls" then
                stuff = { pos1 = vec2(touch.x - wScale(100), touch.y), pos2 = vec2(touch.x, touch.y) }
                stuff.cline = GlowLine(stuff.pos1, stuff.pos2, 3)
                stuff.cline.m.shader.color = vec4(0,0,0,1)
            elseif tool.type == "locks" then
                stuff = { lock = vec2(touch.x - wScale(150), touch.y), key = vec2(touch.x, touch.y) }
                stuff.keyMeshId = self.meshes.keys:addRect(touch.x, touch.y, self.keySize.x, self.keySize.y)
            elseif tool.type == "gravSwitches" or tool.type == "repels" or tool.type == "suctions" then
                stuff = { pos = vec2(touch.x, touch.y) }
            elseif tool.type == "eraser" then
                self.erasing = not self.erasing
            elseif tool.type == "grid" then
                self.showingGrid = not self.showingGrid
            elseif tool.type == "undo" then
                self:undoLastDelete()
            end
            
            if tool.type ~= "eraser" and tool.type ~= "grid" and tool.type ~= "undo" then
                table.insert(self.objects[tool.type], stuff)
                self.erasing = false
                -- elseif tool.type ~= "eraser" and tool.type ~= "grid" then
                self:hideToolsDrawer()
            end
        end
    end
    
    self.maxLinesSlider:touched(touch)
    self.difficultySlider:touched(touch)
end


