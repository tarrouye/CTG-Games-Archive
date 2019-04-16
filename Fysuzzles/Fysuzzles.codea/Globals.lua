themeColors = { 
    { box = color(0, 100, 255, 190), glow = vec4(0, 2, 2, 2), over = color(255) },
    { box = color(127, 0, 255, 190), glow = vec4(1, 0, 2, 2), over = color(255) },
    { box = color(31, 127, 31, 190), glow = vec4(0, 2, 0, 2), over = color(255) },
    { box = color(127, 31, 31, 190), glow = vec4(2, 0, 0, 2), over = color(0) },
    { box = color(255, 255, 0, 190), glow = vec4(2, 2, 0, 2), over = color(0) },
    { box = color(255, 127, 0, 190), glow = vec4(2, 1, 0, 2), over = color(0) },
    { box = color(255, 255, 255, 190), glow = vec4(2, 2, 2, 2), over = color(0) },
    { box = color(0, 0, 0, 190), glow = vec4(0, 0, 0, 2), over = color(255) }
}

STANDARDFONT = "Futura-CondensedExtraBold"

backCol = color(255)
topCol = color(0, 134, 255, 255)
-- backCol = color(0)

function wScale(num)
    return WIDTH/(1024/num)
end

function hScale(num)
    return HEIGHT/(768/num)
end

function owScale(num)
    if num == 0 then
        return num
    end
    
    local pw = WIDTH / num

    return "WIDTH / " .. pw
end

function ohScale(num)
    if num == 0 then
        return num
    end
    
    local ph = HEIGHT / num
    
    return "HEIGHT / " .. ph
end
    
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


local _physics_body = physics.body

function physics.body(...)
    local body = _physics_body(...)
    
    debugDraw:addBody(body)
    
    return body
end    


local update,noop = tween.update,function() end

tween.pauseAll = function()
    tween.update = noop
end

tween.resumeAll = function()
    tween.update = update
end

local _sound = sound

sound = function(...)
    if soundAllowed then
        _sound(...)
    end
end

toggleSound = function() 
    soundAllowed = not soundAllowed 
end

local _mt = getmetatable(music)
local _music = _mt.__call

_mt.__call = function(...)
    _music(...)
    
    if not musicAllowed then
        music.muted = true
        music.paused = true
    end
end

toggleMusic = function() 
    music.muted = musicAllowed
    music.paused = music.muted
    
    musicAllowed = not musicAllowed
end


_font = font

font = function()
    _font(STANDARDFONT)
end





function tableToString (name, value, saved)
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


mt = getmetatable(color())

mt.__add = function (c1, c2)
    return color(c1.r + c2.r, c1.g + c2.g, c1.b + c2.b, c1.a + c2.a)
end

mt.__sub = function (c1, c2)
    return color(c1.r - c2.r, c1.g - c2.g, c1.b - c2.b, c1.a - c2.a)
end

mt.__mul = function (c, s)
    if type(c) ~= "userdata" then
        c, s = s, c
    end
    return color(c.r * s, c.g * s, c.b * s, c.a * s)
end

mt.__div = function (c, s)
    if type(c) ~= "userdata" then
        c, s = s, c
    end
    return color(c.r / s, c.g / s, c.b / s, c.a / s)
end
