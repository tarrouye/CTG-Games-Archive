-- Puzzle
-- Game Jam entry (https://codea.io/talk/discussion/6361/game-jam-2015-winners-announced/p1)
-- Copyright 2015 Théo Arrouye

displayMode(FULLSCREEN)
supportedOrientations(PORTRAIT)

function setup()
    font("Futura-CondensedMedium") textAlign(CENTER)

    music("Dropbox:Little Town", true)
    
    if not readProjectData("levelPacks") then
        levelPacks = {}
        levelPacks[1] = {
            name = "4 x 5", levels = { {
                {"s", "s", " ", " "},
                {"s", " ", "s", " "},
                {"s", " ", " ", " "},
                {" ", "s", " ", "s"},
                {" ", " ", " ", "f"}
            } }
        }
        saveProjectTable("levelPacks", levelPacks)
    end
    
    globalTouches = {}
    loadstring(readProjectData("levelPacks", "levelPacks = {}"))()
    loadstring(readLocalData("completedLevels", "completedLevels = {}"))()
    
    screen = Selection()
end

function draw()
    background(255)
    
    clip(0, 0, WIDTH, HEIGHT)
    screen:draw()
end

function touched(t)
    screen:touched(t)
end



