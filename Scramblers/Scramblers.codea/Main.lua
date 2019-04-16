-- Anagrams

displayMode(FULLSCREEN_NO_BUTTONS)
-- supportedOrientations(LANDSCAPE_ANY)
function setup()
    -- Set font
    STANDARDFONT = "HelveticaNeue-UltraLight"
    WORDFONT = "Futura-CondensedMedium"
    
    -- Load words and split to table format
    loadstring(readProjectData("WORDLIST"))()
    splitToTable()
    
    -- Initiliaze scenes and switch to the title scene
    Scene = SceneManager(2)
    
    Scene:addScene("Game", Anagram)
    Scene:addScene("Title", Title)
    Scene:addScene("Help", Help)
    Scene:addScene("Store", Shop)
    Scene:addScene("Welcome", Welcome)

    if readLocalData("seenwelcome") == nil then
        Scene.currentScene = "Welcome"
        saveLocalData("seenwelcome", true)
    else
        Scene.currentScene = "Title"
    end
    Scene.scenes[Scene.currentScene]:onEnter()
end

function splitToTable()
    WordList = {}
    for i = 0, 22 do
        WordList[i] = {}
    end
    for w in WordStr:gmatch("%a*\n") do
        local i = w:len() - 1
        local word = w:sub(1, i)
        
        local block = false
        for _, bad in pairs(blockedWords) do
            if string.lower(word) == bad then
                -- print("bad!", word)
                block = true
            end
        end
        
        if not block then
            table.insert(WordList[word:len()], word)
        end
    end
end

function makeButtonImgs(img, s, col)
    -- Makes two buttons, one pressed, one not
    local off = image(s, s) setContext(off)
    stroke(col) fill(255) strokeWidth(1) ellipse(s/2, s/2, s)
    sprite(img, s/2, s/2) setContext()
    
    local on = image(s, s) setContext(on)
    fill(col) ellipse(s/2, s/2, s)
    sprite(img, s/2, s/2) setContext()
    
    return off, on
end

function draw()
    background(255, 255, 255, 255)

    Scene:draw()
end

function touched(t)
    Scene:touched(t)
end

table.count = function(tbl)
    local count = 0
    for foo, bar in pairs(tbl) do
        count = count + 1
    end

    return count
end

-- Hack strokeWidth

_strokeWidth = strokeWidth
strokeWidth = function()
    if HEIGHT < 500 then
        _strokeWidth(1)
    else
        _strokeWidth(2)
    end
end



