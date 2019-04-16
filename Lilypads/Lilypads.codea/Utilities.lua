-- Converts table to string then stores in local data
function saveLocalTable(name, tbl)
    saveLocalData(name, tableToString(name, tbl))
end
-- Converts table to string then stores in project data
function saveProjectTable(name, tbl)
    saveProjectData(name, tableToString(name, tbl))
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

-- Formats seconds into Minutes:Seconds Format (00:00)
function formatTime(seconds)
    local fMins = string.format("%02.f", math.floor(seconds / 60))
    local fSecs = string.format("%02.f", math.floor(seconds - (fMins * 60)))
    local formattedTime = fMins .. ":" .. fSecs
    
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

-- Returns the sign of a number (-1 for negative or 1 for positive)
math.sign = function(v)
    if v < 0 then
        return -1
    else
        return 1
    end
end

-- Same as math.sign but returns 0 if number is 0
math.signOrZero = function(v)
    if v < 0 then
        return -1
    elseif v > 0 then
        return 1
    else
        return 0
    end
end
