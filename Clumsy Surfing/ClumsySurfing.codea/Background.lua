Background = class()

function Background:init(x)
    self.col = color(210, 230, 230, 255)
    self.col = color(146, 183, 192, 255)

    self.tree = mesh()
    self.tree.texture = readImage("Project:Palm Tree 2")
    local tw, th = self.tree.texture.width, self.tree.texture.height
    
    self.trees = {}
    for i = 1,7 do
        local mInd = self.tree:addRect(0,0,0,0)
        self.trees[i] = { mI = mInd, x = 0, y = 0, w = 0, h = 0 }
        
        self:createTree(i, (WIDTH / 6) * (i-1))
    end
    self.tree:setColors(255, 255, 255, 200)
end

function Background:createTree(ind) 
    self.trees[ind].h = math.random(HEIGHT // 4, HEIGHT)
    self.trees[ind].y = self.trees[ind].h // 2.1    -- 2.1 so that the bottom goes under the screen and is not seen
    self.trees[ind].w = (self.tree.texture.width / self.tree.texture.height) * self.trees[ind].h
    local spacing = 20
    self.trees[ind].x = self:rightmostTree() + spacing + self.trees[ind].w / 2
        
    self.tree:setRect(self.trees[ind].mI, self.trees[ind].x, self.trees[ind].y, self.trees[ind].w, self.trees[ind].h)
end

function Background:rightmostTree()
    local right = 0
    for i, t in ipairs(self.trees) do
        local r = t.x + t.w / 2
        right = math.max(right, r)
    end
    
    return right
end

function Background:draw(speed)
    --background(self.col)
    
    -- move trees && update mesh
    for i, t in ipairs(self.trees) do
        t.x = t.x - speed
        
        if (t.x + t.w/2 < 0) then
            self:createTree(i)
        end
        
        self.tree:setRect(t.mI, t.x, t.y, t.w, t.h)
    end
    
    -- 
    self.tree:draw()
end

function Background:touched(touch)
    -- Codea does not automatically call this method
end
