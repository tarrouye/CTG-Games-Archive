Board = class()

local defaultMap = { {} }
local defaultSize = vec2(WIDTH, HEIGHT * 5/6)

local tileMoveDuration = 0.35

function Board:init()
    self:initVariables()
    self:resetDefaults()
end

function Board:initVariables()
    self.pieceInstances = {}
    for id, piece in pairs(pieces) do
        self.pieceInstances[id] = piece()
    end
end

function Board:resetDefaults()
    self.map = defaultMap
    self.size = defaultSize
    self:calculateTileSize()
    self:calculateTiles()
end

function Board:setMap(tiles)
    self.map = tiles
    self:calculateTileSize()
    self:calculateTiles()
end

function Board:setSize(size)
    self.size = size
    self:calculateTileSize()
end

function Board:calculateTiles()
    self.tiles = {}
    
    for r = #self.map, 1, -1 do
        for c = 1, #self.map[r], 1 do
            if self.pieceInstances[self.map[r][c]] then
                local x = WIDTH - ((#self.map[r] - c + 1) * self.tileSize.x) + self.tileSize.x / 2
                local y = HEIGHT - (r * self.tileSize.y) + self.tileSize.y / 2
                
                local mstile = { x = x, y = y, fade = 0, key = self.map[r][c] }
                
                if r == 1 and c == 1 then
                    self.player = { x = x, y = y, tile = self.map[r][c] }
                    mstile.currentlyPlayer = true
                end
                
                table.insert(self.tiles, mstile)
            end
        end
    end
end

function Board:calculateTileSize()
    self.tileSize = vec2( self.size.x / #self.map[1], self.size.y / #self.map )
end

function Board:highlightNextMoves()
    local possibleMoves = 0
    
    for i, tile in ipairs(self.tiles) do
        tile.allowedMove, tile.shiftAnyways = false, false
        local coord = vec2(math.signOrZero(tile.x - self.player.x), math.signOrZero(tile.y - self.player.y))
        if not tile.currentlyPlayer
        and ((math.abs(self.player.y - tile.y) - self.tileSize.y <= 0.01 and math.abs(self.player.x - tile.x) <= 0.01)
        or (math.abs(self.player.x - tile.x) - self.tileSize.x <= 0.01 and math.abs(self.player.y - tile.y) <= 0.01)) then
            if self.pieceInstances[self.player.tile]:canMoveOut(coord) 
            and self.pieceInstances[tile.key]:canMoveIn(coord) then
                tile.allowedMove = true
                possibleMoves = possibleMoves + 1
            else
                tile.shiftAnyways = true
            end
        end
    end

    if possibleMoves == 0 then
        self.finished = "failed"
    end
end

function Board:loadLevel(tiles)
    self.finished = nil
    self:setMap(tiles)
    self:highlightNextMoves()
    -- Add some transition effect code?
end

function Board:drawTile(tile)
    self.pieceInstances[tile.key]:draw(tile.x, tile.y, self.tileSize.x, self.tileSize.y)
    if tile.fade > 0 then
        fill(255, 255 * tile.fade)
        rect(tile.x, tile.y, self.tileSize.x, self.tileSize.y)
    end
   
    if tile.allowedMove then
        fill(255, 250, 0, 120 * self:fade())
        rect(tile.x, tile.y, self.tileSize.x, self.tileSize.y)
    end
end

function Board:drawPlayer()
    fill(228, 0, 255, 255)
    ellipse(self.player.x, self.player.y, self.tileSize.x / 3)
end

function Board:draw()
    pushStyle()
    
    noStroke() rectMode(CENTER)

    for tileId, tile in pairs(self.tiles) do
        self:drawTile(tile)
    end
    self:drawPlayer()
    
    popStyle()
end

function Board:fade()
    if self.fadeeffect == nil then
        self.fadeeffect = 0
        tween(0.5, self, { fadeeffect = 1 }, { loop = tween.loop.pingpong })
    end
    
    return self.fadeeffect
end

function Board:tileAtPoint(poignt)
    for i, tile in ipairs(self.tiles) do
        if poignt.x > tile.x - self.tileSize.x / 2 and poignt.x < tile.x + self.tileSize.x / 2
        and poignt.y > tile.y - self.tileSize.y / 2 and poignt.y < tile.y + self.tileSize.y / 2 then
            return { id = i, tile = tile}
        end
    end
end

function Board:movePlayer(tb)
    local dir = vec2(tb.tile.x - self.player.x, tb.tile.y - self.player.y)
    
    local toMove = {}
    for i, tile in ipairs(self.tiles) do
        if (tile.allowedMove or tile.shiftAnyways) and tile ~= tb.tile then
            local off = vec2(self.player.x - tile.x, self.player.y - tile.y)
            if not self:tileAtPoint(vec2(tb.tile.x - off.x, tb.tile.y - off.y)) then
                table.insert(toMove, { tid = i, x = tb.tile.x - off.x, y = tb.tile.y - off.y })
            end
        elseif tile.currentlyPlayer then
            tween(tileMoveDuration, self.tiles[i], { fade = 1 }, tween.easing.linear, function()
                table.remove(self.tiles, i)
            end)
        end
    end
    
    for _, move in ipairs(toMove) do
        tween(tileMoveDuration, self.tiles[move.tid], { x = move.x, y = move.y })
    end
    
    self.player.moving = tween(tileMoveDuration, self.player, { x = tb.tile.x, y = tb.tile.y }, tween.easing.linear,
    function()
        if tb.tile.key == "f" then
            self.finished = "success"
        else
            self.player.moving = nil
            tb.tile.currentlyPlayer = true
            self.player.tile = tb.tile.key
            self:highlightNextMoves()
        end
    end)
end

function Board:touched(t)
    if self:tileAtPoint(t) and self:tileAtPoint(t).tile.allowedMove and not self.player.moving then
        self:movePlayer(self:tileAtPoint(t))
    end
end


