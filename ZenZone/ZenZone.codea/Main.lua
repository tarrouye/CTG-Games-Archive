displayMode(FULLSCREEN_NO_BUTTONS)
function setup()
    time_factor = 0
    speed_factor = 1
    pos = vec2(WIDTH / 2, HEIGHT / 2)
    
    stoperino = false
    
    full_size = math.min(WIDTH, HEIGHT) * 0.75
    max_size = full_size * 0.9
    min_size = full_size * 0.75
    width = full_size
    height = min_size
    --tween(5, _G, { width = min_size }, { easing = tween.easing.linear, loop = tween.loop.pingpong })
    pulserino = tween(3, _G, { height = max_size }, { easing = tween.easing.linear, loop = tween.loop.pingpong })
    
    original = {
        color(255, 81, 0, 255),
        color(0, 153, 255, 255),
        color(215, 0, 255, 255),
        color(0, 255, 64, 255),
        color(0, 255, 205, 255),
        color(107, 0, 255, 255),
    }
    
    google = {
        color(255, 0, 0, 255),
        color(255, 229, 0, 255),
        color(12, 213, 46, 255),
        color(0, 151, 255, 255)
    }
    
    blues = {
        color(101, 0, 255, 255),
        color(26, 0, 255, 255),
        color(0, 58, 255, 255),
        color(0, 124, 255, 255),
        color(0, 178, 255, 255),
        color(0, 206, 255, 255),
        color(0, 235, 255, 255)
    }
    
    colors = original
    
    music("Game Music One:Nothingness", true)
end

function draw()
    background(0, 0, 0, 255)
    
    pushMatrix()
    pushStyle()
    translate(pos.x, pos.y)
    blendMode(ADDITIVE)
    for i = 1, #colors do
        fellipse(0, 0, i * time_factor, colors[i])
    end
    popMatrix()
    
    fill(0, 150, 255, 127 * (1 - speed_factor))
    rect(0, 0, WIDTH, HEIGHT)
    popStyle()
    
    --sprite("Project:jz", pos.x, pos.y, min_size * 0.75)
    
    time_factor = time_factor + 0.85 * speed_factor
    
    music.volume = speed_factor
    
    if stoperino then
        speed_factor = math.max(0.01, speed_factor * 0.85)
    else
        speed_factor = math.min(1, speed_factor + ((1 - speed_factor) * 0.025))
    end
    
    time = os.date("*t")
    time_stamp = string.format("%02d:%02d", time.hour, time.min)
            
    fill(0, 0, 0, 255 * ((1 - speed_factor * 3) + 0.2)) fontSize(25)
    text(time_stamp, pos.x, pos.y)
end

function fellipse(x, y, r, c)
    pushMatrix()
    pushStyle()
    
    rotate(-r)
    
    fill(c)
    ellipse(x, y, width, height)
    
    popStyle()
    popMatrix()
end

function touched(t)
    if t.state == BEGAN and not stoperino then 
        stoperino = true
        tween.stop(pulserino)
        sound("Game Sounds One:Menu Back")
    elseif t.state == ENDED and stoperino then
        stoperino = false
        tween.play(pulserino)
        sound("Game Sounds One:Menu Back")
    end
end
