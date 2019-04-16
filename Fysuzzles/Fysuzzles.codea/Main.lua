-- Fysuzzles

displayMode(FULLSCREEN_NO_BUTTONS)
supportedOrientations(LANDSCAPE_ANY)

function setup()
    saveProjectInfo("Description", "Fun, Floating, Physics-based Puzzles. Fysuzzles.")
    
    -- parameter.boolean("editorLocked", true, function() displayMode(FULLSCREEN_NO_BUTTONS) end)
    
    -- saveLocalData("CompletedLevels", nil)
    
    completedLevels = {}
    if readLocalData("CompletedLevels") ~= nil then
        loadstring(readLocalData("CompletedLevels"))()
    end
    
    selectedTheme = readLocalData("SelectedTheme") or 1

    if readLocalData("LevelData") == nil then
        displayMode(STANDARD) print("nilly willy")
        saveLocalData("LevelData", readProjectTab("LevelData"))
    else
        saveProjectTab("LevelData", readLocalData("LevelData"))
    end
    
    -- statusBar = StatusBar()
    
    local s = readLocalData("SoundAllowed")
    if s == nil then s = true end
    local m = readLocalData("MusicAllowed")
    if m == nil then m = true end
    soundAllowed = s
    musicAllowed = m
    
    music.muted = not musicAllowed
    music.paused = music.muted

    SManager = SceneManager(2)
    SManager:addScene("Intro", IntroScreen)
    SManager.currentScene = "Intro"
    
    -- Spread out loading to avoid a crash
    tween.delay(0.1, function()
        loadstring(readLocalData("LevelData"))()
    
        parameter.boolean("showPhysicsBodies", false)
        debugDraw = PhysicsDebugDraw()
    
        -- Initiate scenes
        tween.delay(0.5, function()
            SManager:addScene("Start", StartScreen)
        end)
        tween.delay(1.0, function()
            SManager:addScene("Modes", ModeManager)
        end)
        tween.delay(1.5, function()
            SManager:addScene("Edit", LevelEditor)
        end)
        tween.delay(2.0, function()
            SManager:addScene("Credits", Credits)
        end)
        tween.delay(2.5, function()
            SManager:addScene("Game", Game)
        end)
        tween.delay(3.0, function()
            SManager.scenes["Intro"]:loaded()
        end)
    end)
end

function draw()
    background(backCol)
    
    SManager:draw()
    
    if statusBar then
        statusBar:draw()
    else
        local w,h = textSize("REFPS: " .. math.floor(1/DeltaTime))
        fontSize(hScale(25))
        text("REFPS: " .. math.floor(1/DeltaTime), w/2, h/2)
    end
    
    if showPhysicsBodies then
        debugDraw:draw()
    end
end

function collide(contact)
    SManager:collide(contact)
end

function touched(touch)
    SManager:touched(touch)
    
    -- statusBar:touched(touch)
end


