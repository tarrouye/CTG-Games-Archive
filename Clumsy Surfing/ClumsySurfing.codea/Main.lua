
-- Ragdoll Physics

displayMode(FULLSCREEN_NO_BUTTONS)
function setup()
    MIN_DIMENSION = math.min(WIDTH, HEIGHT)
    MAX_DIMENSION = math.max(WIDTH, HEIGHT)
    SCALAR = (MAX_DIMENSION / 1024)
    
    font("Futura-CondensedExtraBold")

    gamecenter.enabled()
    checkMusicToggle()
    checkSoundsToggle()

    --parameter.watch("1/DeltaTime")
    parameter.boolean("USE_TEXTURE", false)

    physics.continuous = true

    globalTouches = {}

    floor = physics.body(EDGE, vec2(0,0), vec2(WIDTH,0))
    floor.mask = {1}
    floor.categories = {2}
    walls = physics.body(CHAIN,false,vec2(0,0),vec2(0,HEIGHT),vec2(WIDTH,HEIGHT),vec2(WIDTH,0))
        
    JOYSTICKS = All_Joysticks()
    DebugDraw = PhysicsDebugDraw()
    DebugDraw.drawJoints = false
    DebugDraw.drawContacts = false

    
     -- Initialise Scenes and Scene Manager
    Scene = SceneManager(1)
    Scene:addScene("title", Menu, "Game Music One:Venus")
    Scene:addScene("game", GameManager)
    Scene:start("title")
end

function draw()
    background(146, 183, 200, 255)

    Scene:draw()
end

function touched(t)
    Scene:touched(t)
end

-- toggles music and saves setting
function toggleMusic()
    music.muted = not music.muted
    saveLocalData("musicMuted", music.muted)
end

function checkMusicToggle()
    music.muted = readLocalData("musicMuted")
end

function toggleSounds()
    sound_muted = not sound_muted
    saveLocalData("soundMuted", sound_muted)
end

function checkSoundsToggle()
    sound_muted = readLocalData("soundMuted") or false
end


-- override sound for our own purposes
local _sound = sound
sound = function(...)
    if not sound_muted then
        _sound(...)
    end
end




function weirdReverseModulo(a, b)
    local mod = specialModulo(a, b)
    if (math.ceil(a/b))%2 == 0 then
        return mod - b
    else
        return mod
    end
end

function createCircle(x,y,r)
    local circle = physics.body(CIRCLE, r)
    circle.interpolate = true
    circle.x = x
    circle.y = y
    circle.restitution = 0
    circle.friction = 0.1
    circle.density = 1
    circle.sleepingAllowed = false

    return circle
end
