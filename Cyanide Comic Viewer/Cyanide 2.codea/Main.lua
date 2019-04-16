-- Cyanide 2
-- Copyright 2014 Théo Arrouye

displayMode(FULLSCREEN)
--supportedOrientations(PORTRAIT)
function setup()
    comics = {}
    errors = readProjectData("errors") or {}
    viewing = 1
    max = 10
    
    --loadComic("latest", 1)
    loadInitial(3336)
    
    zoomer = Zoom()
    swiper = SwipeDetector()
end

function loadInitial(id)
    for i = 0, max - 1, 1 do
        comics[i + 1] = createComic(i + id, nil)
        loadComic(i + id, i + 1)
    end
end

function createComic(num, img)
    return { id = num, img = img }
end

function shiftUp()
    local n = 2
    if #errors > 0 then
        if (errors[#errors].into ~= nil) then
            n = errors[#errors].into
            errors[#errors].into = nil
        end
    end
    for i = max, 2, -1 do
        if (comics[i-1] ~= nil) then
            comics[i] = comics[i-1]
        end
    end
end

function shiftDown()
    local n = max - 1
    if #errors > 0 then
        if (errors[#errors].into ~= nil) then
            n = errors[#errors].into
            errors[#errors].into = nil
        end
    end
    for i = 1, n do
        if (comics[i + 1] ~= nil) then
            comics[i] = comics[i + 1]
        end
    end
end

function next()
    local n = viewing + 1
    if (n > max) then
        local l = noError(comics[max].id + 1, 1)
        loadComic(l, max)
        shiftDown()
    end
    viewing = math.min(n, max)
end

function prev()
    local n = viewing - 1
    if (n < 1) then
        local l = noError(comics[1].id - 1, -1)
        print(l)
        loadComic(l, 1)
        shiftUp()
    end
    viewing = math.max(n, 1)
end

function noError(check, dir)
    if #errors == 0 then
        return check
    end
    
    for i = 1, #errors do
        print("e" .. errors[i].id .. " " .. check)
        if errors[i].id == check then
            print("no " .. check)
            return noError(check + dir, dir)
        end
    end
    
    print("yes " .. check)
    return check
end

function loadComic(id, into)
    print("Loading comic: id - " .. id .. " into " .. into)
    http.request( "http://explosm.net/comics/"..id, function(d, s, h) gotPage(d, s, h, id, into) end, function() failedPage(id, into) end)
end

function failedPage(id, into) 
    print("err : " .. id) 
    if (into == 1) then
        prev()
    else
        next()
    end 
    errors[#errors + 1] = { id = id, into = into } 
    --saveProjectData("errors", errors)
end

function gotPage( data, status, headers, id, into)
    --print( "Response Status: " .. status )
    
    -- Check if the status is OK (200)
    if status == 200 then
        print( "Got page data OK" )
        
        local i,j = string.find(data, 'files.explosm.net/comics/(.-)"')
    url = "http://" .. string.sub(data, i, j-1)
        
        http.request(url, function(d, s, h) gotComic(d, s, h, id, into) end)
    else
        print( "Error loading page" )
    end
end

function gotComic(theComic, status, headers, id, into)
    --print( "Response Status: " .. status )
    
    -- Check if the status is OK (200)
    if status == 200 then
        print( "Got the comic. ".. " into " .. into)
    
        comics[into] = createComic(id, theComic)
    else
        print( "Error downloading comic" )
    end
end

-- This function gets called once every frame
function draw()
    -- This sets a dark background color 
    background(255, 255, 255, 255)
    
    pushMatrix()
    zoomer:draw()
    
    fill(0)
    fontSize(WIDTH / 5)
    textAlign(CENTER)
    --text(viewing, WIDTH /2, 20)
    
    if #comics > 0 then
        if (comics[viewing] == nil or comics[viewing].img == nil) then
            fontSize(WIDTH /20)
            text("Loading..\nThis comic may be dead.\nTry swiping to another.", WIDTH/2, HEIGHT/2)
        else
            img = comics[viewing].img
            scaleFactor = math.min(WIDTH / img.width, HEIGHT / img.height)
            
            pushMatrix()
            translate(WIDTH/2, HEIGHT/2)
            scale(scaleFactor)
            sprite(img, 0, 0)
            popMatrix()
        end
    end
    
    popMatrix()
end

function touched(t)
    zoomer:touched(t)
    swiper:touched(t)
    
    if zoomer.zoom == 1 then
    if swiper.swipe == vec2(-1, 0) then
        next()
    elseif swiper.swipe == vec2(1, 0) then
        prev()
    end
    end
end
