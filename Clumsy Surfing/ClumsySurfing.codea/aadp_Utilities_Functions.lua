-- Generate random color
function newRandomColour()
    return color(math.random(255), math.random(255), math.random(255))
end

-- Pick random color
function randomColour()
    return colours[math.random(#colours)]
end

-- Return multiple random colors with no sames
function getRandomColours(n)
    local tb = {}
    for i = 1, n do
        tb[i] = randomColour()
        for b = 1, i - 1 do
            --print(tb[b])
            local c = tb[b]
            while (tb[i].r == c.r and tb[i].g == c.g and tb[i].b == c.b) do
                tb[i] = randomColour()
            end
        end
    end
    
    return tb
end

-- Return multiple random colors with no sames
function getNewRandomColours(n)
    local tb = {}
    for i = 1, n do
        tb[i] = newRandomColour()
        for b = 1, i - 1 do
            --print(tb[b])
            local c = tb[b]
            while (tb[i].r == c.r and tb[i].g == c.g and tb[i].b == c.b) do
                tb[i] = randomColour()
            end
        end
    end
    
    return tb
end

-- Locks a point to the nearest grid position
function lockToGrid(lpoint, gridSize)
    local closestDist = math.huge
    local closestInt = vec2(math.floor(gridSize.x + 0.5), math.floor(gridSize.y + 0.5))
    local off = gridSize - closestInt
    for c = off.x / 2, closestInt.x + off.x / 2 do
        local x = c * WIDTH / (gridSize.x)
        for r = off.y / 2, closestInt.y + off.y / 2 do
            local y = r * HEIGHT / (gridSize.y)
            
            local dist = lpoint:dist(vec2(x, y))
            if dist <= closestDist then
                closestDist = dist
                closest = vec2(x, y)
            end
        end
    end
    
    return closest
end

-- Check if line intersects a circle
function intersectsCircle(center, rad, lp1, lp2)
    local d = lp1 - lp2
    local f = lp2 - center
    local r = rad
    
    local a = d:dot( d ) 
    local b = 2*f:dot( d ) 
    local c = f:dot( f ) - r*r 

    local discriminant = b*b-4*a*c
    if( discriminant < 0 ) then
        return false
    else
        discriminant = math.sqrt( discriminant )
        local t1 = (-b + discriminant)/(2*a)
        local t2 = (-b - discriminant)/(2*a)
    
        if( t1 >= 0 and t1 <= 1 ) or ( t2 >= 0 and t2 <= 1 )  then
            return true
        else
            return false
        end
    end
end


-- Greatest common demoniator
function greatestCommonDenominator(a,b)
    a,b = math.floor(a + 0.5), math.floor(b + 0.5)
	if b ~= 0 then
		return greatestCommonDenominator(b, a % b)
	else
		return math.abs(a)
	end
end


-- Converts table to string then stores in local data
function saveLocalTable(name, tbl)
    saveLocalData(name, tableToString(name, tbl))
end
-- Converts table to string then stores in project data
function saveProjectTable(name, tbl)
    saveProjectData(name, tableToString(name, tbl))
end
-- Converts table to string then stored as text file
function saveTextTable(name, tbl)
    saveText("Project:"..name, tableToString(name, tbl))
end

-- Reads back table stored in local data
function readLocalTable(name)
    load(readLocalData(name, name .. " = {}"))()
end
-- Reads back table stored in project data
function readProjectTable(name)
    load(readProjectData(name, name .. " = {}"))()
end
-- Reads back table stored in text file
function readTextTable(name)
    load(readText("Project:"..name) or name .. " = {}")()
end

-- Turns a table into a string for data storage
function tableToString(name, value, saved)
    local function basicSerialize (o)
        if typeOf(o) == "number" then
            return tostring(o)
        elseif typeOf(o) == "boolean" then
            return tostring(o)
        else -- assume it is a string
            return string.format("%q", o)
        end
    end
    saved = saved or {}
    local returnStr = name.." = " 
    if typeOf(value) == "number" or typeOf(value) == "string" or typeOf(value) == "boolean" then
        returnStr = returnStr .. basicSerialize(value).."\n"
    elseif typeOf(value) == "vec2" then
        returnStr = returnStr .. "vec2(" .. value.x .. ", " .. value.y .. ")\n"
    elseif typeOf(value) == "table" then
        if saved[value] then
            returnStr = returnStr .. saved[value].."\n"
        else
            saved[value] = name
            returnStr = returnStr.."{}\n"
            for k,v in pairs(value) do 
                local fieldname = string.format("%s[%s]", name, basicSerialize(k))
                returnStr = returnStr .. tableToString(fieldname, v, saved)
            end
        end
    else
        error("Cannot save a " .. typeOf(value))
    end
    return returnStr
end

-- Extended type function
function typeOf(x)
    if x == nil then 
        return 'nil' 
    end
    if type(x) == 'table' and x.is_a then 
        return('class') 
    end
    
    local txt
    
    if typeTable == nil then
        typeTable = {
            [getmetatable(vec2()).__index ] = 'vec2', 
            [getmetatable(vec3()).__index ] = 'vec3',
            [getmetatable(color()).__index ] = 'color', 
            [getmetatable(image(1,1)).__index ] = 'image', 
            [getmetatable(matrix()).__index] = 'matrix', 
            [getmetatable(mesh()).__index ] = 'mesh' ,
            [getmetatable(physics.body(CIRCLE, 1)).__index] = 'physics body',
        }
    end
    
    local i = getmetatable(x)
    if i then 
        txt = typeTable[i.__index] 
    end    
    if txt then 
        return txt 
    end
    
    txt = type(x)
    return txt
end

-- Formats seconds into Hours:Minutes:Seconds Format (00:00)
function formatTime(seconds)
    local fHours = string.format("%02.f", math.floor(seconds / 3600))
    local fMins = string.format("%02.f", math.floor((seconds - (fHours * 3600)) / 60))
    local fSecs = string.format("%02.f", math.floor(seconds - (fHours * 3600) - (fMins * 60)))
    local formattedTime = fHours .. ":" .. fMins .. ":" .. fSecs
    
    return formattedTime
end

-- Same as a % b, except that if a is a multiple b it returns b not 0
function specialModulo(a, b)
    local mod = b * (a/b - math.floor(a/b))
    if mod == 0 then
        mod = b
    end
    
    return mod
end

function pairsByKeys (t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

-- Returns the sign of a number (-1 for negative or 1 for positive)
math.signNoZero = function(v)
    if v < 0 then
        return -1
    else
        return 1
    end
end

-- Same as math.signNoZero but returns 0 if number is 0
math.sign = function(v)
    if v < 0 then
        return -1
    elseif v > 0 then
        return 1
    else
        return 0
    end
end

-- Rounds a number
function math.round(num, idp)
    return tonumber(string.format("%." .. (idp or 0) .. "f", num))
end

--[[ New math.random function, can take non-integer numbers
_random = math.random
function math.random(a, b)
    if not b then
        return _random(a)
    else
        return _random(math.floor(a), math.ceil(b))
    end
end]]

-- New clip function, affected by translate() and scale()
_clip = clip
function clip(x, y, w, h)
    if x ~= nil then
        local m = modelMatrix()
        x = x * m[1] + m[13]
        y = y * m[6] + m[14]
        w = w * m[1]
        h = h * m[6]
        _clip(math.floor(x), math.floor(y), math.floor(w), math.floor(h))
    else
        _clip()
    end
end

function subclasses(c)
    local t = {}
    for k, v in pairs(_G) do
        if type(v) == "table" and v._base and v._base == c then
            t[k] = v
        end
    end
    return t
end

-- Sound toggling
function toggleSounds()
    soundAllowed = not soundAllowed
    
    saveLocalData("soundAllowed", soundAllowed)
end

function toggleMusic()
    if musicAllowed then
        music.paused = true
        musicAllowed = false
    else
        music.paused = false
        musicAllowed = true
    end
    
    saveLocalData("musicAllowed", musicAllowed)
end

local mmt = getmetatable(music)
_music = mmt.__call
mmt.__call = function(...) _music(...) if musicAllowed == false then music.paused = true end end

_sound = sound
sound = function(...) if soundAllowed == true or soundAllowed == nil then return _sound(...) end end


-- Pause and resume all tweens
local update,noop = tween.update,function() end
tween.pauseAll = function()
    tween.update = noop
end
tween.resumeAll = function()
    tween.update = update
end

