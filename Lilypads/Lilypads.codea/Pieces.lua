Vertical = class(Piece)

function Vertical:init()
    Piece.init(self)
end

function Vertical:canMoveIn(coord)
    return coord.x == 0
end

function Vertical:canMoveOut(coord)
    return coord.x == 0
end

function Vertical:drawPiece(width, height)
    fill(self.colour) rectMode(CORNER)
    rect(-width / 2, -height / 2, width / 3, height)
    rect(-width / 2 + width * 2/3, -height / 2, width / 3, height)
end


Horizontal = class(Vertical)

function Horizontal:init()
    Vertical.init(self)
    
    self.rotation = 90
    self.invertWidthHeight = true
end

function Horizontal:canMoveIn(coord)
    return coord.y == 0
end

function Horizontal:canMoveOut(coord)
    return coord.y == 0
end

BottomLeft = class(Piece)

function BottomLeft:init(x)
    Piece.init(self)
end

function BottomLeft:canMoveIn(coord)
    return (coord.x == 0 and coord.y == -1) or (coord.x == -1 and coord.y == 0)
end

function BottomLeft:canMoveOut(coord)
    return (coord.x == 0 and coord.y == 1) or (coord.x == 1 and coord.y == 0)
end

function BottomLeft:drawPiece(width, height)
    fill(self.colour) rectMode(CORNER)
    rect(-width / 2, -height / 2, width / 3, height)
    rect(-width / 2, -height / 2, width, height / 3)
    rect(-width / 2 + width * 2/3, -height / 2 + height * 2/3, width / 3, height / 3)
end

BottomRight = class(BottomLeft)

function BottomRight:init(x)
    BottomLeft.init(self)
    
    self.rotation = 90
    self.invertWidthHeight = true
end

function BottomRight:canMoveIn(coord)
    return (coord.x == 0 and coord.y == -1) or (coord.x == 1 and coord.y == 0)
end

function BottomRight:canMoveOut(coord)
    return (coord.x == 0 and coord.y == 1) or (coord.x == -1 and coord.y == 0)
end

TopLeft = class(Piece)

function TopLeft:init()
    Piece.init(self)
end

function TopLeft:canMoveIn(coord)
    return (coord.x == 0 and coord.y == 1) or (coord.x == -1 and coord.y == 0)
end

function TopLeft:canMoveOut(coord)
    return (coord.x == 0 and coord.y == -1) or (coord.x == 1 and coord.y == 0)
end

function TopLeft:drawPiece(width, height)
    fill(self.colour) rectMode(CORNER)
    rect(-width / 2, -height / 2, width / 3, height)
    rect(-width / 2, -height / 2 + height * 2/3, width, height / 3)
    rect(-width / 2 + width * 2/3, -height / 2, width / 3, height / 3)
end


TopRight = class(TopLeft)

function TopRight:init(x)
    TopLeft.init(self)
    
    self.rotation = 270
    self.invertWidthHeight = true
end

function TopRight:canMoveIn(coord)
    return (coord.x == 0 and coord.y == 1) or (coord.x == 1 and coord.y == 0)
end

function TopRight:canMoveOut(coord)
    return (coord.x == 0 and coord.y == -1) or (coord.x == -1 and coord.y == 0)
end

AllSides = class(Piece)

function AllSides:init()
    Piece.init(self)
end

function AllSides:canMoveIn(coord)
    return true
end

function AllSides:canMoveOut(coord)
    return true
end

Goal = class(AllSides)

function Goal:init(x)
    AllSides.init(self)
    self.colour = color(21, 255, 0, 255)
end

pieces = { }
pieces["h"] = Horizontal
pieces["v"] = Vertical
pieces["bl"] = BottomLeft
pieces["br"] = BottomRight
pieces["tl"] = TopLeft
pieces["tr"] = TopRight
pieces["s"] = AllSides
pieces["f"] = Goal

