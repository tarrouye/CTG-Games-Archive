Piece = class()

function Piece:init()
    self.colour = color(0, 187, 255, 255)
    
    self.rotation = 0
    self.invertWidthHeight = false
end

function Piece:open()
    return "yes"
end

function Piece:makeImage(width, height)    
    self.image = image(math.max(width, height), math.max(width, height)) 
    setContext(self.image)
    pushMatrix() resetMatrix()
    
    self:setScene(self.image.width / 2, self.image.height / 2)
    self:drawPiece(width, height)
    
    popMatrix()
    setContext()
    
    
    self.lastWidth, self.lastHeight = width, height
end

function Piece:drawImage(x, y, width, height)
    sprite(self.image, x, y)
end

function Piece:draw(x, y, width, height)
    pushStyle()
    resetStyle()
    pushMatrix()
    
    local w, h
    if self.invertWidthHeight then
        w, h = height, width
    else
        w, h = width, height
    end
    if w ~= self.lastWidth or h ~= self.lastHeight then
        self:makeImage(w, h)
    end
    
    self:drawImage(x, y)
    
    
    popMatrix()
    popStyle()
end

function Piece:setScene(x, y)
    translate(x, y)
    rotate(self.rotation)
end

function Piece:drawPiece(width, height)
    fill(self.colour) rectMode(CORNER)
    rect(-width / 2, -height / 2, width / 3, height / 3)
    rect(-width / 2, -height / 2 + height * 2/3, width / 3, height / 3)
    rect(-width / 2 + width * 2/3, -height / 2, width / 3, height / 3)
    rect(-width / 2 + width * 2/3, -height / 2 + height * 2/3, width / 3, height / 3)
end

function Piece:touched(touch)
    -- Codea does not automatically call this method
end


