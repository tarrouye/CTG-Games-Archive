mp = (180/math.pi)
function angleOfPoint( pt )
   local ang = math.atan2(pt.y,pt.x)*(180/math.pi)
    if ang < 0 then ang = 360+ang elseif ang > 360 then ang = 0+(ang-360) end
    return ang 
end

GlowSquare = class()

function GlowSquare:init(ent,width)
    -- you can accept and set parameters here
    local width = wScale(width)
    self.m = mesh()
    self.r = {}
    local pos1 = nil
    local pos2 = nil
    
    for i=1,4 do
        if i == 1 then
            pos1 = ent.points[i] 
            pos2 = ent.points[4] 
        else
            pos1 = ent.points[i] 
            pos2 = ent.points[i-1] 
        end
        local d = (pos1-pos2)
    self.r[i] = self.m:addRect(pos1.x-d.x/2,pos1.y-d.y/2,d:len(),width*5,angleOfPoint(d)/mp)
    end
    self.m.shader = shader(shadr.vS,shadr.fS)
    self.m.shader.color = themeColors[selectedTheme].glow or vec4(0,2,2,2)
    self.m.shader.len = (ent.points[1]-ent.position):len()/45
    self.width = width
end

function GlowSquare:setPositions(ent)
    local pos1,pos2
    for i=1,4 do
        if i == 1 then
            pos1 = ent.points[i]:rotate(ent.angle/mp)
            pos2 = ent.points[4]:rotate(ent.angle/mp)
        else
            pos1 = ent.points[i]:rotate(ent.angle/mp) 
            pos2 = ent.points[i-1]:rotate(ent.angle/mp) 
        end
        local d = (pos1-pos2)
        self.m:setRect(self.r[i],ent.x+pos1.x-d.x/2,ent.y+pos1.y-d.y/2,d:len(),self.width*5,angleOfPoint(d)/mp)
    end
    self.m.shader.len = (ent.points[1]-ent.position):len()/45
end

function GlowSquare:draw()
    self.m.shader.time = ElapsedTime*2
    self.m:draw()
end

function GlowSquare:touched(touch)
    -- Codea does not automatically call this method
end

shadr = {vS = [[
uniform mat4 modelViewProjection;

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

varying lowp vec4 vColor;
varying highp vec2 vTexCoord;

void main()
{
    //Pass the mesh color to the fragment shader
    vColor = color;
    vTexCoord = texCoord;

    //Multiply the vertex position by our combined transform
    gl_Position = modelViewProjection * position;
}
]],
fS = [[
varying highp vec2 vTexCoord;

uniform lowp vec4 color;
uniform highp float time;
uniform highp float len;

void main()
{
    highp float mp = sin(time*4.0+(25.0*vTexCoord.x)*0.03*len)*
    sin(time*10.0+25.0*vTexCoord.x*0.055*len)*1.9+3.0;
    mediump vec2 vTexCoordn = 1.0-2.0*vec2(vTexCoord.x,vTexCoord.y);
    lowp float dist = sqrt(vTexCoordn.x*vTexCoordn.x+vTexCoordn.y*vTexCoordn.y);
    vTexCoordn.x = 0.0;
    //Premult
    gl_FragColor = color*(1.4-length(vTexCoordn)*0.7*mp-dist);
}
]]}
    -- Codea does not automatically call this method




