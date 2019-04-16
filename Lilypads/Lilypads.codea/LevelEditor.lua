LevelEditor = class()

function LevelEditor:init()
    displayMode(OVERLAY)
    displayMode(FULLSCREEN)
    
    self.selectedPiece = "s"
    self.pieceInstances = {}
    self.nToP = {}
    self.nToP[0] = " "
    for id, piece in pairs(pieces) do
        table.insert(self.pieceInstances, piece())
        self.nToP[#self.pieceInstances] = id
        --parameter.action(id, function() self.selectedPiece = id end)
    end
    
    self.map = {}
    self:reset()
    
    parameter.integer("rows", 4, 10, 5, function(r) self:setRows(r) end)
    parameter.integer("cols", 3, 10, 4, function(c) self:setCols(c) end)
    parameter.action("Export", function() self:export() self.finished = true displayMode(FULLSCREEN) end)
    parameter.action("Quit (Lose Level)", function() self.finished = true displayMode(FULLSCREEN) end)
end

function LevelEditor:reset()
    self.finished = false
    self.map = {}
    self.rows, self.cols = 0, 0
    self:setRows(5)
    self:setCols(4)
end

function LevelEditor:nTpT()
    local n = {}
    for foo, t in ipairs(self.map) do
        table.insert(n, {})
        for bar, im in ipairs(t) do
            table.insert(n[#n], self.nToP[im])
        end
    end
    
    return n
end

function LevelEditor:export()
    local map = self:nTpT()
    local pname = math.floor(self.cols) .. " x " .. math.floor(self.rows)
    local foundpack = false
    for id, pack in ipairs(levelPacks) do
        if pack.name == pname then
            table.insert(pack.levels, map)
            
            foundpack = true
        end
    end
    
    if not foundpack then
        table.insert(levelPacks, { name = pname, levels = { map } })
    end
    
    saveProjectTable("levelPacks", levelPacks)
end

function LevelEditor:setRows(r)
    if (self.rows or 0) < r then
        while #self.map < r do
            local nt = {}
            for _ = 1, self.cols do
                table.insert(nt, 0)
            end
            table.insert(self.map, nt)
        end
    elseif (self.rows or 0) > r then
        while #self.map > r do
            table.remove(self.map, #self.map)
        end
    end
    
    self.rows = r
end

function LevelEditor:setCols(c)
    if (self.cols or 0) < c then
        for r, ct in ipairs(self.map) do
            while #ct < c do 
                table.insert(ct, 0)
            end
        end
    elseif (self.cols or 0) > c then
        for r, ct in ipairs(self.map) do
            while #ct > c do
                table.remove(ct, #ct)
            end
        end
    end
    
    self.cols = c
end

function LevelEditor:draw()
    local size = vec2(WIDTH / self.cols, HEIGHT / self.rows)
    
    for r = 1, self.rows do
        local y = HEIGHT + (size.y / 2) - (size.y * r)
        for c = 1, self.cols do
            local x = (-size.x / 2) + (size.x * c)
            
            if self.map[r][c] == 0 or self.map[r][c] == nil then
                strokeWidth(5) rectMode(CENTER)
                stroke(0)  noFill()
                rect(x, y, size.x, size.y)
            end
            if self.map[r][c] ~= 0 and self.map[r][c] ~= nil then
                self.pieceInstances[self.map[r][c]]:draw(x, y, size.x, size.y)
            end
            if r == 1 and c == 1 then
                fill(204, 0, 255, 255) noStroke()
                ellipse(x, y, size.x / 3)
            end
        end
    end
end

function LevelEditor:touched(t)
    local size = vec2(WIDTH / self.cols, HEIGHT / self.rows)
    
    for r = 1, self.rows do
        local y = HEIGHT + (size.y / 2) - (size.y * r)
        for c = 1, self.cols do
            local x = (-size.x / 2) + (size.x * c)
            
            if t.x > x - size.x / 2 and t.x < x + size.x / 2 and t.y > y - size.y / 2 and t.y < y + size.y / 2
            and t.state == ENDED then
                self.map[r][c] = (self.map[r][c] + 1) % (#self.pieceInstances + 1)
            end
        end
    end
end


