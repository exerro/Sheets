



















































event = {
mouse_down = 0;
mouse_up = 1;
mouse_click = 2;
mouse_hold = 3;
mouse_drag = 4;
mouse_scroll = 5;
key_down = 6;
key_up = 7;
text = 8;
voice = 9;
timer = 10;
paste = 11;
mouse_ping = 12;
}

alignment = {
left = 0;
centre = 1;
center = 1;
right = 2;
top = 3;
bottom = 4;
}


























class = {}
local classobj = setmetatable( {}, { __index = class } )
local names = {}
local last_created

local supportedMetaMethods = {
__add = true;
__sub = true;
__mul = true;
__div = true;
__mod = true;
__pow = true;
__unm = true;
__len = true;
__eq = true;
__lt = true;
__lte = true;
__tostring = true;
__concat = true;
}

local function _tostring( self )
return "[Class] " .. self:type()
end
local function _concat( a, b )
return tostring( a ) .. tostring( b )
end

local function newSuper( object, super )

local superProxy = {}

if super.super then
superProxy.super = newSuper( object, super.super )
end

setmetatable( superProxy, { __index = function( t, k )

if type( super[k] ) == "function" then
return function( self, ... )

if self == superProxy then
self = object
end
object.super = superProxy.super
local v = { super[k]( self, ... ) }
object.super = superProxy
return unpack( v )

end
else
return super[k]
end

end, __newindex = super, __tostring = function( self )
return "[Super] " .. tostring( super ) .. " of " .. tostring( object )
end } )

return superProxy

end

function classobj:new( ... )

local mt = { __index = self, __INSTANCE = true }
local instance = setmetatable( { class = self, meta = mt }, mt )

if self.super then
instance.super = newSuper( instance, self.super )
end

for k, v in pairs( self.meta ) do
if supportedMetaMethods[k] then
mt[k] = v
end
end

if mt.__tostring == _tostring then
function mt:__tostring()
return self:tostring()
end
end

function instance:type()
return self.class:type()
end

function instance:typeOf( class )
return self.class:typeOf( class )
end

if not self.tostring then
function instance:tostring()
return "[Instance] " .. self:type()
end
end

local ob = self
while ob do
if ob[ob.meta.__type] then
ob[ob.meta.__type]( instance, ... )
break
end
ob = ob.super
end

return instance

end

function classobj:extends( super )
self.super = super
self.meta.__index = super
end

function classobj:type()
return tostring( self.meta.__type )
end

function classobj:typeOf( super )
return super == self or ( self.super and self.super:typeOf( super ) ) or false
end

function classobj:implement( t )
if type( t ) ~= "table" then
return error( "cannot implement non-table" )
end
for k, v in pairs( t ) do
self[k] = v
end
return self
end

function classobj:implements( t )
if type( t ) ~= "table" then
return error( "cannot compare non-table" )
end
for k, v in pairs( t ) do
if type( self[k] ) ~= type( v ) then
return false
end
end
return true
end

function class:new( name )

if type( name or self ) ~= "string" then
return error( "expected string class name, got " .. type( name or self ) )
end

local mt = { __index = classobj, __CLASS = true, __tostring = _tostring, __concat = _concat, __call = classobj.new, __type = name or self }
local obj = setmetatable( { meta = mt }, mt )

names[name] = obj
last_created = obj

_ENV[name] = obj

return function( t )
if not last_created then
return error "no class to define"
end

for k, v in pairs( t ) do
last_created[k] = v
end
last_created = nil
end

end

function class.type( object )
local _type = type( object )

if _type == "table" then
pcall( function()
local mt = getmetatable( object )
_type = ( ( mt.__CLASS or mt.__INSTANCE ) and object:type() ) or _type
end )
end

return _type
end

function class.typeOf( object, class )
if type( object ) == "table" then
local ok, v = pcall( function() return getmetatable( object ).__CLASS or getmetatable( object ).__INSTANCE or error() end )
return ok and object:typeOf( class )
end

return false
end

function class.isClass( object )
return pcall( function() if not getmetatable( object ).__CLASS then error() end end ), nil
end

function class.isInstance( object )
return pcall( function() if not getmetatable( object ).__INSTANCE then error() end end ), nil
end

setmetatable( class, {
__call = class.new;
} )

function extends( name )

if not last_created then
return error "no class to extend"
end

if not names[name] then
return error( "no such class '" .. tostring( name ) .. "'" )
end

last_created:extends( names[name] )

return function( t )
if not last_created then
return error "no class to define"
end

for k, v in pairs( t ) do
last_created[k] = v
end
last_created = nil
end

end

function implements( name )

if not last_created then
return error "no class to modify"
end

if type( name ) == "string" then
if not names[name] then
return error( "no such class '" .. tostring( name ) .. "'" )
end
last_created:implement( names[name] )
elseif type( name ) == "table" then
last_created:implement( name )
else
return error( "Cannot implement type (" .. class.type( name ) .. ")" )
end

return function( t )
if not last_created then
return error "no class to define"
end

for k, v in pairs( t ) do
last_created[k] = v
end
last_created = nil
end

end





















colour = {
transparent = 0;
white = 1;
orange = 2;
magenta = 4;
lightBlue = 8;
yellow = 16;
lime = 32;
pink = 64;
grey = 128;
lightGrey = 256;
cyan = 512;
purple = 1024;
blue = 2048;
brown = 4096;
green = 8192;
red = 16384;
black = 32768;
}



























area = {
box = 0;
circle = 1;
line = 2;
vline = 3;
hline = 4;
fill = 5;
point = 6;
ccircle = 7;
}











local shader_darken_lookup = {
[1] = 256;
[2] = 4096;
[4] = 1024;
[8] = 512;
[16] = 2;
[32] = 8192;
[64] = 4;
[128] = 32768;
[256] = 128;
[512] = 2048;
[1024] = 128;
[2048] = 128;
[4096] = 32768;
[8192] = 128;
[16384] = 4096;
[32768] = 32768;
}
local shader_lighten_lookup = {
[1] = 1;
[2] = 16;
[4] = 64;
[8] = 1;
[16] = 1;
[32] = 1;
[64] = 1;
[128] = 256;
[256] = 1;
[512] = 8;
[1024] = 4;
[2048] = 512;
[4096] = 16384;
[8192] = 32;
[16384] = 2;
[32768] = 128;
}
local shader_greyscale_lookup = {
[1] = 1;
[2] = 256;
[4] = 256;
[8] = 256;
[16] = 1;
[32] = 256;
[64] = 1;
[128] = 128;
[256] = 256;
[512] = 128;
[1024] = 128;
[2048] = 128;
[4096] = 32768;
[8192] = 128;
[16384] = 128;
[32768] = 32768;
}
local shader_inverse_lookup = {
[1] = 32768;
[2] = 2048;
[4] = 8192;
[8] = 4096;
[16] = 2048;
[32] = 1024;
[64] = 8192;
[128] = 256;
[256] = 128;
[512] = 16384;
[1024] = 8192;
[2048] = 16;
[4096] = 8;
[8192] = 1024;
[16384] = 512;
[32768] = 1;
}

shader = {}

function shader.darken( col, ... )
return shader_darken_lookup[col] or col, ...
end

function shader.lighten( col, ... )
return shader_lighten_lookup[col] or col, ...
end

function shader.greyscale( col, ... )
return shader_greyscale_lookup[col] or col, ...
end

function shader.inverse( col, ... )
return shader_inverse_lookup[col] or col, ...
end
local __f,__err=load("\
-- drawTo() not false compatible, uses drawPixels()\
\
\
\
\
\
\
\
\
\
local __f,__err=load(\"\\\
\\\
\\\
\\\
\\\
\\\
\\\
\\\
\\\
\\\
\\\
\\\
\\\
local function range( a, b, c, d )\\\
local x = a > c and a or c\\\
local y = ( a + b < c + d and a + b or c + d ) - x\\\
return x, y\\\
end\\\
\\\
local area__join, area__sub, area__intersect, area__tostring\\\
\\\
local function areamt( t )\\\
return setmetatable( t, { __add = area__join, __sub = area__sub, __mod = area__intersect, __tostring = area__tostring } )\\\
end\\\
\\\
function area__join( a, b )\\\
local i1, i2, c = 1, 1, 0\\\
local t = {}\\\
while a[i1] or b[i2] do\\\
if a[i1] and ( not b[i2] or a[i1] <= b[i2] ) then\\\
if t[c] ~= a[i1] then\\\
c = c + 1\\\
t[c] = a[i1]\\\
end\\\
i1 = i1 + 1\\\
elseif b[i2] and ( not a[i1] or a[i1] > b[i2] ) then\\\
if t[c] ~= b[i2] then\\\
c = c + 1\\\
t[c] = b[i2]\\\
end\\\
i2 = i2 + 1\\\
end\\\
end\\\
return areamt( t )\\\
end\\\
\\\
function area__sub( a, b )\\\
local i1, i2, c = 1, 1, 1\\\
local t = {}\\\
while a[i1] do\\\
while b[i2] and b[i2] < a[i1] do\\\
i2 = i2 + 1\\\
end\\\
if a[i1] ~= b[i2] then\\\
t[c] = a[i1]\\\
c = c + 1\\\
end\\\
i1 = i1 + 1\\\
end\\\
return areamt( t )\\\
end\\\
\\\
function area__intersect( a, b )\\\
local i1, i2, c = 1, 1, 1\\\
local t = {}\\\
while a[i1] do\\\
while b[i2] and b[i2] < a[i1] do\\\
i2 = i2 + 1\\\
end\\\
if a[i1] == b[i2] then\\\
t[c] = a[i1]\\\
c = c + 1\\\
end\\\
i1 = i1 + 1\\\
end\\\
return areamt( t )\\\
end\\\
\\\
function area__tostring( a )\\\
return \\\"Area of \\\" .. #a .. \\\" coordinates\\\"\\\
end\\\
\\\
local width, height = term.getSize()\\\
\\\
local area = {}\\\
\\\
function area.setDimensions( w, h )\\\
width, height = w, h\\\
end\\\
\\\
function area.new( t )\\\
return areamt( t )\\\
end\\\
\\\
function area.blank()\\\
return areamt {}\\\
end\\\
\\\
function area.fill()\\\
local t = {}\\\
for i = 1, width * height do\\\
t[i] = i\\\
end\\\
return areamt( t )\\\
end\\\
\\\
function area.point( x, y )\\\
if x >= 0 and x < width and y >= 0 and y < height then\\\
return areamt { y * width + x + 1 }\\\
end\\\
return areamt {}\\\
end\\\
\\\
function area.box( x, y, w, h )\\\
x, w = range( 0, width, x, w )\\\
y, h = range( 0, height, y, h )\\\
\\\
local pos = y * width + x\\\
local t, i = {}, 1\\\
\\\
for _ = 1, h do\\\
for x = 1, w do\\\
t[i] = pos + x\\\
i = i + 1\\\
end\\\
pos = pos + width\\\
end\\\
\\\
return areamt( t )\\\
end\\\
\\\
function area.circle( x, y, radius )\\\
local radius2 = radius * radius\\\
local t = {}\\\
local i = 1\\\
\\\
for yy = math.floor( y - radius ), math.ceil( y + radius ) do\\\
if yy > 0 and yy < height then\\\
local diff = y - yy\\\
local xdiff = ( radius2 - diff * diff ) ^ .5\\\
\\\
local ypos = yy * width + 1\\\
local sx = math.floor( x - xdiff + .5 )\\\
local a, b = range( 0, width, sx, math.ceil( x + xdiff - .5 ) - sx + 1 )\\\
for xx = a, a + b - 1 do\\\
t[i] = ypos + xx\\\
i = i + 1\\\
end\\\
end\\\
end\\\
\\\
return areamt( t )\\\
end\\\
\\\
function area.correct_circle( x, y, radius )\\\
local radius2 = radius * radius\\\
local t = {}\\\
local i = 1\\\
\\\
for yy = math.floor( y - radius ), math.ceil( y + radius ) do\\\
if yy > 0 and yy < height then\\\
local diff = y - yy\\\
local xdiff = ( radius2 - diff * diff ) ^ .5 * 1.5\\\
\\\
local ypos = yy * width + 1\\\
local sx = math.floor( x - xdiff + .5 )\\\
local a, b = range( 0, width, sx, math.ceil( x + xdiff - .5 ) - sx + 1 )\\\
for xx = a, a + b - 1 do\\\
t[i] = ypos + xx\\\
i = i + 1\\\
end\\\
end\\\
end\\\
\\\
return areamt( t )\\\
end\\\
\\\
function area.hLine( x, y, w )\\\
if y >= 0 and y < height then\\\
x, w = range( 0, width, x, w )\\\
local pos = y * width + x\\\
local t = {}\\\
for i = 1, w do\\\
t[i] = pos + i\\\
end\\\
return areamt( t )\\\
end\\\
return areamt {}\\\
end\\\
\\\
function area.vLine( x, y, h )\\\
if x >= 0 and x < width then\\\
y, h = range( 0, height, y, h )\\\
local pos = y * width + x + 1\\\
local t = {}\\\
for i = 1, h do\\\
t[i] = pos\\\
pos = pos + width\\\
end\\\
return areamt( t )\\\
end\\\
return areamt {}\\\
end\\\
\\\
function area.line( x1, y1, x2, y2 )\\\
if x1 > x2 then\\\
x1, x2 = x2, x1\\\
y1, y2 = y2, y1\\\
end\\\
\\\
local dx, dy = x2 - x1, y2 - y1\\\
\\\
if dx == 0 then\\\
if dy == 0 then\\\
return newPointArea( x1, y1, width, height )\\\
end\\\
return newVLineArea( x1, y1, dy, width, height )\\\
elseif dy == 0 then\\\
return newHLineArea( x1, y1, dx, width, height )\\\
end\\\
\\\
local points = {}\\\
\\\
if x1 >= 0 and x1 < width and y1 >= 0 and y1 < height then\\\
points[1] = math.floor( y1 + .5 ) * width + math.floor( x1 + .5 ) + 1\\\
if x2 >= 0 and x2 < width and y2 >= 0 and y2 < height then\\\
points[2] = math.floor( y2 + .5 ) * width + math.floor( x2 + .5 ) + 1\\\
end\\\
elseif x2 >= 0 and x2 < width and y2 >= 0 and y2 < height then\\\
points[1] = math.floor( y2 + .5 ) * width + math.floor( x2 + .5 ) + 1\\\
end\\\
\\\
local m = dy / dx\\\
local c = y1 - m * x1\\\
local step = math.min( 1 / math.abs( m ), 1 )\\\
\\\
local i = #points + 1\\\
\\\
for x = math.max( x1, 0 ), math.min( x2, width - 1 ), step do\\\
local y = math.floor( m * x + c + .5 )\\\
if y > 0 and y < height then\\\
points[i] = y * width + math.floor( x + .5 ) + 1\\\
i = i + 1\\\
end\\\
end\\\
\\\
return areamt( points )\\\
end\\\
\\\
return area\",\"area\",nil,_ENV)if not __f then error(__err,0)end local area=__f()\
\
--[[\
load\
loadString\
save\
saveString\
getTerm\
drawRoundRect\
drawRoundedRect\
fillRoundRect\
fillRoundedRect\
drawTriangle\
fillTriangle\
drawEllipse\
fillEllipse\
drawArc\
drawPie\
fillPie\
floodFill\
drawSurfacePart\
drawSurfaceScaled\
drawSurfaceRotated\
]]\
\
local function range( a, b, c, d )\
local x = a > c and a or c\
local y = ( a + b < c + d and a + b or c + d ) - x\
return x, y\
end\
\
local insert, remove = table.insert, table.remove\
local min, max = math.min, math.max\
local floor = math.floor\
\
class \"Canvas\" {\
width = 0;\
height = 0;\
\
colour = 1;\
\
pixels = {};\
}\
\
function Canvas:Canvas( width, height )\
width = width or 0\
height = height or 0\
\
\
if type( width ) ~= \"number\" then return error( \"element attribute #1 'width' not a number (\" .. class.type( width ) .. \")\", 2 ) end\
if type( height ) ~= \"number\" then return error( \"element attribute #2 'height' not a number (\" .. class.type( height ) .. \")\", 2 ) end\
\
\
self.width = width\
self.height = height\
self.pixels = {}\
\
local px = { 1, 1, \" \" }\
for i = 1, width * height do\
self.pixels[i] = px\
end\
end\
\
function Canvas:setWidth( width )\
\
if type( width ) ~= \"number\" then return error( \"expected number width, got \" .. class.type( width ) ) end\
\
width = math.floor( width )\
local height, pixels = self.height, self.pixels\
local sWidth = self.width\
local px = { self.colour, 1, \" \" }\
\
while sWidth < width do\
for i = 1, height do\
insert( pixels, ( sWidth + 1 ) * i, px )\
end\
sWidth = sWidth + 1\
end\
\
while sWidth > width do\
for i = height, 1, -1 do\
remove( pixels, sWidth * i )\
end\
sWidth = sWidth - 1\
end\
\
self.width = sWidth\
end\
\
function Canvas:setHeight( height )\
\
if type( height ) ~= \"number\" then return error( \"expected number height, got \" .. class.type( height ) ) end\
\
height = math.floor( height )\
local width, pixels = self.width, self.pixels\
local sHeight = self.height\
local px = { self.colour, 1, \" \" }\
\
while sHeight < height do\
for i = 1, width do\
pixels[#pixels + 1] = px\
end\
sHeight = sHeight + 1\
end\
\
while sHeight > height do\
for i = 1, width do\
pixels[#pixels] = nil\
end\
sHeight = sHeight - 1\
end\
\
self.height = sHeight\
end\
\
\
\
\
\
\
\
\
\
function Canvas:getPixel( x, y )\
local sWidth = self.width\
if x >= 0 and x < sWidth and y >= 0 and y < self.height then\
local px = self.pixels[y * sWidth + x + 1]\
return px[1], px[2], px[3]\
end\
end\
\
\
function Canvas:mapColour( coords, colour )\
\
if type( coords ) ~= \"table\" then return error( \"expected table coords, got \" .. class.type( coords ) ) end\
if type( colour ) ~= \"number\" then return error( \"expected number colour, got \" .. class.type( colour ) ) end\
\
local px = { colour, 1, \" \" }\
local pxls = self.pixels\
for i = 1, #coords do\
pxls[coords[i]] = px\
end\
end\
\
function Canvas:mapColours( coords, colours )\
\
if type( coords ) ~= \"table\" then return error( \"expected table coords, got \" .. class.type( coords ) ) end\
if type( colours ) ~= \"table\" then return error( \"expected table colours, got \" .. class.type( colours ) ) end\
\
local pxls = self.pixels\
local l = #colours\
for i = 1, #coords do\
pxls[coords[i]] = { colours[( i - 1 ) % l + 1], 1, \" \" }\
end\
end\
\
\
function Canvas:mapPixel( coords, pixel )\
\
if type( coords ) ~= \"table\" then return error( \"expected table coords, got \" .. class.type( coords ) ) end\
if type( pixel ) ~= \"table\" then return error( \"expected table pixel, got \" .. class.type( pixel ) ) end\
\
local pxls = self.pixels\
for i = 1, #coords do\
pxls[coords[i]] = pixel\
end\
end\
\
function Canvas:mapPixels( coords, pixels )\
\
if type( coords ) ~= \"table\" then return error( \"expected table coords, got \" .. class.type( coords ) ) end\
if type( pixels ) ~= \"table\" then return error( \"expected table pixels, got \" .. class.type( pixels ) ) end\
\
local pxls = self.pixels\
for i = 1, #coords do\
pxls[coords[i]] = pixels[i]\
end\
end\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
function Canvas:mapShader( coords, shader )\
\
if type( coords ) ~= \"table\" then return error( \"expected table coords, got \" .. class.type( coords ) ) end\
if type( shader ) ~= \"function\" then return error( \"expected function shader, got \" .. class.type( shader ) ) end\
\
local pxls = self.pixels\
local width = self.width\
local changed = {}\
\
for i = 1, #coords do\
local p = coords[i]\
local px = pxls[p]\
local rem = ( p - 1 ) % width\
local bc, tc, char = shader( px[1], px[2], px[3], rem, ( p - 1 - rem ) / width )\
\
changed[i] = ( bc or tc or char ) and { bc or px[1], tc or px[2], char or px[3] }\
end\
\
for i = 1, #coords do\
local c = changed[i]\
if c then\
pxls[coords[i]] = c\
end\
end\
end\
\
\
function Canvas:shift( area, x, y, blank )\
local sWidth = self.width\
if type( area ) == \"number\" then\
x, y, blank = area, x, y\
area = {}\
for i = 1, sWidth * self.height do\
area[i] = i\
end\
end\
local diff = y * sWidth + x\
local pixels = self.pixels\
for i = 1, #area do\
pixels[i] = pixels[i + diff] or blank\
end\
end\
\
function Canvas:drawColour( coords, colour )\
\
if type( coords ) ~= \"table\" then return error( \"expected table coords, got \" .. class.type( coords ) ) end\
if type( colour ) ~= \"number\" then return error( \"expected number colour, got \" .. class.type( colour ) ) end\
\
if colour == 0 then return end\
local px = { colour, 1, \" \" }\
local pixels = self.pixels\
for i = 1, #coords do\
pixels[coords[i]] = px\
end\
end\
\
function Canvas:drawColours( coords, colours )\
\
if type( coords ) ~= \"table\" then return error( \"expected table coords, got \" .. class.type( coords ) ) end\
if type( colours ) ~= \"table\" then return error( \"expected table colours, got \" .. class.type( colours ) ) end\
\
local l = #colours\
local pxls = self.pixels\
for i = 1, #coords do\
if colours[i] ~= 0 then\
pxls[coords[i]] = { colours[( i - 1 ) % l + 1], 1, \" \" }\
end\
end\
end\
\
\
function Canvas:drawPixel( coords, pixel )\
\
if type( coords ) ~= \"table\" then return error( \"expected table coords, got \" .. class.type( coords ) ) end\
if type( pixel ) ~= \"table\" then return error( \"expected table pixel, got \" .. class.type( pixel ) ) end\
\
local pxls = self.pixels\
if pixel[1] == 0 and ( pixel[2] == 0 or pixel[3] == \"\" ) then\
return -- not gonna draw anything\
elseif pixel[1] == 0 or pixel[2] == 0 or pixel[3] == \"\" then\
local bc, tc, char = pixel[1], pixel[2], pixel[3]\
for i = 1, #coords do\
local c = coords[i]\
local cpx, cbc, ctc, cchar\
if bc == 0 then\
cpx = pxls[c]\
cbc = cpx[1]\
end\
if tc == 0 or char == \"\" then\
cpx = cpx or pxls[c]\
ctc = cpx[2]\
cchar = cpx[3]\
end\
pxls[c] = { cbc or bc, ctc or tc, cchar or char }\
end\
else\
for i = 1, #coords do\
pxls[coords[i]] = pixel\
end\
end\
end\
\
function Canvas:drawPixels( coords, pixels )\
\
if type( coords ) ~= \"table\" then return error( \"expected table coords, got \" .. class.type( coords ) ) end\
if type( pixels ) ~= \"table\" then return error( \"expected table pixels, got \" .. class.type( pixels ) ) end\
\
local pxls = self.pixels\
for i = 1, #coords do\
local px = pixels[i]\
local bc, tc, char = px[1], px[2], px[3]\
local cpx\
if bc == 0 then\
cpx = pxls[coords[i]]\
bc = cpx[1]\
end\
if tc == 0 or char == \"\" then\
cpx = cpx or pxls[coords[i]]\
tc = cpx[2]\
char = cpx[3]\
end\
pxls[coords[i]] = { bc, tc, char }\
end\
end\
\
\
function Canvas:clear( colour )\
\
if colour and type( colour ) ~= \"number\" then return error( \"expected number colour, got \" .. class.type( colour ) ) end\
\
local px = { colour or self.colour, 1, \" \" }\
for i = 1, self.width * self.height do\
self.pixels[i] = px\
end\
end\
\
function Canvas:clone( _class )\
\
if _class and not class.isClass( _class ) then return error( \"expected Class class, got \" .. class.type( _class ) ) end\
\
local new = ( _class or self.class )( self.width, self.height )\
new.pixels = self.pixels\
return new\
end\
\
function Canvas:copy( _class )\
\
if _class and not class.isClass( _class ) then return error( \"expected Class class, got \" .. class.type( _class ) ) end\
\
local new = ( _class or self.class )( self.width, self.height )\
local b1, b2 = new.pixels, self.pixels\
for i = 1, #b2 do\
b1[i] = b2[i]\
end\
return new\
end\
\
function Canvas:drawTo( canvas, offsetX, offsetY )\
offsetX, offsetY = offsetX or 0, offsetY or 0\
\
if not class.typeOf( canvas, Canvas ) then return error( \"expected Canvas canvas, got \" .. class.type( canvas ) ) end\
if type( offsetX ) ~= \"number\" then return error( \"expected number offsetX, got \" .. class.type( offsetX ) ) end\
if type( offsetY ) ~= \"number\" then return error( \"expected number offsetY, got \" .. class.type( offsetY ) ) end\
\
local width, height = self.width, self.height\
local otherWidth, otherHeight = canvas.width, canvas.height\
\
local toDrawCoords = {}\
local toDrawPixels = {}\
local pc = 1\
local pixels = self.pixels\
\
local a, b = range( 0, otherWidth, offsetX, width )\
\
a = a - offsetX + 1\
b = a + b - 1\
\
for y = 0, height - 1 do\
local my = y + offsetY\
if my >= 0 and my < otherHeight then\
local coord = y * width\
local otherCoord = my * otherWidth + offsetX\
for i = a, b do\
if pixels[coord + i] then\
toDrawPixels[pc] = pixels[coord + i]\
toDrawCoords[pc] = otherCoord + i\
pc = pc + 1\
end\
end\
end\
end\
\
canvas:drawPixels( toDrawCoords, toDrawPixels )\
end\
\
function Canvas:getArea( mode, a, b, c, d )\
area.setDimensions( self.width, self.height )\
if mode == 5 then\
return area.fill()\
elseif mode == 0 then\
\
if type( a ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( a ) ) end\
if type( b ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( b ) ) end\
if type( c ) ~= \"number\" then return error( \"expected number width, got \" .. class.type( c ) ) end\
if type( d ) ~= \"number\" then return error( \"expected number height, got \" .. class.type( d ) ) end\
\
return area.box( a, b, c, d )\
elseif mode == 6 then\
\
if type( a ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( a ) ) end\
if type( b ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( b ) ) end\
\
return area.point( a, b )\
elseif mode == 4 then\
\
if type( a ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( a ) ) end\
if type( b ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( b ) ) end\
if type( c ) ~= \"number\" then return error( \"expected number width, got \" .. class.type( c ) ) end\
\
return area.hLine( a, b, c )\
elseif mode == 3 then\
\
if type( a ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( a ) ) end\
if type( b ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( b ) ) end\
if type( c ) ~= \"number\" then return error( \"expected number height, got \" .. class.type( c ) ) end\
\
return area.vLine( a, b, c )\
elseif mode == 2 then\
\
if type( a ) ~= \"number\" then return error( \"expected number x1, got \" .. class.type( a ) ) end\
if type( b ) ~= \"number\" then return error( \"expected number y1, got \" .. class.type( b ) ) end\
if type( c ) ~= \"number\" then return error( \"expected number x2, got \" .. class.type( c ) ) end\
if type( d ) ~= \"number\" then return error( \"expected number y2, got \" .. class.type( d ) ) end\
\
return area.line( a, b, c, d )\
elseif mode == 1 then\
\
if type( a ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( a ) ) end\
if type( b ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( b ) ) end\
if type( c ) ~= \"number\" then return error( \"expected number radius, got \" .. class.type( c ) ) end\
\
return area.circle( a, b, c )\
elseif mode == 7 then\
\
if type( a ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( a ) ) end\
if type( b ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( b ) ) end\
if type( c ) ~= \"number\" then return error( \"expected number radius, got \" .. class.type( c ) ) end\
\
return area.correct_circle( a, b, c )\
else\
return error( \"unexpected mode: \" .. tostring( mode ) )\
end\
end","graphics.Canvas",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
\
\
\
\
class \"DrawingCanvas\" extends \"Canvas\" {}\
\
function DrawingCanvas:drawPoint( x, y, options )\
\
if type( x ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( x ) ) end\
if type( y ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( y ) ) end\
if type( options ) ~= \"table\" then return error( \"expected table options, got \" .. class.type( options ) ) end\
\
local colour = options.colour or 0\
local textColour = options.textColour or 1\
local character = options.character or \" \"\
\
if type( colour ) ~= \"number\" then return error( \"expected number colour, got \" .. class.type( colour ) ) end\
if type( textColour ) ~= \"number\" then return error( \"expected number textColour, got \" .. class.type( textColour ) ) end\
if type( character ) ~= \"string\" then return error( \"expected string character, got \" .. class.type( character ) ) end\
\
if x >= 0 and y >= 0 and x < self.width and y < self.height then\
self:drawPixel( { y * self.width + x + 1 }, { colour, textColour, character } )\
end\
end\
\
function DrawingCanvas:drawBox( x, y, width, height, options )\
\
if type( x ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( x ) ) end\
if type( y ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( y ) ) end\
if type( width ) ~= \"number\" then return error( \"expected number width, got \" .. class.type( width ) ) end\
if type( height ) ~= \"number\" then return error( \"expected number height, got \" .. class.type( height ) ) end\
if type( options ) ~= \"table\" then return error( \"expected table options, got \" .. class.type( options ) ) end\
\
local colour = options.colour or 0\
local textColour = options.textColour or 1\
local character = options.character or \" \"\
\
if type( colour ) ~= \"number\" then return error( \"expected number colour, got \" .. class.type( colour ) ) end\
if type( textColour ) ~= \"number\" then return error( \"expected number textColour, got \" .. class.type( textColour ) ) end\
if type( character ) ~= \"string\" then return error( \"expected string character, got \" .. class.type( character ) ) end\
\
if character == \" \" then\
self:drawColour( self:getArea( 0, x, y, width, height ), colour )\
else\
self:drawPixel( self:getArea( 0, x, y, width, height ), { colour, textColour, character } )\
end\
end\
\
function DrawingCanvas:drawCircle( x, y, radius, options )\
\
if type( x ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( x ) ) end\
if type( y ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( y ) ) end\
if type( radius ) ~= \"number\" then return error( \"expected number radius, got \" .. class.type( radius ) ) end\
if type( options ) ~= \"table\" then return error( \"expected table options, got \" .. class.type( options ) ) end\
\
local colour = options.colour or 0\
local textColour = options.textColour or 1\
local character = options.character or \" \"\
local corrected = options.corrected or false\
\
if type( colour ) ~= \"number\" then return error( \"expected number colour, got \" .. class.type( colour ) ) end\
if type( textColour ) ~= \"number\" then return error( \"expected number textColour, got \" .. class.type( textColour ) ) end\
if type( character ) ~= \"string\" then return error( \"expected string character, got \" .. class.type( character ) ) end\
\
if character == \" \" then\
self:drawColour( self:getArea( corrected and 7 or 1, x, y, radius ), colour )\
else\
self:drawPixel( self:getArea( corrected and 7 or 1, x, y, radius ), { colour, textColour, character } )\
end\
end\
\
function DrawingCanvas:drawLine( x1, y1, x2, y2, options )\
\
if type( x1 ) ~= \"number\" then return error( \"expected number x1, got \" .. class.type( x1 ) ) end\
if type( y1 ) ~= \"number\" then return error( \"expected number y1, got \" .. class.type( y1 ) ) end\
if type( x2 ) ~= \"number\" then return error( \"expected number x2, got \" .. class.type( x2 ) ) end\
if type( y2 ) ~= \"number\" then return error( \"expected number y2, got \" .. class.type( y2 ) ) end\
if type( options ) ~= \"table\" then return error( \"expected table options, got \" .. class.type( options ) ) end\
\
local colour = options.colour or 0\
local textColour = options.textColour or 1\
local character = options.character or \" \"\
\
if type( colour ) ~= \"number\" then return error( \"expected number colour, got \" .. class.type( colour ) ) end\
if type( textColour ) ~= \"number\" then return error( \"expected number textColour, got \" .. class.type( textColour ) ) end\
if type( character ) ~= \"string\" then return error( \"expected string character, got \" .. class.type( character ) ) end\
\
if character == \" \" then\
self:drawColour( self:getArea( 2, x1, y1, x2, y2 ), colour )\
else\
self:drawPixel( self:getArea( 2, x1, y1, x2, y2 ), { colour, textColour, character } )\
end\
end\
\
function DrawingCanvas:drawHorizontalLine( x, y, width, options )\
\
if type( x ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( x ) ) end\
if type( y ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( y ) ) end\
if type( width ) ~= \"number\" then return error( \"expected number width, got \" .. class.type( width ) ) end\
if type( options ) ~= \"table\" then return error( \"expected table options, got \" .. class.type( options ) ) end\
\
local colour = options.colour or 0\
local textColour = options.textColour or 1\
local character = options.character or \" \"\
\
if type( colour ) ~= \"number\" then return error( \"expected number colour, got \" .. class.type( colour ) ) end\
if type( textColour ) ~= \"number\" then return error( \"expected number textColour, got \" .. class.type( textColour ) ) end\
if type( character ) ~= \"string\" then return error( \"expected string character, got \" .. class.type( character ) ) end\
\
if character == \" \" then\
self:drawColour( self:getArea( 4, x, y, width ), colour )\
else\
self:drawPixel( self:getArea( 4, x, y, width ), { colour, textColour, character } )\
end\
end\
\
function DrawingCanvas:drawVerticalLine( x, y, height, options )\
\
if type( x ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( x ) ) end\
if type( y ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( y ) ) end\
if type( height ) ~= \"number\" then return error( \"expected number height, got \" .. class.type( height ) ) end\
if type( options ) ~= \"table\" then return error( \"expected table options, got \" .. class.type( options ) ) end\
\
local colour = options.colour or 0\
local textColour = options.textColour or 1\
local character = options.character or \" \"\
\
if type( colour ) ~= \"number\" then return error( \"expected number colour, got \" .. class.type( colour ) ) end\
if type( textColour ) ~= \"number\" then return error( \"expected number textColour, got \" .. class.type( textColour ) ) end\
if type( character ) ~= \"string\" then return error( \"expected string character, got \" .. class.type( character ) ) end\
\
if character == \" \" then\
self:drawColour( self:getArea( 3, x, y, height ), colour )\
else\
self:drawPixel( self:getArea( 3, x, y, height ), { colour, textColour, character } )\
end\
end\
\
\
\
\
\
function DrawingCanvas:drawText( x, y, text, options )\
\
if type( x ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( x ) ) end\
if type( y ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( y ) ) end\
if type( text ) ~= \"string\" then return error( \"expected string text, got \" .. class.type( text ) ) end\
if type( options ) ~= \"table\" then return error( \"expected table options, got \" .. class.type( options ) ) end\
\
local colour = options.colour or 0\
local textColour = options.textColour or 1\
\
if type( colour ) ~= \"number\" then return error( \"expected number colour, got \" .. class.type( colour ) ) end\
if type( textColour ) ~= \"number\" then return error( \"expected number textColour, got \" .. class.type( textColour ) ) end\
\
\
if y < 0 or y >= self.height then return end -- no pixels to draw\
\
local sWidth = self.width\
local ypos = y * sWidth + ( x > 0 and x or 0 )\
local diff = x > 0 and 0 or -x\
local t, p = {}, {}\
local w, w2 = sWidth - x, #text - diff\
\
for i = 1, w < w2 and w or w2 do\
t[i] = { colour, textColour, text:sub( i + diff, i + diff ) }\
p[i] = ypos + i\
end\
\
self:drawPixels( p, t )\
end","graphics.DrawingCanvas",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
\
\
\
\
local redirect = term.redirect\
\
local hex = {}\
for i = 0, 15 do\
hex[2 ^ i] = (\"%x\"):format( i )\
end\
\
class \"ScreenCanvas\" extends \"Canvas\" {\
last = {};\
}\
\
function ScreenCanvas:ScreenCanvas( width, height )\
width = width or 0\
height = height or 0\
\
\
if type( width ) ~= \"number\" then return error( \"element attribute #1 'width' not a number (\" .. class.type( width ) .. \")\", 2 ) end\
if type( height ) ~= \"number\" then return error( \"element attribute #2 'height' not a number (\" .. class.type( height ) .. \")\", 2 ) end\
\
\
self.last = {}\
for i = 1, width * height do\
self.last[i] = {}\
end\
\
return self:Canvas( width, height )\
end\
\
function ScreenCanvas:drawToTerminal( term, sx, sy )\
sx = sx or 0\
sy = sy or 0\
\
if type( term ) ~= \"table\" or not pcall( function() redirect( redirect( term ) ) end ) then\
return error( \"expected term-redirect t, got \" .. class.type( term ) )\
end\
if type( sx ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( sx ) ) end\
if type( sy ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( sy ) ) end\
\
\
local i = 1\
local pixels, last = self.pixels, self.last\
local sWidth = self.width\
\
for y = 1, self.height do\
local changed = false\
for x = 1, sWidth do\
\
local px = pixels[i]\
local ltpx = last[i]\
\
\
\
if px[1] ~= ltpx[1] or px[2] ~= ltpx[2] or px[3] ~= ltpx[3] then\
changed = true\
last[i] = px\
end\
\
\
i = i + 1\
end\
\
if changed then\
local bc, tc, s = {}, {}, {}\
i = i - sWidth\
for x = 1, sWidth do\
local px = pixels[i]\
bc[x] = hex[px[1]]\
tc[x] = hex[px[2]]\
s[x] = px[3] == \"\" and \" \" or px[3]\
i = i + 1\
end\
term.setCursorPos( sx + 1, sy + y )\
term.blit( table.concat( s ), table.concat( tc ), table.concat( bc ) )\
end\
end\
end\
\
function ScreenCanvas:drawToScreen( x, y )\
return self:drawToTerminal( term, x, y )\
end","graphics.ScreenCanvas",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("\
timer = {}\
\
local timers = {}\
local timerID = 0\
local t, lt = os.clock()\
\
function timer.new( n )\
local finish, ID = t + n, false -- avoids duplicating timer events\
for i = 1, #timers do\
if timers[i].time == finish then\
ID = timers[i].ID\
break\
end\
end\
return ID or os.startTimer( n )\
end\
\
function timer.queue( n, response )\
\
\
\
\
\
local finish, ID = t + n, false -- avoids duplicating timer events\
for i = 1, #timers do\
if timers[i].time == finish then\
ID = timers[i].ID\
break\
end\
end\
\
local timerID = ID or os.startTimer( n )\
timers[#timers + 1] = { time = finish, response = response, ID = timerID }\
return timerID\
end\
\
function timer.cancel( ID )\
\
\
\
for i = #timers, 1, -1 do\
if timers[i].ID == ID then\
return table.remove( timers, i ).time - t\
end\
end\
return 0\
end\
\
function timer.step()\
lt = t\
t = os.clock()\
end\
\
function timer.getDelta()\
return t - lt\
end\
\
function timer.update( timerID )\
local updated = false\
for i = #timers, 1, -1 do\
if timers[i].ID == timerID then\
table.remove( timers, i ).response()\
updated = true\
end\
end\
return updated\
end\
\
timer.step()","sheets.timer",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("\
\
\
\
\
\
\
\
\
IAnimation = {}\
\
function IAnimation:IAnimation()\
self.animations = {}\
end\
\
function IAnimation:addAnimation( label, setter, animation )\
if type( label ) ~= \"string\" then return error( \"expected string label, got \" .. class.type( label ) ) end\
if type( setter ) ~= \"function\" then return error( \"expected function setter, got \" .. class.type( setter ) ) end\
if not class.typeOf( animation, Animation ) then return error( \"expected Animation animation, got \" .. class.type( animation ) ) end\
\
self.animations[label] = {\
setter = setter;\
animation = animation;\
}\
if animation.value then\
setter( self, animation.value )\
end\
end\
\
function IAnimation:updateAnimations( dt )\
if type( dt ) ~= \"number\" then return error( \"expected number dt, got \" .. class.type( dt ) ) end\
\
local finished = {}\
local animations = self.animations\
local k, v = next( animations )\
\
while animations[k] do\
v.animation:update( dt )\
if v.animation.value then\
v.setter( self, v.animation.value )\
end\
\
if v.animation:finished() then\
if type( v.animation.onFinish ) == \"function\" then\
v.animation:onFinish()\
end\
finished[#finished + 1] = k\
end\
\
k, v = next( animations, k )\
end\
\
for i = 1, #finished do\
self.animations[finished[i]] = nil\
end\
end","sheets.interfaces.IAnimation",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IChildContainer = {}\
\
IChildContainer.children = {}\
\
function IChildContainer:IChildContainer()\
self.children = {}\
\
self.meta.__add = self.addChild\
\
function self.meta:__concat( child )\
self:addChild( child )\
return self\
end\
end\
\
function IChildContainer:addChild( child )\
if not class.typeOf( child, Sheet ) then return error( \"expected Sheet child, got \" .. class.type( child ) ) end\
\
if child.parent then\
child.parent:removeChild( child )\
end\
\
self:setChanged( true )\
child.parent = self\
if child.theme == default_theme then\
child:setTheme( self.theme )\
end\
self.children[#self.children + 1] = child\
return child\
end\
\
function IChildContainer:removeChild( child )\
for i = #self.children, 1, -1 do\
if self.children[i] == child then\
self:setChanged( true )\
child.parent = nil\
\
return table.remove( self.children, i )\
end\
end\
end\
\
function IChildContainer:getChildById( id )\
if type( id ) ~= \"string\" then return error( \"expected string id, got \" .. class.type( id ) ) end\
\
for i = #self.children, 1, -1 do\
local c = self.children[i]:getChildById( id )\
if c then\
return c\
elseif self.children[i].id == id then\
return self.children[i]\
end\
end\
end\
\
function IChildContainer:getChildrenById( id )\
if type( id ) ~= \"string\" then return error( \"expected string id, got \" .. class.type( id ) ) end\
\
local t = {}\
for i = #self.children, 1, -1 do\
local subt = self.children[i]:getChildById( id )\
for i = 1, #subt do\
t[#t + 1] = subt[i]\
end\
if self.children[i].id == id then\
t[#t + 1] = self.children[i]\
end\
end\
return t\
end\
\
function IChildContainer:isChildVisible( child )\
return child.x + child.width > 0 and child.y + child.height > 0 and child.x < self.width and child.y < self.height\
end","sheets.interfaces.IChildContainer",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IChildDecoder = {}\
\
function IChildDecoder:decodeChildren( body )\
local document = SMLDocument.current()\
local c = {}\
\
for i = 1, #body do\
local object, err = document:loadSMLNode( body[i], self )\
if object then\
c[i] = object\
else\
return error( err, 0 )\
end\
end\
\
return c\
end","sheets.interfaces.IChildDecoder",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
ICommon = {\
changed = true;\
}\
\
function ICommon:setChanged( state )\
self.changed = state ~= false\
if state ~= false and self.parent and not self.parent.changed then\
self.parent:setChanged( true )\
end\
return self\
end","sheets.interfaces.ICommon",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IEvent = {\
event = nil;\
handled = false;\
}\
\
function IEvent:IEvent( event )\
self.event = event\
end\
\
function IEvent:is( event )\
return self.event == event\
end\
\
function IEvent:handle()\
self.handled = true\
end","sheets.interfaces.IEvent",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IHasID = {\
id = \"ID\";\
}\
\
function IHasID:setID( id )\
self.id = id\
return self\
end","sheets.interfaces.IHasID",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IHasParent = {}\
\
IHasParent.parent = nil\
\
function IHasParent:setParent( parent )\
if parent and ( not class.isInstance( parent ) or not parent:implements( IChildContainer ) ) then return error( \"expected IChildContainer parent, got \" .. class.type( parent ) ) end\
\
if parent then\
parent:addChild( self )\
else\
self:remove()\
end\
return self\
end\
\
function IHasParent:remove()\
if self.parent then\
return self.parent:removeChild( self )\
end\
end\
\
function IHasParent:isVisible()\
return self.parent and self.parent:isChildVisible( self )\
end","sheets.interfaces.IHasParent",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
local wrapline, wrap\
\
IHasText = {\
text = \"\";\
horizontal_alignment = 0;\
vertical_alignment = 3;\
text_lines = {};\
}\
\
function IHasText:setText( text )\
if type( text ) ~= \"string\" then return error( \"expected string text, got \" .. class.type( text ) ) end\
\
self.text = text\
self:wrapText()\
self:setChanged()\
return self\
end\
\
function IHasText:setVerticalAlignment( alignment )\
if alignment ~= 3 and alignment ~= 1 and alignment ~= 4 then return error( \"invalid alignment\" ) end\
\
self.vertical_alignment = alignment\
self:wrapText()\
self:setChanged()\
\
return self\
end\
\
function IHasText:setHorizontalAlignment( alignment )\
if alignment ~= 0 and alignment ~= 1 and alignment ~= 2 then return error( \"invalid alignment\" ) end\
\
self.horizontal_alignment = alignment\
self:wrapText()\
self:setChanged()\
\
return self\
end\
\
function IHasText:wrapText()\
self.lines = wrap( self.text, self.width, self.height )\
end\
\
function IHasText:drawText( mode )\
local offset, lines = 0, self.lines\
mode = mode or \"default\"\
\
if not lines then\
self:wrapText()\
lines = self.lines\
end\
\
if self.vertical_alignment == 1 then\
offset = math.floor( self.height / 2 - #lines / 2 + .5 )\
elseif self.vertical_alignment == 4 then\
offset = self.height - #lines\
end\
\
for i = 1, #lines do\
\
local xOffset = 0\
if self.horizontal_alignment == 1 then\
xOffset = math.floor( self.width / 2 - #lines[i] / 2 + .5 )\
elseif self.horizontal_alignment == 2 then\
xOffset = self.width - #lines[i]\
end\
\
self.canvas:drawText( xOffset, offset + i - 1, lines[i], {\
colour = self.theme:getField( self.class, \"colour\", mode );\
textColour = self.theme:getField( self.class, \"textColour\", mode );\
} )\
\
end\
end\
\
function IHasText:onPreDraw()\
self:drawText \"default\"\
end\
\
function wrapline( text, width )\
if text:sub( 1, width ):find \"\\n\" then\
return text:match \"^(.-)\\n[^%S\\n]*(.*)$\"\
end\
if #text < width then\
return text\
end\
for i = width + 1, 1, -1 do\
if text:sub( i, i ):find \"%s\" then\
return text:sub( 1, i - 1 ):gsub( \"[^%S\\n]+$\", \"\" ), text:sub( i + 1 ):gsub( \"^[^%S\\n]+\", \"\" )\
end\
end\
return text:sub( 1, width ), text:sub( width + 1 )\
end\
\
function wrap( text, width, height )\
local lines, line = {}\
while text and #lines < height do\
line, text = wrapline( text, width )\
lines[#lines + 1] = line\
end\
return lines\
end","sheets.interfaces.IHasText",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IHasTheme = {\
theme = nil;\
}\
\
function IHasTheme:setTheme( theme, children )\
if not class.typeOf( theme, Theme ) then return error( \"expected Theme theme, got \" .. type( theme ) ) end\
\
self.theme = theme\
\
if children and self.children then\
for i = 1, #self.children do\
self.children[i]:setTheme( theme, true )\
end\
end\
\
self:setChanged( true )\
return self\
end","sheets.interfaces.IHasTheme",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IPosition = {}\
\
IPosition.x = 0\
IPosition.y = 0\
IPosition.width = 0\
IPosition.height = 0\
\
function IPosition:IPosition( x, y, width, height )\
self.x = x\
self.y = y\
self.width = width\
self.height = height\
end\
\
function IPosition:setX( x )\
\
\
\
if self.x ~= x then\
self.x = x\
if self.parent then self.parent:setChanged( true ) end\
end\
return self\
end\
\
function IPosition:setY( y )\
\
\
\
if self.y ~= y then\
self.y = y\
if self.parent then self.parent:setChanged( true ) end\
end\
return self\
end\
\
function IPosition:setWidth( width )\
\
\
\
if self.width ~= width then\
self.width = width\
for i = 1, #self.children do\
self.children[i]:onParentResized()\
end\
self.canvas:setWidth( width )\
self:setChanged( true )\
end\
return self\
end\
\
function IPosition:setHeight( height )\
\
\
\
if self.height ~= height then\
self.height = height\
for i = 1, #self.children do\
self.children[i]:onParentResized()\
end\
self.canvas:setHeight( height )\
self:setChanged( true )\
end\
return self\
end","sheets.interfaces.IPosition",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IPositionAnimator = {}\
\
function IPositionAnimator:transitionX( to, time, easing )\
if type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if easing and type( easing ) ~= \"function\" and easing ~= 2 and easing ~= 0 and easing ~= 1 then return error( \"expected function easing, got \" .. class.type( easing ) ) end\
\
local a = Animation():setRounded()\
:addKeyFrame( self.x, to, time or .3, easing or 2 )\
self:addAnimation( \"x\", self.setX, a )\
return a\
end\
\
function IPositionAnimator:transitionY( to, time, easing )\
if type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if easing and type( easing ) ~= \"function\" and easing ~= 2 and easing ~= 0 and easing ~= 1 then return error( \"expected function easing, got \" .. class.type( easing ) ) end\
\
local a = Animation():setRounded()\
:addKeyFrame( self.y, to, time or .3, easing or 2 )\
self:addAnimation( \"y\", self.setY, a )\
return a\
end\
\
function IPositionAnimator:transitionWidth( to, time, easing )\
if type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if easing and type( easing ) ~= \"function\" and easing ~= 2 and easing ~= 0 and easing ~= 1 then return error( \"expected function easing, got \" .. class.type( easing ) ) end\
\
local a = Animation():setRounded()\
:addKeyFrame( self.width, to, time or .3, easing or 2 )\
self:addAnimation( \"width\", self.setWidth, a )\
return a\
end\
\
function IPositionAnimator:transitionHeight( to, time, easing )\
if type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if easing and type( easing ) ~= \"function\" and easing ~= 2 and easing ~= 0 and easing ~= 1 then return error( \"expected function easing, got \" .. class.type( easing ) ) end\
\
local a = Animation():setRounded()\
:addKeyFrame( self.height, to, time or .3, easing or 2 )\
self:addAnimation( \"height\", self.setHeight, a )\
return a\
end\
\
function IPositionAnimator:transitionInLeft( to, time )\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if to and type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
\
if not self.parent then\
return error( tostring( self ) .. \" has no parent, cannot transition in\" )\
end\
local a = Animation():setRounded()\
:addKeyFrame( self.x, to or 0, time or .3, 1 )\
self:addAnimation( \"x\", self.setX, a )\
\
return a\
end\
\
function IPositionAnimator:transitionOutLeft( to, time )\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if to and type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
\
if not self.parent then\
return error( tostring( self ) .. \" has no parent, cannot transition out\" )\
end\
local a = Animation():setRounded()\
:addKeyFrame( self.x, to or -self.width, time or .3, 0 )\
\
local f = a:getLastAdded()\
\
self:addAnimation( \"x\", self.setX, a )\
\
function f.onFinish()\
self:remove()\
end\
\
return a\
end\
\
function IPositionAnimator:transitionInRight( to, time )\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if to and type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
\
if not self.parent then\
return error( tostring( self ) .. \" has no parent, cannot transition in\" )\
end\
local a = Animation():setRounded()\
:addKeyFrame( self.x, to or self.parent.width - self.width, time or .3, 1 )\
self:addAnimation( \"x\", self.setX, a )\
\
return a\
end\
\
function IPositionAnimator:transitionOutRight( to, time )\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if to and type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
\
if not self.parent then\
return error( tostring( self ) .. \" has no parent, cannot transition out\" )\
end\
local a = Animation():setRounded()\
:addKeyFrame( self.x, to or self.parent.width, time or .3, 0 )\
\
local f = a:getLastAdded()\
\
self:addAnimation( \"x\", self.setX, a )\
\
function f.onFinish()\
self:remove()\
end\
\
return a\
end\
\
function IPositionAnimator:transitionInTop( to, time )\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if to and type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
\
if not self.parent then\
return error( tostring( self ) .. \" has no parent, cannot transition in\" )\
end\
local a = Animation():setRounded()\
:addKeyFrame( self.y, to or 0, time or .3, 1 )\
self:addAnimation( \"y\", self.setY, a )\
\
return a\
end\
\
function IPositionAnimator:transitionOutTop( to, time )\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if to and type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
\
if not self.parent then\
return error( tostring( self ) .. \" has no parent, cannot transition out\" )\
end\
local a = Animation():setRounded()\
:addKeyFrame( self.y, to or -self.height, time or .3, 0 )\
\
local f = a:getLastAdded()\
\
self:addAnimation( \"y\", self.setY, a )\
\
function f.onFinish()\
self:remove()\
end\
\
return a\
end\
\
function IPositionAnimator:transitionInBottom( to, time )\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if to and type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
\
if not self.parent then\
return error( tostring( self ) .. \" has no parent, cannot transition in\" )\
end\
local a = Animation():setRounded()\
:addKeyFrame( self.y, to or self.parent.height - self.height, time or .3, 1 )\
self:addAnimation( \"y\", self.setY, a )\
\
return a\
end\
\
function IPositionAnimator:transitionOutBottom( to, time )\
if time and type( time ) ~= \"number\" then return error( \"expected number time, got \" .. class.type( time ) ) end\
if to and type( to ) ~= \"number\" then return error( \"expected number to, got \" .. class.type( to ) ) end\
\
if not self.parent then\
return error( tostring( self ) .. \" has no parent, cannot transition out\" )\
end\
local a = Animation():setRounded()\
:addKeyFrame( self.y, to or self.parent.height, time or .3, 0 )\
\
local f = a:getLastAdded()\
\
self:addAnimation( \"y\", self.setY, a )\
\
function f.onFinish()\
self:remove()\
end\
\
return a\
end","sheets.interfaces.IPositionAnimator",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IAnimatedPositionAttributes = {}\
\
function IAnimatedPositionAttributes:attribute_targetX( value, node )\
if type( value ) ~= \"number\" then\
error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: expected number for 'targetX' attribute\" )\
end\
self:transitionX( value )\
end\
\
function IAnimatedPositionAttributes:attribute_targetY( value, node )\
if type( value ) ~= \"number\" then\
error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: expected number for 'targetY' attribute\" )\
end\
self:transitionY( value )\
end\
\
function IAnimatedPositionAttributes:attribute_targetWidth( value, node )\
if type( value ) ~= \"number\" then\
error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: expected number for 'targetWidth' attribute\" )\
end\
self:transitionWidth( value )\
end\
\
function IAnimatedPositionAttributes:attribute_targetHeight( value, node )\
if type( value ) ~= \"number\" then\
error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: expected number for 'targetHeight' attribute\" )\
end\
self:transitionHeight( value )\
end","sheets.interfaces.attributes.IAnimatedPositionAttributes",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
ICommonAttributes = {}\
\
function ICommonAttributes:attribute_id( id )\
self:setID( id )\
end","sheets.interfaces.attributes.ICommonAttributes",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IPositionAttributes = {}\
\
function IPositionAttributes:attribute_x( x, node )\
if type( x ) == \"number\" then\
return self:setX( x )\
else\
error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: attribute 'x' is not a number (\" .. type( x ) .. \")\", 0 )\
end\
end\
\
function IPositionAttributes:attribute_y( y, node )\
if type( y ) == \"number\" then\
return self:setY( y )\
else\
error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: attribute 'y' is not a number (\" .. type( y ) .. \")\", 0 )\
end\
end\
\
function IPositionAttributes:attribute_width( width, node )\
if type( width ) == \"number\" then\
return self:setWidth( width )\
else\
error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: attribute 'width' is not a number (\" .. type( width ) .. \")\", 0 )\
end\
end\
\
function IPositionAttributes:attribute_height( height, node )\
if type( height ) == \"number\" then\
return self:setHeight( height )\
else\
error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: attribute 'height' is not a number (\" .. type( height ) .. \")\", 0 )\
end\
end","sheets.interfaces.attributes.IPositionAttributes",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
local a = {\
left = 0;\
centre = 1;\
center = 1;\
right = 2;\
top = 3;\
bottom = 4;\
}\
\
ITextAttributes = {}\
\
function ITextAttributes:attribute_text( text )\
self:setText( tostring( text ) )\
end\
\
function ITextAttributes:attribute_horizontalAlignment( alignment, node )\
if alignment == \"left\" or alignment == \"centre\" or alignment == \"center\" or alignment == \"right\" then\
return self:setHorizontalAlignment( a[alignment] )\
else\
error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: attribute 'horizonalAlignment' is invalid\", 0 )\
end\
end\
\
function ITextAttributes:attribute_verticalAlignment( alignment, node )\
if alignment == \"top\" or alignment == \"centre\" or alignment == \"center\" or alignment == \"bottom\" then\
return self:setVerticalAlignment( a[alignment] )\
else\
error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: attribute 'verticalAlignment' is invalid\", 0 )\
end\
end","sheets.interfaces.attributes.ITextAttributes",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IThemeAttribute = {}\
\
function IThemeAttribute:attribute_theme( theme, node )\
local themeobj = SMLDocument.current():getTheme( theme )\
if themeobj then\
self:setTheme( themeobj )\
else\
return error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: no such theme '\" .. tostring( theme ) .. \"'\", 0 )\
end\
end","sheets.interfaces.attributes.IThemeAttribute",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"SMLNode\" {\
nodetype = \"blank\";\
attributes = {};\
body = nil;\
position = { line = 0, character = 0 };\
}\
\
function SMLNode:SMLNode( type, attributes, body, position )\
self.nodetype = type\
self.attributes = attributes\
self.body = body\
self.position = position\
end\
\
function SMLNode:set( attribute, value )\
for i = 1, #self.attributes do\
if self.attributes[i][1] == attribute then\
self.attributes[i][2] = value\
end\
end\
end\
\
function SMLNode:get( attribute )\
for i = 1, #self.attributes do\
if self.attributes[i][1] == attribute then\
return self.attributes[i][2]\
end\
end\
end\
\
function SMLNode:tostring( indent )\
local whitespace = (\"  \"):rep( indent or 0 )\
local a, b = \"\", {}\
\
for k, v in pairs( self.attributes ) do\
if v == true then\
a = a .. \" \" .. k\
else\
pcall( function()\
a = a .. \" \" .. k .. \"=\" .. textutils.serialize( v )\
end )\
end\
end\
\
if self.body then\
for i = 1, #self.body do\
b[i] = whitespace .. \"  \" .. self.body[i]:tostring( ( indent or 0 ) + 1 )\
end\
\
return \"<\" .. self.nodetype .. a .. \">\\n\\n\" .. table.concat( b, \"\\n\" ) .. \"\\n\\n\" .. whitespace .. \"</\" .. self.nodetype .. \">\"\
else\
return \"<\" .. self.nodetype .. a .. \"/>\"\
end\
end","sheets.sml.SMLNode",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
\
local type_lookup = {\
[0] = \"string\";\
[1] = \"equals\";\
[2] = \"opening bracket\";\
[3] = \"closing bracket\";\
[4] = \"slash\";\
[5] = \"number\";\
[6] = \"boolean\";\
[7] = \"identifier\";\
[8] = \"symbol\";\
[9] = \"EOF\";\
}\
\
local stringlookupt = setmetatable( { n = \"\\n\", r = \"\\r\", [\"0\"] = \"\\0\" }, { __index = function( t, k ) return k end } )\
\
local function matches( self, type, value )\
return self.type == type and ( value == nil or self.value == value )\
end\
\
local function Token( type, value, line, char )\
return { type = type, value = value, line = line, character = char, matches = matches }\
end\
\
local function tType( type )\
return type_lookup[type]\
end\
\
class \"SMLParser\" {\
text = \"\";\
char = 1;\
marker = 1;\
character = 1;\
line = 1;\
token = nil;\
peeking = {};\
}\
\
function SMLParser:SMLParser( str )\
self.text = str\
self.peeking = {}\
end\
\
function SMLParser:begin()\
if not self.token then\
self:next()\
end\
end\
\
function SMLParser:consume()\
\
local line, char = self.line, self.character\
if self.char > #self.text then\
return Token( 9, nil, line, char )\
end\
local c = self.text:sub( self.char, self.char )\
if c == \"\\\"\" or c == \"'\" then\
return self:consumeString( line, char )\
\
elseif self.text:find( \"^<!%-%-\", self.char ) then\
self:consumeComment( line, char )\
return self:consume()\
\
elseif c == \"<\" then\
self.char = self.char + 1\
self.character = self.character + 1\
return Token( 2, \"<\", line, char )\
\
elseif c == \">\" then\
self.char = self.char + 1\
self.character = self.character + 1\
return Token( 3, \">\", line, char )\
\
elseif c == \"/\" then\
self.char = self.char + 1\
self.character = self.character + 1\
return Token( 4, \"/\", line, char )\
\
elseif c == \"=\" or c == \":\" then\
self.char = self.char + 1\
self.character = self.character + 1\
return Token( 1, c, line, char )\
\
elseif self.text:find( \"^%-?%.?%d\", self.char ) then\
return self:consumeNumber( line, char )\
\
elseif c:find \"[%w_]\" then\
return self:consumeWord( line, char )\
\
elseif c == \"\\n\" then\
self:consumeNewline( line, char )\
return self:consume()\
\
elseif c:find \"%s\" then\
self:consumeWhitespace( line, char )\
return self:consume()\
\
end\
\
self.character = self.character + 1\
self.char = self.char + 1\
return Token( 8, c, line, char )\
\
end\
\
function SMLParser:consumeWord( line, char )\
local w = self.text:match( \"[a-zA-Z_][a-zA-Z_0-9]*\", self.char )\
self.char = self.char + #w\
self.character = self.character + #w\
if w == \"true\" or w == \"false\" then\
return Token( 6, w == \"true\", line, char )\
end\
return Token( 7, w, line, char )\
end\
\
function SMLParser:consumeNumber( line, char )\
local n = self.text:match( \"%-?%d*%.?%d+\", self.char )\
if self.text:sub( self.char + #n, self.char + #n ) == \"e\" then\
n = n .. ( self.text:match( \"^e%-?%d+\", self.char + #n ) or error( \"[\" .. line .. \", \" .. char .. \"]: expected number after exponent 'e'\", 0 ) )\
end\
self.char = self.char + #n\
self.character = self.character + #n\
return Token( 5, tonumber( n ), line, char )\
end\
\
function SMLParser:consumeString( line, char )\
local close, e, s = self.text:sub( self.char, self.char ), false, \"\"\
\
for i = self.char + 1, #self.text do\
if e then\
local ch = stringlookupt[self.text:sub( i, i )]\
if self.text:sub( i, i ) == \"\\n\" then\
self.character = 0\
self.line = self.line + 1\
end\
s, self.character, e = s .. ch, self.character + 1, false\
elseif self.text:sub( i, i ) == \"\\\\\" then\
e = true\
self.character = self.character + 1\
elseif self.text:sub( i, i ) == close then\
self.char = i + 1\
self.character = self.character + 1\
return Token( 0, s, line, char )\
elseif self.text:sub( i, i ) == \"\\n\" then\
s = s .. \"\\n\"\
self.character = 1\
self.line = self.line + 1\
else\
s = s .. self.text:sub( i, i )\
self.character = self.character + 1\
end\
end\
return error( \"[\" .. line .. \", \" .. char .. \"]: found no closing \" .. close, 0 )\
end\
\
function SMLParser:consumeComment( line, char )\
local _, e = self.text:find( \"%-%->\", self.char )\
if e then\
self.line = self.line + select( 2, self.text:sub( self.char, e ):gsub( \"\\n\", \"\" ) )\
self.character = self.character + #self.text:sub( self.char, e ):gsub( \".+\\n\", \"\" ) + 2\
self.char = e + 2\
else\
self.char = #self.text + 1\
end\
end\
\
function SMLParser:consumeNewline()\
self.line = self.line + 1\
self.character = 1\
self.char = self.char + 1\
end\
\
function SMLParser:consumeWhitespace()\
self.char = self.char + 1\
self.character = self.character + 1\
end\
\
function SMLParser:next()\
local t = self.token\
self.token = table.remove( self.peeking, 1 ) or self:consume()\
return t\
end\
\
function SMLParser:peek( n )\
if ( n or 0 ) == 0 then\
return self.token\
end\
for i = #self.peeking + 1, n do\
self.peeking[i] = self:consume()\
end\
return self.peeking[n]\
end\
\
function SMLParser:test( type, value, n )\
return self:peek( n ):matches( type, value ) and self:peek( n ) or nil\
end\
\
function SMLParser:skip( type, value )\
return self.token:matches( type, value ) and self:next() or nil\
end\
\
function SMLParser:parseArrayList()\
if self:test( 8, \"]\" ) then\
return {}\
else\
local t = {}\
repeat\
t[#t + 1] = self:parseValue()\
until not self:skip( 8, \",\" )\
return t\
end\
end\
\
function SMLParser:parseValue()\
local value = self:next()\
if value.type == 0 or value.type == 7 or value.type == 5 or value.type == 6 then\
return value.value\
elseif value:matches( 8, \"[\" ) then\
local array = self:parseArrayList()\
if not self:skip( 8, \"]\" ) then\
return error( \"[\" .. self:peek().line .. \", \" .. self:peek().character .. \"]: expected ']', got \" .. tType( self:peek().type ), 0 )\
end \
return array\
else\
return error( \"[\" .. value.line .. \", \" .. value.character .. \"]: unexpected \" .. tType( value.type ), 0 )\
end\
end\
\
function SMLParser:parseAttribute()\
local ident = self:skip( 7 ).value\
if self:skip( 1 ) then\
return ident, self:parseValue()\
else\
return ident, true\
end\
end\
\
function SMLParser:parseAttributes()\
local t = {}\
local l = {}\
while self:test( 7 ) do\
local k, v = self:parseAttribute()\
local n = l[k] or #t + 1\
l[k] = n\
t[n] = { k, v }\
end\
return t\
end\
\
function SMLParser:parseObject( position )\
if self:test( 7 ) then\
local name = self:skip( 7 ).value\
local attributes = self:parseAttributes()\
\
if self:skip( 4 ) then\
if not self:skip( 3 ) then\
return error( \"[\" .. self:peek().line .. \", \" .. self:peek().character .. \"]: expected '>' after '/'\", 0 )\
end\
return SMLNode( name, attributes, nil, position )\
else\
if not self:skip( 3 ) then\
return error( \"[\" .. self:peek().line .. \", \" .. self:peek().character .. \"]: expected '>' after '/'\", 0 )\
end\
return SMLNode( name, attributes, self:parseBody( name ), position )\
end\
else\
return error( \"[\" .. self:peek().line .. \", \" .. self:peek().character .. \"]: expected object type, got \" .. tType( self:peek().type ), 0 )\
end\
end\
\
function SMLParser:parseBody( closing )\
local body = {}\
local position = { line = self:peek().line, character = self:peek().character }\
while self:skip( 2 ) do\
if self:test( 4 ) then\
if closing then\
self:next()\
if self:test( 7 ) then\
if not self:skip( 7, closing ) then\
return error( \"[\" .. self:peek().line .. \", \" .. self:peek().character .. \"]: unexpected closing tag for '\" .. self:peek().value .. \"', expected '\" .. closing .. \"'\", 0 )\
end\
end\
if self:skip( 3 ) then\
return body\
else\
return error( \"[\" .. self:peek().line .. \", \" .. self:peek().character .. \"]: expected '>' after '/'\", 0 )\
end\
else\
return error( \"[\" .. self:peek().line .. \", \" .. self:peek().character .. \"]: unexpected closing tag\", 0 )\
end\
else\
body[#body + 1] = self:parseObject( position )\
end\
position = { line = self:peek().line, character = self:peek().character }\
end\
if closing then\
return error( \"[\" .. self:peek().line .. \", \" .. self:peek().character .. \"]: unexpected '\" .. tType( self:peek().type ) .. \"', expected closing tag to close '\" .. closing .. \"'\", 0 )\
end\
return body\
end","sheets.sml.SMLParser",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"SMLNodeDecoder\" {\
name = \"node\";\
isBodyAllowed = false;\
isBodyNecessary = false;\
}\
\
function SMLNodeDecoder:SMLNodeDecoder( name )\
self.name = name\
end\
\
function SMLNodeDecoder:init( node )\
\
end\
\
function SMLNodeDecoder:decodeBody( body )\
\
end","sheets.sml.SMLNodeDecoder",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
local active\
\
local function copyt( o )\
local t = {}\
local k, v = next( o )\
while k do\
t[k] = v\
k, v = next( o, k )\
end\
return t\
end\
\
local function parseScript( script, name )\
return pcall( function()\
local parser = SMLParser( script )\
parser:begin()\
return parser:parseBody()\
end )\
end\
\
local function readScript( file )\
local h = fs.open( file, \"r\" )\
if h then\
local content = h.readAll()\
h.close()\
return parseScript( content, fs.getName( file ) )\
else\
return false, \"failed to open file '\" .. file .. \"'\"\
end\
end\
\
local function rawLoadNode( self, node, parent )\
local decoder = self:getDecoder( node.nodetype )\
if decoder then\
local src = node:get \"src\"\
if src then\
if node.body then\
return error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: cannot have src attribute and body\", 0 )\
elseif type( src ) ~= \"string\" then\
return error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: expected string 'src'\", 0 )\
else\
local ok, data = readScript( self.application and self.application.path .. \"/\" .. src or src )\
if ok then\
node.body = data\
else\
return false, data\
end\
end\
end\
\
if node.body and not decoder.isBodyAllowed then\
return error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: body not allowed for node '\" .. decoder.name .. \"'\", 0 )\
elseif not node.body and decoder.isBodyNecessary then\
return error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: body required for node '\" .. decoder.name .. \"'\", 0 )\
end\
\
local element = decoder:init( parent )\
\
for i = 1, #node.attributes do\
local k, v = node.attributes[i][1], node.attributes[i][2]\
if k ~= \"src\" then\
if decoder[\"attribute_\" .. k] then\
local ok, data = pcall( decoder[\"attribute_\" .. k], element, v, node, parent )\
if not ok then\
return false, data\
end\
else\
return error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: invalid attribute '\" .. k .. \"' for node '\" .. decoder.name .. \"'\", 0 )\
end\
end\
end\
\
if node.body then\
local ok, data = pcall( decoder.decodeBody, element, node.body, parent )\
if not ok then\
return false, data\
end\
end\
\
return element\
else\
return false, \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: unknown node type '\" .. node.nodetype .. \"'\"\
end\
end\
\
class \"SMLDocument\" {\
application = nil;\
themes = {};\
environment = {};\
decoders = {};\
elements = {};\
}\
\
function SMLDocument.current()\
return active\
end\
\
function SMLDocument:SMLDocument( application )\
self.application = application\
self.themes = copyt( SMLDocument.themes )\
self.environment = copyt( SMLDocument.environment )\
self.decoders = copyt( SMLDocument.decoders )\
self.elements = copyt( SMLDocument.elements )\
\
self.environment.document = self\
self.environment.application = self.application\
\
active = self\
end\
\
function SMLDocument:loadSMLNode( node, parent )\
if not class.typeOf( node, SMLNode ) then return error( \"expected SMLNode node, got \" .. class.type( node ) ) end\
\
active = self\
if not self.application then\
return error( \"SMLDocument has no application: load an application first using SMLDocument:loadSMLApplication()\" )\
end\
return rawLoadNode( self, node, parent )\
end\
\
function SMLDocument:loadSMLScript( script, name, parent )\
name = name or \"sml-script\"\
\
if type( script ) ~= \"string\" then return error( \"expected string script, got \" .. class.type( script ) ) end\
if type( name ) ~= \"string\" then return error( \"expected string source, got \" .. class.type( name ) ) end\
\
if not self.application then\
return error( \"SMLDocument has no application: load an application first using SMLDocument:loadSMLApplication()\" )\
end\
\
local ok, data = parseScript( script, name )\
\
if ok then\
local t = {}\
for i = 1, #data do\
local object, err = rawLoadNode( self, data[i], parent )\
if not object then\
return false, name .. \" \" .. tostring( err )\
end\
t[i] = object\
end\
return t\
else\
return false, name .. \" \" .. data\
end\
end\
\
function SMLDocument:loadSMLFile( file, parent )\
if type( file ) ~= \"string\" then return error( \"expected string file, got \" .. class.type( file ) ) end\
\
if not self.application then\
return error( \"SMLDocument has no application: load an application first using SMLDocument:loadSMLApplication()\" )\
end\
local h = fs.open( self.application.path .. \"/\" .. file, \"r\" )\
if h then\
local content = h.readAll()\
h.close()\
return self:loadSMLScript( content, fs.getName( file ), parent )\
else\
return false, \"failed to open file\"\
end\
end\
\
function SMLDocument:loadSMLApplication( script, name )\
name = name or \"sml-script\"\
if type( script ) ~= \"string\" then return error( \"expected string script, got \" .. class.type( script ) ) end\
if type( name ) ~= \"string\" then return error( \"expected string source, got \" .. class.type( name ) ) end\
\
if self.application then\
return error \"document already has an application\"\
end\
\
local ok, data = parseScript( script, name )\
\
if ok then\
if #data == 1 then\
if data[1].nodetype == \"application\" then\
local application, err = rawLoadNode( self, data[1], self )\
if application and application:typeOf( Application ) then\
self.application = application\
self.environment.application = application\
return application\
elseif not application then\
return false, name .. \" \" .. tostring( err )\
else\
return error( \"misconfigured Sheets installation, <application> node didn't return an Application\" )\
end\
else\
return false, \"[\" .. data[1].position.line .. \", \" .. data[1].position.character .. \"]: expected application node, got \" .. data[1].nodetype\
end\
elseif data[2] then\
return false, \"[\" .. data[2].position.line .. \", \" .. data[2].position.character .. \"]: unexpected node '\" .. data[2].nodetype .. \"'\"\
else\
return false, \"expected application node, got nothing\"\
end\
else\
return false, name .. \" \" .. data\
end\
end\
\
function SMLDocument:loadSMLApplicationFile( file )\
if type( file ) ~= \"string\" then return error( \"expected string file, got \" .. class.type( file ) ) end\
\
if self.application then\
return error \"document already has an application\"\
end\
\
local h = fs.open( file, \"r\" )\
if h then\
local content = h.readAll()\
h.close()\
return self:loadSMLApplication( content, fs.getName( file ) )\
else\
return false, \"failed to open file\"\
end\
end\
\
function SMLDocument:setTheme( name, theme )\
if type( name ) ~= \"string\" then return error( \"expected string name, got \" .. class.type( name ) ) end\
if not class.typeOf( theme, Theme ) then return error( \"expected Theme theme, got \" .. class.type( theme ) ) end\
\
self.themes[name] = theme\
end\
\
function SMLDocument:getTheme( name )\
if type( name ) ~= \"string\" then return error( \"expected string name, got \" .. class.type( name ) ) end\
\
return self.themes[name] or self.themes.default\
end\
\
function SMLDocument:addElement( name, cls, decoder )\
if type( name ) ~= \"string\" then return error( \"expected string name, got \" .. class.type( name ) ) end\
if not class.isClass( cls ) then return error( \"expected Class class, got \" .. class.type( cls ) ) end\
if not class.typeOf( decoder, SMLNodeDecoder ) then return error( \"expected SMLNodeDecoder decoder, got \" .. class.type( decoder ) ) end\
\
self.elements[name] = cls\
self.decoders[name] = decoder\
end\
\
function SMLDocument:getElement( name )\
if type( name ) ~= \"string\" then return error( \"expected string name, got \" .. class.type( name ) ) end\
\
return self.elements[name]\
end\
\
function SMLDocument:setDecoder( name, decoder )\
if type( name ) ~= \"string\" then return error( \"expected string name, got \" .. class.type( name ) ) end\
if not class.typeOf( decoder, SMLNodeDecoder ) then return error( \"expected SMLNodeDecoder decoder, got \" .. class.type( decoder ) ) end\
\
self.decoders[name] = decoder\
end\
\
function SMLDocument:getDecoder( name )\
if type( name ) ~= \"string\" then return error( \"expected string name, got \" .. class.type( name ) ) end\
\
return self.decoders[name]\
end\
\
function SMLDocument:setVariable( name, value )\
if type( name ) ~= \"string\" then return error( \"expected string name, got \" .. class.type( name ) ) end\
\
self.environment[name] = value\
end\
\
function SMLDocument:getVariable( name )\
if type( name ) ~= \"string\" then return error( \"expected string name, got \" .. class.type( name ) ) end\
\
return self.environment[name]\
end","sheets.sml.SMLDocument",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"KeyFrame\" {\
clock = 0;\
value = 0;\
initial = 0;\
difference = 0;\
duration = 0;\
easing = nil;\
onFinish = nil;\
}\
\
function KeyFrame:KeyFrame( initial, final, duration, easing )\
self.duration = duration\
self.initial = initial\
self.difference = final - initial\
self.easing = easing\
self.value = initial\
end\
\
function KeyFrame:update( dt )\
self.clock = math.min( math.max( self.clock + dt, 0 ), self.duration )\
\
self.value = self.easing( self.initial, self.difference, self.clock / self.duration )\
end\
\
function KeyFrame:finished()\
return self.clock == self.duration\
end","sheets.animation.KeyFrame",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"Pause\" {\
duration = 0;\
clock = 0;\
onFinish = nil;\
}\
\
function Pause:Pause( pause )\
self.duration = pause\
end\
\
function Pause:update( dt )\
self.clock = math.min( math.max( self.clock + dt, 0 ), self.duration )\
\
if self.clock == self.duration and type( self.onFinish ) == \"function\" then\
self:onFinish()\
end\
end\
\
function Pause:finished()\
return self.clock == self.duration\
end","sheets.animation.Pause",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
-- if you try to update the value being animated using an onFinish method, nothing will happen unless you set self.value to nil\
\
local halfpi = math.pi / 2\
\
local function easing_transition( u, d, t )\
return u + d * ( 3 * t * t - 2 * t * t * t )\
end\
\
local function easing_exit( u, d, t )\
return -d * math.cos(t * halfpi) + d + u\
end\
\
local function easing_entrance( u, d, t )\
return u + d * math.sin(t * halfpi)\
end\
\
class \"Animation\" {\
frames = {};\
value = nil;\
rounded = false;\
}\
\
function Animation:Animation()\
self.frames = {}\
end\
\
function Animation:setRounded( value )\
self.rounded = value ~= false\
return self\
end\
\
function Animation:addKeyFrame( initial, final, duration, easing )\
if easing == 2 then\
easing = easing_transition\
elseif easing == 0 then\
easing = easing_exit\
elseif easing == 1 then\
easing = easing_entrance\
end\
\
if type( initial ) ~= \"number\" then return error( \"expected number initial, got \" .. class.type( initial ) ) end\
if type( final ) ~= \"number\" then return error( \"expected number final, got \" .. class.type( final ) ) end\
if type( duration ) ~= \"number\" then return error( \"expected number duration, got \" .. class.type( duration ) ) end\
if easing and type( easing ) ~= \"function\" then return error( \"expected function easing, got \" .. class.type( easing ) ) end\
\
local frame = KeyFrame( initial, final, duration, easing )\
self.frames[#self.frames + 1] = frame\
\
if #self.frames == 0 then\
self.value = frame.value\
end\
\
return self\
end\
\
function Animation:addPause( pause )\
pause = pause or 1\
if type( pause ) ~= \"number\" then return error( \"expected number pause, got \" .. class.type( pause ) ) end\
\
local p = Pause( pause )\
self.frames[#self.frames + 1] = p\
\
return self\
end\
\
function Animation:getLastAdded()\
return self.frames[#self.frames]\
end\
\
function Animation:update( dt )\
if type( dt ) ~= \"number\" then return error( \"expected number dt, got \" .. class.type( dt ) ) end\
\
if self.frames[1] then\
self.frames[1]:update( dt )\
self.value = self.frames[1].value or self.value -- the or self.value is because pauses don't have a value\
if self.rounded and self.value then\
self.value = math.floor( self.value + .5 )\
end\
if self.frames[1]:finished() then\
if type( self.frames[1].onFinish ) == \"function\" then\
self.frames[1].onFinish( self )\
end\
table.remove( self.frames, 1 )\
end\
end\
end\
\
function Animation:finished()\
return #self.frames == 0\
end","sheets.animation.Animation",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"KeyboardEvent\" implements (IEvent) {\
key = 0;\
meta = {};\
}\
\
function KeyboardEvent:KeyboardEvent( event, key, meta )\
self:IEvent( event )\
self.key = key\
self.meta = meta\
end","sheets.events.KeyboardEvent",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"MiscEvent\" implements (IEvent) {\
key = 0;\
meta = {};\
}\
\
function MiscEvent:MiscEvent( ... )\
self:IEvent( event )\
self.parameters = { ... }\
end","sheets.events.MiscEvent",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
\
class \"MouseEvent\" implements (IEvent) {\
x = 0;\
y = 0;\
button = 0;\
within = true;\
}\
\
function MouseEvent:MouseEvent( event, x, y, button, within )\
self:IEvent( event )\
self.x = x\
self.y = y\
self.button = button\
self.within = within\
end\
\
function MouseEvent:isWithinArea( x, y, width, height )\
if type( x ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( x ) ) end\
if type( y ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( y ) ) end\
if type( width ) ~= \"number\" then return error( \"expected number width, got \" .. class.type( width ) ) end\
if type( height ) ~= \"number\" then return error( \"expected number height, got \" .. class.type( height ) ) end\
\
return self.x >= x and self.y >= y and self.x < x + width and self.y < y + height\
end\
\
function MouseEvent:clone( x, y, within )\
if type( x ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( x ) ) end\
if type( y ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( y ) ) end\
\
local sub = MouseEvent( self.event, self.x - x, self.y - y, self.button, self.within and within or false )\
sub.handled = self.handled\
\
function sub.handle()\
sub.handled = true\
self:handle()\
end\
\
return sub\
end","sheets.events.MouseEvent",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"TextEvent\" implements (IEvent) {\
text = \"\";\
}\
\
function TextEvent:TextEvent( event, text )\
self:IEvent( event )\
self.text = text\
end","sheets.events.TextEvent",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"TimerEvent\" implements (IEvent) {\
key = 0;\
meta = {};\
}\
\
function TimerEvent:TimerEvent( timerID )\
self:IEvent( 10 )\
self.timerID = timerID\
end","sheets.events.TimerEvent",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("\
\
\
\
\
\
\
\
\
local template = {}\
\
class \"Theme\" {\
elements = {};\
}\
\
function Theme.addToTemplate( class, field, states )\
if not class.isClass( class ) then return error( \"expected Class class, got \" .. class.type( class ) ) end\
if type( field ) ~= \"string\" then return error( \"expected string field, got \" .. class.type( field ) ) end\
if type( states ) ~= \"table\" then return error( \"expected table states, got \" .. class.type( states ) ) end\
template[class] = template[class] or {}\
template[class][field] = template[class][field] or {}\
for k, v in pairs( states ) do\
template[class][field][k] = v\
end\
end\
\
function Theme:Theme()\
self.elements = {}\
end\
\
function Theme:setField( cls, field, state, value )\
if not class.isClass( cls ) then return error( \"expected Class class, got \" .. class.type( cls ) ) end\
if type( field ) ~= \"string\" then return error( \"expected string field, got \" .. class.type( field ) ) end\
if type( state ) ~= \"string\" then return error( \"expected string state, got \" .. class.type( state ) ) end\
self.elements[cls] = self.elements[cls] or {}\
self.elements[cls][field] = self.elements[cls][field] or {}\
self.elements[cls][field][state] = value\
end\
\
function Theme:getField( cls, field, state )\
if not class.isClass( cls ) then return error( \"expected Class class, got \" .. class.type( cls ) ) end\
if type( field ) ~= \"string\" then return error( \"expected string field, got \" .. class.type( field ) ) end\
if type( state ) ~= \"string\" then return error( \"expected string state, got \" .. class.type( state ) ) end\
if self.elements[cls] then\
if self.elements[cls][field] then\
if self.elements[cls][field][state] then\
return self.elements[cls][field][state]\
end\
end\
end\
if template[cls] then\
if template[cls][field] then\
if template[cls][field][state] then\
return template[cls][field][state]\
end\
end\
end\
if self.elements[cls] then\
if self.elements[cls][field] then\
if self.elements[cls][field].default then\
return self.elements[cls][field].default\
end\
end\
end\
end\
\
local decoder = SMLNodeDecoder \"theme\"\
\
decoder.isBodyAllowed = true\
decoder.isBodyNecessary = true\
\
function decoder:init()\
return Theme()\
end\
\
function decoder:attribute_name( name )\
SMLDocument.current():setTheme( name, self )\
end\
\
function decoder:decodeBody( body )\
local doc = SMLDocument.current()\
for i = 1, #body do\
\
local element = doc:getElement( body[i].nodetype )\
if not element then\
error( \"[\" .. body[i].position.line .. \", \" .. body[i].position.character .. \"] : unknown element '\" .. body[i].nodetype .. \"'\", 0 )\
end\
\
local fields = body[i].body\
if not fields then\
error( \"[\" .. body[i].position.line .. \", \" .. body[i].position.character .. \"] : element has no body for fields\", 0 )\
end\
\
for i = 1, #fields do\
local field = fields[i]\
\
if fields[i].body then\
error( \"[\" .. fields[i].position.line .. \", \" .. fields[i].position.character .. \"] : field '\" .. fields[i].nodetype .. \"' has body\", 0 )\
end\
\
for n = 1, #field.attributes do\
local k, v = field.attributes[n][1], field.attributes[n][2]\
if doc:getVariable( v ) ~= nil then\
v = doc:getVariable( v )\
end\
self:setField( element, fields[i].nodetype, k, v )\
end\
end\
end\
end\
\
SMLDocument:setDecoder( \"theme\", decoder )","sheets.Theme",nil,_ENV)if not __f then error(__err,0)end __f()

default_theme = Theme()

local __f,__err=load("\
\
\
\
\
\
\
\
\
-- need to add monitor support\
\
class \"Application\" implements (IChildContainer) implements (IAnimation) implements (ICommon)\
{\
name = \"UnNamed Application\";\
path = \"\";\
terminateable = true;\
\
viewportX = 0;\
viewportY = 0;\
\
width = 0;\
height = 0;\
\
screen = nil;\
\
terminal = term;\
terminals = {};\
monitor_sides = {};\
\
running = true;\
\
mouse = {};\
keys = {};\
}\
\
function Application:Application( name, path )\
self.name = tostring( name or \"UnNamed Application\" )\
self.path = path\
\
self.width, self.height = term.getSize()\
self.timers = {}\
\
self:IChildContainer()\
self:IAnimation()\
\
self.screen = ScreenCanvas( self.width, self.height )\
end\
\
function Application:stop()\
self.running = false\
end\
\
function Application:addChild( child )\
if not class.typeOf( child, View ) then return error( \"expected View child, got \" .. class.type( child ) ) end\
\
if child.parent then\
child.parent:removeChild( child )\
end\
\
self:setChanged( true )\
child.parent = self\
self.children[#self.children + 1] = child\
return child\
end\
\
function Application:isChildVisible( child )\
if not class.typeOf( child, View ) then return error( \"expected View child, got \" .. class.type( child ) ) end\
\
return child.x - self.viewportX + child.width > 0 and child.y - self.viewportY + child.height > 0 and child.x - self.viewportX < self.width and child.y - self.viewportY < self.height\
end\
\
function Application:setViewportX( x )\
if type( x ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( x ) ) end\
\
self.viewportX = x\
self:setChanged()\
end\
\
function Application:setViewportY( y )\
if type( y ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( y ) ) end\
\
self.viewportY = y\
self:setChanged()\
end\
\
function Application:transitionViewport( x, y )\
if x and type( x ) ~= \"number\" then return error( \"expected number x, got \" .. class.type( x ) ) end\
if y and type( y ) ~= \"number\" then return error( \"expected number y, got \" .. class.type( y ) ) end\
\
local ax, ay\
local dx = x and math.abs( x - self.viewportX ) or 0\
local dy = y and math.abs( y - self.viewportY ) or 0\
local xt = .5 * dx / self.width\
if dx > 0 then\
local ax = self:addAnimation( \"viewportX\", self.setViewportX, Animation():setRounded()\
:addKeyFrame( self.viewportX, x, xt, 2 ) )\
end\
if dy > 0 then\
local ay = self:addAnimation( \"viewportY\", self.setViewportY, Animation():setRounded()\
:addPause( xt )\
:addKeyFrame( self.viewportY, y, .5 * dy / self.height, 2 ) )\
end\
return ax, ay\
end\
\
function Application:transitionView( view )\
if not class.typeOf( view, View ) then return error( \"expected View view, got \" .. class.type( view ) ) end\
\
if view.parent == self then\
return self:transitionViewport( view.x, view.y )\
else\
return error( \"View is not a part of application '\" .. self.name .. \"'\" )\
end\
end\
\
function Application:event( event, ... )\
local params = { ... }\
local children = {}\
\
local function handle( e )\
if e:typeOf( MouseEvent ) then\
for i = #children, 1, -1 do\
children[i]:handle( e:clone( children[i].x - self.viewportX, children[i].y - self.viewportY, true ) )\
end\
else\
for i = #children, 1, -1 do\
children[i]:handle( e )\
end\
end\
end\
\
if event == \"timer\" and timer.update( ... ) then\
return\
end\
for i = 1, #self.children do\
children[i] = self.children[i]\
end\
\
if event == \"mouse_click\" then\
self.mouse = {\
x = params[2] - 1;\
y = params[3] - 1;\
down = true;\
timer = os.startTimer( 1 );\
moved = false;\
time = os.clock();\
button = params[1];\
}\
\
handle( MouseEvent( 0, params[2] - 1, params[3] - 1, params[1], true ) )\
\
elseif event == \"mouse_up\" then\
handle( MouseEvent( 1, params[2] - 1, params[3] - 1, params[1], true ) )\
\
self.mouse.down = false\
os.cancelTimer( self.mouse.timer )\
\
if not self.mouse.moved and os.clock() - self.mouse.time < 1 and params[1] == self.mouse.button then\
handle( MouseEvent( 2, params[2] - 1, params[3] - 1, params[1], true ) )\
end\
\
elseif event == \"mouse_drag\" then\
handle( MouseEvent( 4, params[2] - 1, params[3] - 1, params[1], true ) )\
\
self.mouse.moved = true\
os.cancelTimer( self.mouse.timer )\
\
elseif event == \"mouse_scroll\" then\
handle( MouseEvent( 5, params[2] - 1, params[3] - 1, params[1], true ) )\
\
elseif event == \"monitor_touch\" then -- need to think about this one\
-- handle( MouseEvent( 2, params[2] - 1, params[3] - 1, 1 ) )\
\
elseif event == \"chatbox_something\" then\
handle( TextEvent( 9, params[1] ) )\
\
elseif event == \"char\" then\
handle( TextEvent( 8, params[1] ) )\
\
elseif event == \"paste\" then\
handle( TextEvent( 11, params[1] ) )\
\
elseif event == \"key\" then\
handle( TextEvent( 6, params[1], self.keys ) )\
self.keys[keys.getName( params[1] ) or params[1]] = os.clock()\
\
elseif event == \"key_up\" then\
handle( TextEvent( 7, params[1], self.keys ) )\
self.keys[keys.getName( params[1] ) or params[1]] = nil\
\
elseif event == \"term_resize\" then\
self.width, self.height = term.getSize()\
for i = 1, #self.children do\
self.children[i]:onParentResized()\
end\
\
elseif event == \"timer\" then\
if params[1] == self.mouse.timer then\
handle( MouseEvent( 3, self.mouse.x, self.mouse.y, self.mouse.button, true ) )\
else\
handle( TimerEvent( params[1] ) )\
end\
\
else\
handle( MiscEvent( event, ... ) )\
end\
end\
\
function Application:update()\
\
local dt = timer.getDelta()\
local c = {}\
\
timer.step()\
self:updateAnimations( dt )\
\
for i = 1, #self.children do\
c[i] = self.children[i]\
end\
\
for i = #c, 1, -1 do\
c[i]:update( dt )\
end\
end\
\
function Application:draw()\
if self.changed then\
local screen = self.screen\
local children = {}\
\
screen:clear()\
\
for i = 1, #self.children do\
children[i] = self.children[i]\
end\
\
for i = 1, #children do\
local child = children[i]\
if child:isVisible() then\
child:draw()\
child.canvas:drawTo( screen, child.x - self.viewportX, child.y - self.viewportY )\
end\
end\
\
self.changed = false\
screen:drawToTerminal( self.terminal )\
end\
end\
\
function Application:run()\
local t = timer.new( 0 )\
while self.running do\
local event = { coroutine.yield() }\
if event[1] == \"timer\" and event[2] == t then\
t = timer.new( .05 )\
self:update()\
elseif event[1] == \"terminate\" and self.terminateable then\
self:stop()\
else\
self:event( unpack( event ) )\
end\
self:draw()\
end\
end\
\
Theme.addToTemplate( Application, \"colour\", {\
default = 1;\
} )\
\
local decoder = SMLNodeDecoder \"application\"\
\
decoder.isBodyAllowed = true\
decoder.isBodyNecessary = true\
\
function decoder:init( document )\
local a = Application()\
document.application = a\
return a\
end\
\
function decoder:attribute_name( name, node )\
if type( name ) == \"string\" then\
self.name = name\
else\
return error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: expected string name, got \" .. type( name ), 0 )\
end\
end\
\
function decoder:attribute_path( path, node )\
if type( path ) == \"string\" then\
self.path = path\
else\
return error( \"[\" .. node.position.line .. \", \" .. node.position.character .. \"]: expected string path, got \" .. type( path ), 0 )\
end\
end\
\
function decoder:attribute_terminateable( t, node )\
self.terminateable = t\
end\
\
function decoder:decodeBody( body, parent )\
local document = SMLDocument.current()\
for i = 1, #body do\
if body[i].nodetype == \"view\" or body[i].nodetype == \"theme\" or body[i].nodetype == \"script\" then\
local element, err = document:loadSMLNode( body[i], self )\
if element then\
if element:typeOf( View ) then\
self:addChild( element )\
end\
else\
return error( err, 0 )\
end\
end\
end\
end\
\
SMLDocument:addElement( \"application\", Application, decoder )","sheets.Application",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
local function orderChildren( children )\
local t = {}\
for i = 1, #children do\
local n = 1\
while t[n] and t[n].z <= children[i].z do\
n = n + 1\
end\
table.insert( t, n, children[i] )\
end\
return t\
end\
\
class \"Sheet\"\
implements (IChildContainer)\
implements (IPosition)\
implements (IAnimation)\
implements (IHasParent)\
implements (IPositionAnimator)\
implements (IHasID)\
implements (IHasTheme)\
implements (ICommon)\
{\
z = 0;\
\
canvas = nil;\
\
handlesKeyboard = true;\
handlesText = true;\
}\
\
function Sheet:Sheet( x, y, width, height )\
if type( x ) ~= \"number\" then return error( \"element attribute #1 'x' not a number (\" .. class.type( x ) .. \")\", 2 ) end\
if type( y ) ~= \"number\" then return error( \"element attribute #2 'y' not a number (\" .. class.type( y ) .. \")\", 2 ) end\
if type( width ) ~= \"number\" then return error( \"element attribute #3 'width' not a number (\" .. class.type( width ) .. \")\", 2 ) end\
if type( height ) ~= \"number\" then return error( \"element attribute #4 'height' not a number (\" .. class.type( height ) .. \")\", 2 ) end\
\
self:IPosition( x, y, width, height )\
self:IChildContainer()\
self:IAnimation()\
\
self.canvas = DrawingCanvas( width, height )\
self.theme = default_theme\
end\
\
function Sheet:tostring()\
return \"[Instance] Sheet \" .. tostring( self.id )\
end\
\
function Sheet:setZ( z )\
if type( z ) ~= \"number\" then return error( \"expected number z, got \" .. class.type( z ) ) end\
\
self.z = z\
if self.parent then self.parent:setChanged( true ) end\
return self\
end\
\
function Sheet:onPreDraw() end\
function Sheet:onPostDraw() end\
function Sheet:onUpdate( dt ) end\
function Sheet:onMouseEvent( event ) end\
function Sheet:onKeyboardEvent( event ) end\
function Sheet:onTextEvent( event ) end\
function Sheet:onParentResized() end\
\
function Sheet:draw()\
if self.changed then\
self:onPreDraw()\
\
local children = orderChildren( self.children )\
\
for i = 1, #children do\
local child = children[i]\
child:draw()\
child.canvas:drawTo( self.canvas, child.x, child.y )\
end\
\
self:onPostDraw()\
self.changed = false\
end\
end\
\
function Sheet:update( dt )\
if type( dt ) ~= \"number\" then return error( \"expected number dt, got \" .. class.type( dt ) ) end\
\
self:onUpdate( dt )\
self:updateAnimations( dt )\
\
local c = {}\
for i = 1, #self.children do\
c[i] = self.children[i]\
end\
\
for i = #c, 1, -1 do\
c[i]:update( dt )\
end\
end\
\
function Sheet:handle( event )\
local c = orderChildren( self.children )\
\
if event:typeOf( MouseEvent ) then\
local within = event:isWithinArea( 0, 0, self.width, self.height )\
for i = #c, 1, -1 do\
c[i]:handle( event:clone( c[i].x, c[i].y, within ) )\
end\
else\
for i = #c, 1, -1 do\
c[i]:handle( event )\
end\
end\
\
if event:typeOf( MouseEvent ) then\
if event:is( EVENT_MOUSE_PING ) and event:isWithinArea( 0, 0, self.width, self.height ) and event.within then\
event.button[#event.button + 1] = self\
end\
self:onMouseEvent( event )\
elseif event:typeOf( KeyboardEvent ) and self.handlesKeyboard then\
self:onKeyboardEvent( event )\
elseif event:typeOf( TextEvent ) and self.handlesText then\
self:onTextEvent( event )\
end\
end\
\
function Sheet:onMouseEvent( event )\
if not event.handled and event:isWithinArea( 0, 0, self.width, self.height ) and event.within then\
if not event:is( EVENT_MOUSE_DRAG ) and not event:is( EVENT_MOUSE_SCROLL ) then\
event:handle()\
end\
end\
end","sheets.Sheet",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("\
\
\
\
\
\
\
\
\
local function orderChildren( children )\
local t = {}\
for i = 1, #children do\
local n = 1\
while t[n] and t[n].z <= children[i].z do\
n = n + 1\
end\
table.insert( t, n, children[i] )\
end\
return t\
end\
\
class \"View\"\
implements (IChildContainer)\
implements (IPosition)\
implements (IAnimation)\
implements (IHasParent)\
implements (IPositionAnimator)\
implements (IHasID)\
implements (IHasTheme)\
implements (ICommon)\
{\
canvas = nil;\
}\
\
function View:View( x, y, width, height )\
if type( x ) ~= \"number\" then return error( \"element attribute #1 'x' not a number (\" .. class.type( x ) .. \")\", 2 ) end\
if type( y ) ~= \"number\" then return error( \"element attribute #2 'y' not a number (\" .. class.type( y ) .. \")\", 2 ) end\
if type( width ) ~= \"number\" then return error( \"element attribute #3 'width' not a number (\" .. class.type( width ) .. \")\", 2 ) end\
if type( height ) ~= \"number\" then return error( \"element attribute #4 'height' not a number (\" .. class.type( height ) .. \")\", 2 ) end\
\
self:IPosition( x, y, width, height )\
self:IChildContainer()\
self:IAnimation()\
\
self.canvas = DrawingCanvas( width, height )\
self.theme = default_theme\
end\
\
function View:tostring()\
return \"[Instance] View \" .. tostring( self.id )\
end\
\
function View:draw()\
if self.changed then\
local canvas = self.canvas\
\
canvas:clear( self.theme:getField( self.class, \"colour\", \"default\" ) )\
\
local children = orderChildren( self.children )\
\
for i = 1, #children do\
local child = children[i]\
child:draw()\
child.canvas:drawTo( canvas, child.x, child.y )\
end\
\
self.changed = false\
end\
end\
\
function View:update( dt )\
if type( dt ) ~= \"number\" then return error( \"expected number dt, got \" .. class.type( dt ) ) end\
\
self:updateAnimations( dt )\
\
local c = {}\
for i = 1, #self.children do\
c[i] = self.children[i]\
end\
\
for i = #c, 1, -1 do\
c[i]:update( dt )\
end\
end\
\
function View:handle( event )\
\
local c = orderChildren( self.children )\
\
if event:typeOf( MouseEvent ) then\
local within = event:isWithinArea( 0, 0, self.width, self.height )\
for i = #c, 1, -1 do\
c[i]:handle( event:clone( c[i].x, c[i].y, within ) )\
end\
else\
for i = #c, 1, -1 do\
c[i]:handle( event )\
end\
end\
\
if event:typeOf( MouseEvent ) then\
self:onMouseEvent( event )\
elseif event:typeOf( KeyboardEvent ) then\
self:onKeyboardEvent( event )\
end\
end\
\
function View:onMouseEvent( event )\
-- click callbacks\
end\
\
function View:onKeyboardEvent( event )\
-- keyboard shortcut callbacks\
end\
\
Theme.addToTemplate( View, \"colour\", {\
default = 1;\
} )\
\
local decoder = SMLNodeDecoder \"view\"\
\
decoder.isBodyAllowed = true\
decoder.isBodyNecessary = false\
\
decoder:implement( ICommonAttributes )\
decoder:implement( IPositionAttributes )\
decoder:implement( IAnimatedPositionAttributes )\
decoder:implement( IThemeAttribute )\
\
function decoder:init( parent )\
return View( 0, 0, parent.width, parent.height )\
end\
\
function decoder:decodeBody( body )\
local children = IChildDecoder.decodeChildren( self, body )\
\
for i = 1, #children do\
if children[i]:typeOf( Sheet ) then\
self:addChild( children[i] )\
else\
return error( \"[\" .. body[i].position.line .. \", \" .. body[i].position.character .. \"]: child not a sheet\", 0 )\
end\
end\
end\
\
SMLDocument:addElement( \"view\", View, decoder )","sheets.View",nil,_ENV)if not __f then error(__err,0)end __f()

SMLDocument:setVariable( "transparent", 0 )
SMLDocument:setVariable( "white", 1 )
SMLDocument:setVariable( "orange", 2 )
SMLDocument:setVariable( "magenta", 4 )
SMLDocument:setVariable( "lightBlue", 8 )
SMLDocument:setVariable( "yellow", 16 )
SMLDocument:setVariable( "lime", 32 )
SMLDocument:setVariable( "pink", 64 )
SMLDocument:setVariable( "grey", 128 )
SMLDocument:setVariable( "lightGrey", 256 )
SMLDocument:setVariable( "cyan", 512 )
SMLDocument:setVariable( "purple", 1024 )
SMLDocument:setVariable( "blue", 2048 )
SMLDocument:setVariable( "brown", 4096 )
SMLDocument:setVariable( "green", 8192 )
SMLDocument:setVariable( "red", 16384 )
SMLDocument:setVariable( "black", 32768 )









class "UIButton" extends "Sheet" implements (IHasText) {
down = false;
vertical_alignment = 1;
horizontal_alignment = 1;
}

function UIButton:UIButton( x, y, width, height, text )
self.text = text
return self:Sheet( x, y, width, height )
end

function UIButton:onPreDraw()
self.canvas:clear( self.theme:getField( self.class, "colour", self.down and "pressed" or "default" ) )
self:drawText( self.down and "pressed" or "default" )
end

function UIButton:onMouseEvent( event )
if event:is( 1 ) and self.down then
self.down = false
self:setChanged()
end

if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then
return
end

if event:is( 0 ) and not self.down then
self.down = true
self:setChanged()
event:handle()
elseif event:is( 2 ) then
if self.onClick then
self:onClick( event.button, event.x, event.y )
end
event:handle()
elseif event:is( 3 ) then
if self.onHold then
self:onHold( event.button, event.x, event.y )
end
event:handle()
elseif event:is( 1 ) and self.down then
event:handle()
end
end

Theme.addToTemplate( UIButton, "colour", {
default = 512;
pressed = 8;
} )
Theme.addToTemplate( UIButton, "textColour", {
default = 1;
pressed = 1;
} )

local decoder = SMLNodeDecoder()

decoder.isBodyAllowed = false
decoder.isBodyNecessary = false

decoder:implement( ICommonAttributes )
decoder:implement( IPositionAttributes )
decoder:implement( IAnimatedPositionAttributes )
decoder:implement( IThemeAttribute )
decoder:implement( ITextAttributes )

function decoder:init()
return UIButton( 0, 0, 10, 3 )
end

SMLDocument:addElement( "button", UIButton, decoder )

local document = SMLDocument()

local app, err = document:loadSMLApplicationFile "test/main.sml"

if not app then
return error( err, 0 )
end

app:run()