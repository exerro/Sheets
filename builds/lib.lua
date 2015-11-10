





































local env = setmetatable( {}, { __index = _ENV } )
local function f()
local _ENV = env
if setfenv then
setfenv( 1, env )
end


























event = {
mouse_down = 0;
mouse_up = 1;
mouse_click = 2;
mouse_hold = 3;
mouse_drag = 4;
mouse_scroll = 5;
mouse_ping = 6;
key_down = 7;
key_up = 8;
text = 9;
voice = 10;
paste = 11;
}

alignment = {
left = 0;
centre = 1;
center = 1;
right = 2;
top = 3;
bottom = 4;
}







































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
local __f,__err=load("\
\
\
\
class = {}\
local classobj = setmetatable( {}, { __index = class } )\
local names = {}\
local last_created\
\
local supportedMetaMethods = {\
__add = true;\
__sub = true;\
__mul = true;\
__div = true;\
__mod = true;\
__pow = true;\
__unm = true;\
__len = true;\
__eq = true;\
__lt = true;\
__lte = true;\
__tostring = true;\
__concat = true;\
}\
\
local function _tostring( self )\
return \"[Class] \" .. self:type()\
end\
local function _concat( a, b )\
return tostring( a ) .. tostring( b )\
end\
\
local function newSuper( object, super )\
\
local superProxy = {}\
\
if super.super then\
superProxy.super = newSuper( object, super.super )\
end\
\
setmetatable( superProxy, { __index = function( t, k )\
\
if type( super[k] ) == \"function\" then\
return function( self, ... )\
\
if self == superProxy then\
self = object\
end\
object.super = superProxy.super\
local v = { super[k]( self, ... ) }\
object.super = superProxy\
return unpack( v )\
\
end\
else\
return super[k]\
end\
\
end, __newindex = super, __tostring = function( self )\
return \"[Super] \" .. tostring( super ) .. \" of \" .. tostring( object )\
end } )\
\
return superProxy\
\
end\
\
function classobj:new( ... )\
\
local mt = { __index = self, __INSTANCE = true }\
local instance = setmetatable( { class = self, meta = mt }, mt )\
\
if self.super then\
instance.super = newSuper( instance, self.super )\
end\
\
for k, v in pairs( self.meta ) do\
if supportedMetaMethods[k] then\
mt[k] = v\
end\
end\
\
if mt.__tostring == _tostring then\
function mt:__tostring()\
return self:tostring()\
end\
end\
\
function instance:type()\
return self.class:type()\
end\
\
function instance:typeOf( class )\
return self.class:typeOf( class )\
end\
\
if not self.tostring then\
function instance:tostring()\
return \"[Instance] \" .. self:type()\
end\
end\
\
local ob = self\
while ob do\
if ob[ob.meta.__type] then\
ob[ob.meta.__type]( instance, ... )\
break\
end\
ob = ob.super\
end\
\
return instance\
\
end\
\
function classobj:extends( super )\
self.super = super\
self.meta.__index = super\
end\
\
function classobj:type()\
return tostring( self.meta.__type )\
end\
\
function classobj:typeOf( super )\
return super == self or ( self.super and self.super:typeOf( super ) ) or false\
end\
\
function classobj:implement( t )\
if type( t ) ~= \"table\" then\
return error( \"cannot implement non-table\" )\
end\
for k, v in pairs( t ) do\
self[k] = v\
end\
return self\
end\
\
function classobj:implements( t )\
if type( t ) ~= \"table\" then\
return error( \"cannot compare non-table\" )\
end\
for k, v in pairs( t ) do\
if type( self[k] ) ~= type( v ) then\
return false\
end\
end\
return true\
end\
\
function class:new( name )\
\
if type( name or self ) ~= \"string\" then\
return error( \"expected string class name, got \" .. type( name or self ) )\
end\
\
local mt = { __index = classobj, __CLASS = true, __tostring = _tostring, __concat = _concat, __call = classobj.new, __type = name or self }\
local obj = setmetatable( { meta = mt }, mt )\
\
names[name] = obj\
last_created = obj\
\
_ENV[name] = obj\
\
return function( t )\
if not last_created then\
return error \"no class to define\"\
end\
\
for k, v in pairs( t ) do\
last_created[k] = v\
end\
last_created = nil\
end\
\
end\
\
function class.type( object )\
local _type = type( object )\
\
if _type == \"table\" then\
pcall( function()\
local mt = getmetatable( object )\
_type = ( ( mt.__CLASS or mt.__INSTANCE ) and object:type() ) or _type\
end )\
end\
\
return _type\
end\
\
function class.typeOf( object, class )\
if type( object ) == \"table\" then\
local ok, v = pcall( function() return getmetatable( object ).__CLASS or getmetatable( object ).__INSTANCE or error() end )\
return ok and object:typeOf( class )\
end\
\
return false\
end\
\
function class.isClass( object )\
return pcall( function() if not getmetatable( object ).__CLASS then error() end end ), nil\
end\
\
function class.isInstance( object )\
return pcall( function() if not getmetatable( object ).__INSTANCE then error() end end ), nil\
end\
\
setmetatable( class, {\
__call = class.new;\
} )\
\
function extends( name )\
\
if not last_created then\
return error \"no class to extend\"\
end\
\
if not names[name] then\
return error( \"no such class '\" .. tostring( name ) .. \"'\" )\
end\
\
last_created:extends( names[name] )\
\
return function( t )\
if not last_created then\
return error \"no class to define\"\
end\
\
for k, v in pairs( t ) do\
last_created[k] = v\
end\
last_created = nil\
end\
\
end\
\
function implements( name )\
\
if not last_created then\
return error \"no class to modify\"\
end\
\
if type( name ) == \"string\" then\
if not names[name] then\
return error( \"no such class '\" .. tostring( name ) .. \"'\" )\
end\
last_created:implement( names[name] )\
elseif type( name ) == \"table\" then\
last_created:implement( name )\
else\
return error( \"Cannot implement type (\" .. class.type( name ) .. \")\" )\
end\
\
return function( t )\
if not last_created then\
return error \"no class to define\"\
end\
\
for k, v in pairs( t ) do\
last_created[k] = v\
end\
last_created = nil\
end\
\
end","class",nil,_ENV)if not __f then error(__err,0)end __f()






















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
[2] = 16384;
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
function area.correctedCircle( x, y, radius )\\\
local radius2 = radius * radius\\\
local t = {}\\\
local i = 1\\\
\\\
for yy = math.floor( y - radius + 1 ), math.ceil( y + radius - 1 ) do\\\
if yy >= 0 and yy < height then\\\
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
--[[ Need to do\
Image\
load\
loadString\
save\
saveString\
\
area.lua\
area.triangle implemented\
\
DrawingCanvas\
drawEllipse\
drawArc\
\
floodFill\
\
drawSurfacePart\
drawSurfaceScaled\
drawSurfaceRotated\
\
TermCanvas\
getRedirect\
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
local l = #pixels\
local pxls = self.pixels\
local modNeeded = l < #coords\
for i = 1, #coords do\
local px = modNeeded and pixels[( i - 1 ) % l + 1] or pixels[i]\
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
local px = { colour or self.colour, 0, \" \" }\
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
\
\
\
canvas:drawPixels( toDrawCoords, toDrawPixels )\
\
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
return area.correctedCircle( a, b, c )\
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
local diff = x >= 0 and 0 or -x\
local t, p = {}, {}\
local w, w2 = sWidth - ( x > 0 and x or 0 ), #text - diff\
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
local t = {}\
\
self.last = {}\
for i = 1, width * height do\
self.last[i] = t\
end\
\
return self:Canvas( width, height )\
end\
\
function ScreenCanvas:reset()\
local t = {}\
for i = 1, width * height do\
self.last[i] = t\
end\
end\
\
function ScreenCanvas:drawToTerminals( terminals, sx, sy )\
sx = sx or 0\
sy = sy or 0\
\
if type( terminals ) ~= \"table\" then\
return error( \"expected table terminals, got \" .. class.type( terminals ) )\
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
if px[1] ~= ltpx[1] or px[2] ~= ltpx[2] or px[3] ~= ltpx[3] then\
changed = true\
last[i] = px\
end\
\
i = i + 1\
end\
\
if changed then\
local bc, tc, s = {}, {}, {}\
i = i - sWidth\
for x = 1, sWidth do\
local px = pixels[i]\
bc[x] = hex[px[1]] or \"0\"\
tc[x] = hex[px[2]] or \"0\"\
s[x] = px[3] == \"\" and \" \" or px[3]\
i = i + 1\
end\
for i = 1, #terminals do\
terminals[i].setCursorPos( sx + 1, sy + y )\
terminals[i].blit( table.concat( s ), table.concat( tc ), table.concat( bc ) )\
end\
end\
end\
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
if px[1] ~= ltpx[1] or px[2] ~= ltpx[2] or px[3] ~= ltpx[3] then\
changed = true\
last[i] = px\
end\
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
local hexLookup = {}\
for i = 0, 15 do\
hexLookup[2 ^ i] = (\"%x\"):format( i )\
hexLookup[(\"%x\"):format( i )] = 2 ^ i\
hexLookup[(\"%X\"):format( i )] = 2 ^ i\
end\
\
image = {}\
\
function image.decodePaintutils( str, canvas )\
local lines = {}\
for line in str:gmatch \"[^\\n]+\" do\
local decodedLine = {}\
for i = 1, #line do\
\
\
\
decodedLine[i] = { hexLookup[ line:sub( i, i ) ] or 0, 1, \" \" }\
\
end\
lines[#lines + 1] = decodedLine\
end\
return lines\
end\
\
function image.encodePaintutils( canvas )\
\
end\
\
function image.apply( map, canvas )\
local pixels, coords = {}, {}\
local n = 1\
\
for y = 0, math.min( #map, canvas.height ) - 1 do\
local pos = y * canvas.width\
for x = 1, math.min( #map[y + 1], canvas.width ) do\
pixels[n] = map[y + 1][x]\
coords[n] = pos + x\
n = n + 1\
end\
end\
\
\
\
\
canvas:mapPixels( coords, pixels )\
\
end","graphics.image",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("\
timer = {}\
\
local timers = {}\
local timerID = 0\
local t, lt = os.clock()\
\
function timer.new( n )\
functionParameters.check( 1, \"n\", \"number\", n )\
\
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
functionParameters.check( 2, \"n\", \"number\", n, \"response\", \"function\", response )\
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
functionParameters.check( 1, \"ID\", \"number\", ID )\
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
local c = {}\
\
clipboard = {}\
\
function clipboard.put( modes )\
functionParameters.check( 1, \"modes\", \"table\", modes )\
c = modes\
end\
\
function clipboard.get( mode )\
functionParameters.check( 1, \"mode\", \"string\", mode )\
return c[mode]\
end\
\
function clipboard.clear()\
c = {}\
end","sheets.clipboard",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("\
\
\
\
\
\
\
\
\
local ID = 0\
local exceptions = {}\
local thrownExceptionID\
\
local function __tostring( e )\
local trace = \"\"\
for i = 1, #e.trace do\
trace = trace .. \"\\n in \" .. e.trace[i]\
end\
return textutils.serialize( e.data ) .. trace\
end\
\
local function handler( t )\
local exception = exceptions[thrownExceptionID]\
for i = 1, #t do\
if t[i].catch == exception.name or t[i].default then\
return t[i].handler( exception )\
end\
end\
end\
\
local function exception( name, data, call_level )\
if type( name ) ~= \"string\" then return error( \"expected string name, got \" .. class.type( name ) ) end\
\
local function f( data, call_level )\
local e = setmetatable( { name = name, ID = ID }, { __tostring = __tostring } )\
local level = ( call_level or 1 ) + 1\
local trace = {}\
\
for i = 1, 5 do\
local src = select( 2, pcall( error, \"\", i + level ) )\
if src == \"pcall: \" then\
break\
else\
trace[i] = src:gsub( \":%s$\", \"\", 1 )\
end\
end\
\
e.data = data\
e.trace = trace\
exceptions[ID] = e\
ID = ID + 1\
\
return e\
end\
\
if data == nil and call_level == nil then\
return f\
else\
return f( data, call_level )\
end\
end\
\
function throw( exception, data )\
if type( exception ) == \"string\" then\
if not data then\
return function( data )\
return throw( exception, data, 2 )\
end\
end\
exception = Exception( exception, data, 2 )\
end\
return error( \"SheetsException-\" .. exception.ID, 0 )\
end\
\
function try( func )\
local ok, err = pcall( func )\
\
if not ok and type( err ) == \"string\" then\
local ID = err:match \"SheetsException%-(%d+)\"\
if ID then\
thrownExceptionID = tonumber( ID )\
return handler\
end\
end\
\
return error( err, 0 )\
end\
\
function catch( etype )\
return function( handler )\
return { catch = etype, handler = handler }\
end\
end\
\
function default( handler )\
return { default = true, handler = handler }\
end\
\
IncorrectParameterException = exception \"IncorrectParameterException\"\
IncorrectConstructorException = exception \"IncorrectConstructorException\"","sheets.exception",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
functionParameters = {}\
\
function functionParameters.checkConstructor( _class, argc, ... )\
local args = { ... }\
for i = 1, argc * 3, 3 do\
local name = args[i]\
local expectedType = args[i + 1]\
local value = args[i + 2]\
\
if type( expectedType ) == \"string\" then\
if type( value ) ~= expectedType then\
throw( IncorrectConstructorException( _class:type() .. \" expects \" .. expectedType .. \" \" .. name .. \" when created, got \" .. class.type( value ), 4 ) )\
end\
else\
if not class.typeOf( value, expectedType ) then\
throw( IncorrectConstructorException( _class:type() .. \" expects \" .. expectedType:type() .. \" \" .. name .. \" when created, got \" .. class.type( value ), 4 ) )\
end\
end\
end\
end\
\
function functionParameters.check( argc, ... )\
local args = { ... }\
for i = 1, argc * 3, 3 do\
local name = args[i]\
local expectedType = args[i + 1]\
local value = args[i + 2]\
\
if type( expectedType ) == \"string\" then\
if type( value ) ~= expectedType then\
throw( IncorrectParameterException( \"expected \" .. expectedType .. \" \" .. name .. \", got \" .. class.type( value ), 3 ) )\
end\
else\
if not class.typeOf( value, expectedType ) then\
throw( IncorrectParameterException( \"expected \" .. expectedType:type() .. \" \" .. name .. \", got \" .. class.type( value ), 3 ) )\
end\
end\
end\
end","sheets.functionParameters",nil,_ENV)if not __f then error(__err,0)end __f()

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
functionParameters.check( 3,\
\"label\", \"string\", label,\
\"setter\", \"function\", setter,\
\"animation\", Animation, animation\
)\
\
self.animations[label] = {\
setter = setter;\
animation = animation;\
}\
if animation.value then\
setter( self, animation.value )\
end\
\
return animation\
end\
\
function IAnimation:stopAnimation( label )\
functionParameters.check( 1, \"label\", \"string\", label )\
\
local a = self.animations[label]\
self.animations[label] = nil\
return a\
end\
\
function IAnimation:updateAnimations( dt )\
functionParameters.check( 1, \"dt\", \"number\", dt )\
\
local finished = {}\
local animations = self.animations\
local k, v = next( animations )\
\
while animations[k] do\
\
local animation = v.animation\
animation:update( dt )\
if animation.value then\
v.setter( self, animation.value )\
end\
\
if animation:finished() then\
finished[#finished + 1] = k\
end\
\
k, v = next( animations, k )\
end\
\
for i = 1, #finished do\
self.animations[finished[i]] = nil\
end\
end","sheets.interfaces.core.IAnimation",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
IChildContainer = {\
children = {}\
}\
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
functionParameters.check( 1, \"child\", Sheet, child )\
\
local children = self.children\
\
if child.parent then\
child.parent:removeChild( child )\
end\
\
child.parent = self\
self:setChanged()\
\
for i = 1, #children do\
if children[i].z > child.z then\
table.insert( children, i, child )\
return child\
end\
end\
\
children[#children + 1] = child\
return child\
end\
\
function IChildContainer:removeChild( child )\
for i = 1, #self.children do\
if self.children[i] == child then\
child.parent = nil\
self:setChanged()\
return table.remove( self.children, i )\
end\
end\
end\
\
function IChildContainer:repositionChildZIndex( child )\
local children = self.children\
\
for i = 1, #children do\
if children[i] == child then\
while children[i-1] and children[i-1].z > child.z do\
children[i-1], children[i] = child, children[i-1]\
i = i - 1\
end\
while children[i+1] and children[i+1].z < child.z do\
children[i+1], children[i] = child, children[i+1]\
i = i + 1\
end\
\
self:setChanged()\
break\
end\
end\
end\
\
function IChildContainer:getChildById( id )\
functionParameters.check( 1, \"id\", \"string\", id )\
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
functionParameters.check( 1, \"id\", \"string\", id )\
\
local t = {}\
for i = #self.children, 1, -1 do\
local subt = self.children[i]:getChildrenById( id )\
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
function IChildContainer:getChildrenAt( x, y )\
functionParameters.check( 2, \"x\", \"number\", x, \"y\", \"number\", y )\
\
local c = {}\
local children = self.children\
for i = 1, #children do\
c[i] = children[i]\
end\
\
local elements = {}\
\
for i = #c, 1, -1 do\
c[i]:handle( MouseEvent( EVENT_MOUSE_PING, x - c[i].x, y - c[i].y, elements, true ) )\
end\
\
return elements\
end\
\
function IChildContainer:isChildVisible( child )\
functionParameters.check( 1, \"child\", Sheet, child )\
\
return child.x + child.width > 0 and child.y + child.height > 0 and child.x < self.width and child.y < self.height\
end\
\
function IChildContainer:update( dt )\
local c = {}\
local children = self.children\
\
self:updateAnimations( dt )\
\
if self.onUpdate then\
self:onUpdate( dt )\
end\
\
for i = 1, #children do\
c[i] = children[i]\
end\
\
for i = #c, 1, -1 do\
c[i]:update( dt )\
end\
end","sheets.interfaces.core.IChildContainer",nil,_ENV)if not __f then error(__err,0)end __f()
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
id = \"ID\";\
style = nil;\
cursor_x = 0;\
cursor_y = 0;\
cursor_colour = 0;\
cursor_active = false;\
}\
\
function ICommon:ICommon()\
self.style = Style( self )\
end\
\
function ICommon:setChanged( state )\
self.changed = state ~= false\
if state ~= false and self.parent and not self.parent.changed then\
self.parent:setChanged( true )\
end\
return self\
end\
\
function ICommon:setID( id )\
self.id = tostring( id )\
return self\
end\
\
function ICommon:setStyle( style, children )\
functionParameters.check( 1, \"style\", Style, style )\
\
self.style = style:clone( self )\
\
if children and self.children then\
for i = 1, #self.children do\
self.children[i]:setStyle( style, true )\
end\
end\
\
self:setChanged( true )\
return self\
end\
\
function ICommon:setCursorBlink( x, y, colour )\
colour = colour or 128\
\
functionParameters.check( 3, \"x\", \"number\", x, \"y\", \"number\", y, \"colour\", \"number\", colour )\
\
self.cursor_active = true\
self.cursor_x = x\
self.cursor_y = y\
self.cursor_colour = colour\
return self\
end\
\
function ICommon:resetCursorBlink()\
self.cursor_active = false\
return self\
end","sheets.interfaces.core.ICommon",nil,_ENV)if not __f then error(__err,0)end __f()
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
end","sheets.interfaces.core.IEvent",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IHasParent = {\
parent = nil;\
}\
\
function IHasParent:setParent( parent )\
-- fix this\
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
end\
\
function IHasParent:bringToFront()\
if self.parent then\
return self:setParent( self.parent )\
end\
return self\
end\
\
function IHasParent:getRootParent()\
local p = self.parent\
if p then\
while p.parent do\
p = p.parent\
end\
return p\
end\
end","sheets.interfaces.core.IHasParent",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
IPosition = {\
x = 0;\
y = 0;\
z = 0;\
\
width = 0;\
height = 0;\
}\
\
function IPosition:IPosition( x, y, width, height )\
self.x = x\
self.y = y\
self.width = width\
self.height = height\
end\
\
function IPosition:setX( x )\
functionParameters.check( 1, \"x\", \"number\", x )\
\
if self.x ~= x then\
self.x = x\
if self.parent then self.parent:setChanged( true ) end\
end\
return self\
end\
\
function IPosition:setY( y )\
functionParameters.check( 1, \"y\", \"number\", y )\
\
if self.y ~= y then\
self.y = y\
if self.parent then self.parent:setChanged( true ) end\
end\
return self\
end\
\
function IPosition:setZ( z )\
functionParameters.check( 1, \"z\", \"number\", z )\
\
if self.z ~= z then\
self.z = z\
if self.parent then self.parent:repositionChildZIndex( self ) end\
end\
return self\
end\
\
function IPosition:setWidth( width )\
functionParameters.check( 1, \"width\", \"number\", width )\
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
functionParameters.check( 1, \"height\", \"number\", height )\
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
end","sheets.interfaces.core.IPosition",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
local function animateAttribute( self, label, setter, from, to, time, easing )\
easing = easing or \"transition\"\
\
functionParameters.check( 3, \"to\", \"number\", to, \"time\", \"number\", time or 0, \"easing\", type( easing ) == \"string\" and \"string\" or \"function\", easing )\
\
local a = Animation():setRounded()\
:addKeyFrame( from, to, time or .3, easing )\
self:addAnimation( label, setter, a )\
return a\
end\
\
local function animateElementInOrOut( self, mode, vertical, current, to, time )\
if not self.parent then\
return\
end\
\
local a = Animation():setRounded():addKeyFrame( current, to, time, mode == \"in\" and \"entrance\" or \"exit\" )\
\
if vertical then\
self:addAnimation( \"y\", self.setY, a )\
else\
self:addAnimation( \"x\", self.setX, a )\
end\
if mode == \"exit\" then\
function a.onFinish() self:remove() end\
end\
\
return a\
end\
\
IPositionAnimator = {}\
\
function IPositionAnimator:animateX( to, time, easing )\
return animateAttribute( self, \"x\", self.setX, self.x, to, time, easing )\
end\
\
function IPositionAnimator:animateY( to, time, easing )\
return animateAttribute( self, \"y\", self.setY, self.y, to, time, easing )\
end\
\
function IPositionAnimator:animateZ( to, time, easing )\
return animateAttribute( self, \"z\", self.setZ, self.z, to, time, easing )\
end\
\
function IPositionAnimator:animateWidth( to, time, easing )\
return animateAttribute( self, \"width\", self.setWidth, self.width, to, time, easing )\
end\
\
function IPositionAnimator:animateHeight( to, time, easing )\
return animateAttribute( self, \"height\", self.setHeight, self.height, to, time, easing )\
end\
\
function IPositionAnimator:animateIn( side, to, time )\
side = side or \"top\"\
time = time or .3\
\
functionParameters.check( 3, \"side\", \"string\", side, \"to\", \"number\", to or 0, \"time\", \"number\", time )\
\
if side == \"top\" then\
return animateElementInOrOut( self, \"in\", true, self.y, to or 0, time )\
elseif side == \"left\" then\
return animateElementInOrOut( self, \"in\", false, self.x, to or 0, time )\
elseif side == \"right\" then\
return animateElementInOrOut( self, \"in\", false, self.x, to or self.parent.width - self.width, time )\
elseif side == \"bottom\" then\
return animateElementInOrOut( self, \"in\", true, self.y, to or self.parent.height - self.height, time )\
else\
throw( IncorrectParameterException( \"invalid side '\" .. side .. \"'\", 2 ) )\
end\
end\
\
function IPositionAnimator:animateOut( side, to, time )\
side = side or \"top\"\
time = time or .3\
\
functionParameters.check( 3, \"side\", \"string\", side, \"to\", \"number\", to or 0, \"time\", \"number\", time )\
\
if side == \"top\" then\
return animateElementInOrOut( self, \"out\", true, self.y, to or -self.height, time )\
elseif side == \"left\" then\
return animateElementInOrOut( self, \"out\", false, self.x, to or -self.width, time )\
elseif side == \"right\" then\
return animateElementInOrOut( self, \"out\", false, self.x, to or self.parent.width, time )\
elseif side == \"bottom\" then\
return animateElementInOrOut( self, \"out\", true, self.y, to or self.parent.height, time )\
else\
throw( IncorrectParameterException( \"invalid side '\" .. side .. \"'\", 2 ) )\
end\
end","sheets.interfaces.core.IPositionAnimator",nil,_ENV)if not __f then error(__err,0)end __f()

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
text_lines = nil;\
}\
\
function IHasText:autoHeight()\
if not self.text_lines then\
self:wrapText( true )\
end\
return self:setHeight( #self.text_lines )\
end\
\
function IHasText:setText( text )\
functionParameters.check( 1, \"text\", \"string\", text )\
\
self.text = text\
self:wrapText()\
self:setChanged()\
return self\
end\
\
function IHasText:wrapText( ignoreHeight )\
self.text_lines = wrap( self.text, self.width, not ignoreHeight and self.height )\
end\
\
function IHasText:drawText( mode )\
local offset, lines = 0, self.text_lines\
mode = mode or \"default\"\
\
local horizontal_alignment = self.style:getField( \"horizontal-alignment.\" .. mode )\
local vertical_alignment = self.style:getField( \"vertical-alignment.\" .. mode )\
\
if not lines then\
self:wrapText()\
lines = self.text_lines\
end\
\
if vertical_alignment == 1 then\
offset = math.floor( self.height / 2 - #lines / 2 + .5 )\
elseif vertical_alignment == 4 then\
offset = self.height - #lines\
end\
\
for i = 1, #lines do\
\
local xOffset = 0\
if horizontal_alignment == 1 then\
xOffset = math.floor( self.width / 2 - #lines[i] / 2 + .5 )\
elseif horizontal_alignment == 2 then\
xOffset = self.width - #lines[i]\
end\
\
self.canvas:drawText( xOffset, offset + i - 1, lines[i], {\
colour = 0;\
textColour = self.style:getField( \"textColour.\" .. mode );\
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
while text and ( not height or #lines < height ) do\
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
local sin, cos = math.sin, math.cos\
local halfpi = math.pi / 2\
\
local function easing_transition( u, d, t )\
return u + d * ( 3 * t * t - 2 * t * t * t )\
end\
\
local function easing_exit( u, d, t )\
return -d * cos(t * halfpi) + d + u\
end\
\
local function easing_entrance( u, d, t )\
return u + d * sin(t * halfpi)\
end\
\
class \"Animation\" {\
frame = 1;\
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
duration = duration or .5\
easing = easing or easing_transition\
\
if not easing or easing == \"transition\" then\
easing = easing_transition\
elseif easing == \"entrance\" then\
easing = easing_entrance\
elseif easing == \"exit\" then\
easing = easing_exit\
end\
\
functionParameters.check( 4,\
\"initial\", \"number\", initial,\
\"final\", \"number\", final,\
\"duration\", \"number\", duration,\
\"easing\", \"function\", easing\
)\
\
local frame = {\
ease = true;\
clock = 0;\
duration = duration;\
initial = initial;\
difference = final - initial;\
easing = easing;\
}\
\
self.frames[#self.frames + 1] = frame\
\
if #self.frames == 1 then\
self.value = initial\
end\
\
return self\
end\
\
function Animation:addPause( pause )\
pause = pause or 1\
functionParameters.check( 1, \"pause\", \"number\", pause )\
\
local frame = {\
clock = 0;\
duration = pause;\
}\
\
self.frames[#self.frames + 1] = frame\
\
return self\
end\
\
function Animation:frameFinished()\
if type( self.onFrameFinished ) == \"function\" then\
self:onFrameFinished( self.frame )\
end\
\
self.frame = self.frame + 1\
\
if not self.frames[self.frame] and type( self.onFinish ) == \"function\" then\
self:onFinish()\
end\
end\
\
function Animation:update( dt )\
functionParameters.check( 1, \"dt\", \"number\", dt )\
\
local frame = self.frames[self.frame]\
\
if frame then\
frame.clock = math.min( frame.clock + dt, frame.duration )\
\
if frame.ease then\
\
local value = frame.easing( frame.initial, frame.difference, frame.clock / frame.duration )\
if self.rounded then\
value = math.floor( value + .5 )\
end\
\
self.value = value\
\
if frame.clock >= frame.duration then\
self:frameFinished()\
end\
\
end\
\
if frame.clock >= frame.duration then\
self:frameFinished()\
end\
end\
end\
\
function Animation:finished()\
return not self.frames[self.frame]\
end","sheets.Animation",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
local function exceptionHandler( e )\
return error( \"An uncaught \" .. e.name .. \" exception was thrown:\\n\" .. tostring( e ), 0 )\
end\
\
class \"Application\" implements (IChildContainer) implements (IAnimation)\
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
terminals = { term };\
monitor_sides = {};\
\
running = true;\
\
changed = true;\
\
mouse = nil;\
keys = {};\
}\
\
function Application:Application()\
self.width, self.height = term.getSize()\
\
self:IChildContainer()\
self:IAnimation()\
\
self.screen = ScreenCanvas( self.width, self.height )\
end\
\
function Application:stop()\
self.running = false\
return self\
end\
\
function Application:setViewportX( x )\
functionParameters.check( 1, \"x\", \"number\", x )\
\
self.viewportX = x\
self:setChanged()\
return self\
end\
\
function Application:setViewportY( y )\
functionParameters.check( 1, \"y\", \"number\", y )\
\
self.viewportY = y\
self:setChanged()\
return self\
end\
\
function Application:transitionViewport( x, y )\
functionParameters.check( 1, \"x\", \"number\", x )\
functionParameters.check( 1, \"y\", \"number\", y )\
\
local ax, ay -- the animations defined later on\
local dx = x and math.abs( x - self.viewportX ) or 0\
local dy = y and math.abs( y - self.viewportY ) or 0\
\
local xt = .4 * dx / self.width\
if dx > 0 then\
local ax = self:addAnimation( \"viewportX\", self.setViewportX, Animation():setRounded()\
:addKeyFrame( self.viewportX, x, xt, SHEETS_EASING_TRANSITION ) )\
end\
if dy > 0 then\
local ay = self:addAnimation( \"viewportY\", self.setViewportY, Animation():setRounded()\
:addPause( xt )\
:addKeyFrame( self.viewportY, y, .4 * dy / self.height, SHEETS_EASING_TRANSITION ) )\
end\
return ax, ay\
end\
\
function Application:transitionToView( view )\
functionParameters.check( 1, \"view\", View, view )\
\
if view.parent == self then\
return self:transitionViewport( view.x, view.y )\
else\
throw( IncorrectParameterException( \"View given is not a part of application '\" .. self.name .. \"'\", 2 ) )\
end\
end\
\
function Application:addTerminal( t )\
functionParameters.check( 1, \"redirect\", \"table\", t )\
\
self.terminals[#self.terminals + 1] = t\
self.screen:reset()\
return self\
end\
\
function Application:removeTerminal( t )\
for i = #self.terminals, 1, -1 do\
if self.terminals[i] == t then\
table.remove( self.terminals, i )\
break\
end\
end\
return self\
end\
\
function Application:addMonitor( side )\
functionParameters.check( 1, \"side\", \"string\", side )\
\
if peripheral.getType( side ) == \"monitor\" then\
local r = peripheral.wrap( side )\
self.terminals[#self.terminals + 1] = r\
self.monitor_sides[side] = r\
return self\
else\
return error( \"no monitor on side \" .. tostring( side ) )\
end\
end\
\
function Application:removeMonitor( side )\
functionParameters.check( 1, \"side\", \"string\", side )\
\
for i = #self.terminals, 1, -1 do\
if self.terminals[i] == self.monitor_sides[side] then\
table.remove( self.terminals, i )\
self.monitor_sides[side] = nil\
break\
end\
end\
return self\
end\
\
function Application:positionChildrenInColumn( padding, order )\
padding = padding or 0\
order = order or \"ascending\"\
\
functionParameters.check( 2, \"padding\", \"number\", padding, \"order\", \"string\", order )\
if order ~= \"ascending\" and order ~= \"descending\" then throw( IncorrectParameterException( \"invalid order '\" .. order .. \"', expected 'ascending' or 'descending'\" ) ) end\
\
local children = self.children\
local y = 0\
\
for i = order == \"ascending\" and 1 or #children, order == \"ascending\" and #children or 1, order == \"ascending\" and 1 or -1 do\
children[i].y = y\
y = y + children[i].height + padding\
end\
\
self:setChanged()\
end\
\
function Application:positionChildrenInRow( padding, order )\
padding = padding or 0\
order = order or \"ascending\"\
\
functionParameters.check( 2, \"padding\", \"number\", padding, \"order\", \"string\", order )\
if order ~= \"ascending\" and order ~= \"descending\" then throw( IncorrectParameterException( \"invalid order '\" .. order .. \"', expected 'ascending' or 'descending'\" ) ) end\
\
local children = self.children\
local x = 0\
\
for i = order == \"ascending\" and 1 or #children, order == \"ascending\" and #children or 1, order == \"ascending\" and 1 or -1 do\
children[i].x = x\
x = x + children[i].width + padding\
end\
\
self:setChanged()\
end\
\
function Application:positionChildrenInGrid( hPadding, vPadding, order )\
return error( \"positionChildrenInGrid() not yet supported\" )\
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
x = params[2] - 1, y = params[3] - 1;\
down = true, button = params[1];\
timer = os.startTimer( 1 ), time = os.clock(), moved = false;\
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
elseif event == \"monitor_touch\" and self.monitor_sides[params[1]] then\
handle( MouseEvent( 0, params[2] - 1, params[3] - 1, 1 ) )\
handle( MouseEvent( 1, params[2] - 1, params[3] - 1, 1 ) )\
handle( MouseEvent( 2, params[2] - 1, params[3] - 1, 1 ) )\
\
elseif event == \"chatbox_something\" then\
-- handle( TextEvent( 10, params[1] ) )\
\
elseif event == \"char\" then\
handle( TextEvent( 9, params[1] ) )\
\
elseif event == \"paste\" then\
if self.keys.leftShift or self.keys.rightShift then\
handle( KeyboardEvent( 7, keys.v, { leftCtrl = true, rightCtrl = true } ) )\
else\
handle( TextEvent( 11, params[1] ) )\
end\
\
elseif event == \"key\" then\
handle( KeyboardEvent( 7, params[1], self.keys ) )\
self.keys[keys.getName( params[1] ) or params[1]] = os.clock()\
\
elseif event == \"key_up\" then\
handle( KeyboardEvent( 8, params[1], self.keys ) )\
self.keys[keys.getName( params[1] ) or params[1]] = nil\
\
elseif event == \"term_resize\" then\
self.width, self.height = term.getSize()\
for i = 1, #self.children do\
self.children[i]:onParentResized()\
end\
\
elseif event == \"timer\" and params[1] == self.mouse.timer then\
handle( MouseEvent( 3, self.mouse.x, self.mouse.y, self.mouse.button, true ) )\
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
\
local screen = self.screen\
local children = {}\
local cx, cy, cc\
\
screen:clear()\
\
for i = 1, #self.children do\
children[i] = self.children[i]\
end\
\
for i = 1, #children do\
local child = children[i]\
\
if child:isVisible() then\
child:draw()\
child.canvas:drawTo( screen, child.x - self.viewportX, child.y - self.viewportY )\
\
if child.cursor_active then\
cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour\
end\
end\
end\
\
screen:drawToTerminals( self.terminals )\
\
self.changed = false\
for i = 1, #self.terminals do\
if cx then\
self.terminals[i].setCursorPos( cx + 1, cy + 1 )\
self.terminals[i].setTextColour( cc )\
self.terminals[i].setCursorBlink( true )\
else\
self.terminals[i].setCursorBlink( false )\
end\
end\
end\
end\
\
function Application:run()\
try (function()\
if self.load then\
self:load()\
end\
local t = timer.new( 0 )\
while self.running do\
local event = { coroutine.yield() }\
if event[1] == \"timer\" and event[2] == t then\
t = timer.new( .05 )\
elseif event[1] == \"terminate\" and self.terminateable then\
self:stop()\
else\
self:event( unpack( event ) )\
end\
self:update()\
self:draw()\
end\
end) {\
default (exceptionHandler);\
}\
end\
\
function Application:setChanged( state )\
self.changed = state ~= false\
return self\
end\
\
function Application:addChild( child )\
local children = self.children\
\
functionParameters.check( 1, \"child\", View, child )\
\
child.parent = self\
self:setChanged()\
\
for i = 1, #children do\
if children[i].z > child.z then\
table.insert( children, i, child )\
return child\
end\
end\
\
children[#children + 1] = child\
return child\
end\
\
function Application:isChildVisible( child )\
functionParameters.check( 1, \"child\", View, child )\
\
return child.x - self.viewportX + child.width > 0 and child.y - self.viewportY + child.height > 0 and child.x - self.viewportX < self.width and child.y - self.viewportY < self.height\
end","sheets.Application",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
\
\
\
\
\
\
\
\
local function formatFieldName( name )\
if not name:find \"%.\" then\
return name .. \".default\"\
end\
return name\
end\
\
local function getDefaultFieldName( name )\
return name:gsub( \"%..-$\", \"\", 1 ) .. \".default\"\
end\
\
local template = {}\
\
class \"Style\" {\
fields = {};\
object = nil;\
}\
\
function Style.addToTemplate( cls, fields )\
if not class.isClass( cls ) then throw( IncorrectParameterException( \"expected Class class, got \" .. class.type( cls ), 2 ) ) end\
if type( fields ) ~= \"table\" then throw( IncorrectParameterException( \"expected table fields, got \" .. class.type( fields ), 2 ) ) end\
\
template[cls] = template[cls] or {}\
for k, v in pairs( fields ) do\
template[cls][formatFieldName( k )] = v\
end\
end\
\
function Style:Style( object )\
if not class.isInstance( object ) then throw( IncorrectConstructorException( \"Style expects Instance object when created, got \" .. class.type( object ), 3 ) ) end\
\
template[object.class] = template[object.class] or {}\
self.fields = {}\
self.object = object\
end\
\
function Style:clone( object )\
if not class.isInstance( object ) then throw( IncorrectInitialiserException( \"expected Instance object, got \" .. class.type( object ), 2 ) ) end\
\
local s = Style( object or self.object )\
for k, v in pairs( self.fields ) do\
s.fields[k] = v\
end\
return s\
end\
\
function Style:setField( field, value )\
functionParameters.check( 1, \"field\", \"string\", field )\
\
self.fields[formatFieldName( field )] = value\
self.object:setChanged()\
return self\
end\
\
function Style:getField( field )\
functionParameters.check( 1, \"field\", \"string\", field )\
\
field = formatFieldName( field )\
local default = getDefaultFieldName( field )\
if self.fields[field] ~= nil then\
return self.fields[field]\
elseif self.fields[default] ~= nil then\
return self.fields[default]\
elseif template[self.object.class][field] ~= nil then\
return template[self.object.class][field]\
end\
return template[self.object.class][default]\
end","sheets.Style",nil,_ENV)if not __f then error(__err,0)end __f()

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
held = {};\
}\
\
function KeyboardEvent:KeyboardEvent( event, key, held )\
self:IEvent( event )\
self.key = key\
self.held = held\
end\
\
function KeyboardEvent:matches( hotkey )\
local t\
\
for segment in hotkey:gmatch \"(.*)%-\" do\
if not self.held[segment] or ( t and self.held[segment] < t ) then\
return false\
end\
t = self.held[segment]\
end\
\
return self.key == keys[hotkey:gsub( \".+%-\", \"\" )]\
end\
\
function KeyboardEvent:isHeld( key )\
return self.key == keys[key] or self.held[key]\
end\
\
function KeyboardEvent:tostring()\
return \"KeyboardEvent\"\
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
functionParameters.check( 4,\
\"x\", \"number\", x,\
\"y\", \"number\", y,\
\"width\", \"number\", width,\
\"height\", \"number\", height\
)\
\
return self.x >= x and self.y >= y and self.x < x + width and self.y < y + height\
end\
\
function MouseEvent:clone( x, y, within )\
functionParameters.check( 2,\
\"x\", \"number\", x,\
\"y\", \"number\", y\
)\
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
-- undefined callbacks\
\
-- function Sheet:onPreDraw() end\
-- function Sheet:onPostDraw() end\
-- function Sheet:onUpdate( dt ) end\
-- function Sheet:onKeyboardEvent( event ) end\
-- function Sheet:onTextEvent( event ) end\
\
class \"Sheet\"\
implements (IAnimation)\
implements (ICommon)\
implements (IChildContainer)\
implements (IHasParent)\
implements (IPosition)\
implements (IPositionAnimator)\
{\
canvas = nil\
;\
handlesKeyboard = false;\
handlesText = false;\
}\
\
function Sheet:Sheet( x, y, width, height )\
functionParameters.checkConstructor( self.class, 4,\
\"x\", \"number\", x,\
\"y\", \"number\", y,\
\"width\", \"number\", width,\
\"height\", \"number\", height\
)\
\
self:IAnimation()\
self:IChildContainer()\
self:ICommon()\
self:IPosition( x, y, width, height )\
\
self.canvas = DrawingCanvas( width, height )\
end\
\
function Sheet:tostring()\
return \"[Instance] \" .. self.class:type() .. \" \" .. tostring( self.id )\
end\
\
function Sheet:onParentResized() end\
\
function Sheet:draw()\
if self.changed then\
\
local children = self.children\
local cx, cy, cc\
\
self:resetCursorBlink()\
\
if self.onPreDraw then\
self:onPreDraw()\
end\
\
for i = 1, #children do\
local child = children[i]\
child:draw()\
child.canvas:drawTo( self.canvas, child.x, child.y )\
\
if child.cursor_active then\
cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour\
end\
end\
\
if cx then\
self:setCursorBlink( cx, cy, cc )\
end\
\
if self.onPostDraw then\
self:onPostDraw()\
end\
\
self.changed = false\
end\
end\
\
function Sheet:handle( event )\
local c = {}\
local children = self.children\
for i = 1, #children do\
c[i] = children[i]\
end\
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
elseif event:typeOf( KeyboardEvent ) and self.handlesKeyboard and self.onKeyboardEvent then\
self:onKeyboardEvent( event )\
elseif event:typeOf( TextEvent ) and self.handlesText and self.onTextEvent then\
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
class \"View\"\
implements (IChildContainer)\
implements (IPosition)\
implements (IAnimation)\
implements (IHasParent)\
implements (IPositionAnimator)\
implements (ICommon)\
{\
canvas = nil;\
}\
\
function View:View( x, y, width, height )\
functionParameters.checkConstructor( self.class, 4,\
\"x\", \"number\", x,\
\"y\", \"number\", y,\
\"width\", \"number\", width,\
\"height\", \"number\", height\
)\
\
self:IPosition( x, y, width, height )\
self:IChildContainer()\
self:IAnimation()\
self:ICommon()\
\
self.canvas = DrawingCanvas( width, height )\
end\
\
function View:tostring()\
return \"[Instance] View \" .. tostring( self.id )\
end\
\
function View:draw()\
if self.changed then\
\
local children = self.children\
local canvas = self.canvas\
local cx, cy, cc\
\
self:resetCursorBlink()\
canvas:clear( self.style:getField \"colour\" )\
\
for i = 1, #children do\
local child = children[i]\
child:draw()\
child.canvas:drawTo( canvas, child.x, child.y )\
\
if child.cursor_active then\
cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour\
end\
end\
\
if cx then\
self:setCursorBlink( cx, cy, cc )\
end\
\
self.changed = false\
end\
end\
\
function View:handle( event )\
local c = {}\
local children = self.children\
\
for i = 1, #children do\
c[i] = children[i]\
end\
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
end\
\
Style.addToTemplate( View, {\
colour = 1;\
} )","sheets.View",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"Button\" extends \"Sheet\" implements (IHasText) {\
down = false;\
}\
\
function Button:Button( x, y, width, height, text )\
self.text = text\
return self:Sheet( x, y, width, height )\
end\
\
function Button:onPreDraw()\
self.canvas:clear( self.down and self.style:getField \"colour.pressed\" or self.style:getField \"colour\" )\
self:drawText( self.down and \"pressed\" or \"default\" )\
end\
\
function Button:onMouseEvent( event )\
if event:is( 1 ) and self.down then\
self.down = false\
self:setChanged()\
end\
\
if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then\
return\
end\
\
if event:is( 0 ) and not self.down then\
self.down = true\
self:setChanged()\
event:handle()\
elseif event:is( 2 ) then\
if self.onClick then\
self:onClick( event.button, event.x, event.y )\
end\
event:handle()\
elseif event:is( 3 ) then\
if self.onHold then\
self:onHold( event.button, event.x, event.y )\
end\
event:handle()\
end\
end\
\
Style.addToTemplate( Button, {\
[\"colour\"] = 512;\
[\"colour.pressed\"] = 8;\
[\"textColour\"] = 1;\
[\"textColour.pressed\"] = 1;\
[\"horizontal-alignment\"] = 1;\
[\"horizontal-alignment.pressed\"] = 1;\
[\"vertical-alignment\"] = 1;\
[\"vertical-alignment.pressed\"] = 1;\
} )","sheets.elements.Button",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"Checkbox\" extends \"Sheet\" {\
down = false;\
checked = false;\
}\
\
function Checkbox:Checkbox( x, y, checked )\
self.checked = checked\
self:Sheet( x, y, 1, 1 )\
end\
\
function Checkbox:setWidth() end\
function Checkbox:setHeight() end\
\
function Checkbox:toggle()\
self.checked = not self.checked\
if self.onToggle then\
self:onToggle()\
end\
if self.checked and self.onCheck then\
self:onCheck()\
elseif not self.checked and self.onUnCheck then\
self:onUnCheck()\
end\
self:setChanged()\
end\
\
function Checkbox:onPreDraw()\
self.canvas:drawPoint( 0, 0, {\
colour = self.style:getField( \"colour.\" .. ( ( self.down and \"pressed\" ) or ( self.checked and \"checked\" ) or \"default\" ) );\
textColour = self.style:getField( \"checkColour.\" .. ( self.down and \"pressed\" or \"default\" ) );\
character = self.checked and \"x\" or \" \";\
} )\
end\
\
function Checkbox:onMouseEvent( event )\
if event:is( 1 ) and self.down then\
self.down = false\
self:setChanged()\
end\
\
if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then\
return\
end\
\
if event:is( 0 ) and not self.down then\
self.down = true\
self:setChanged()\
event:handle()\
elseif event:is( 2 ) then\
self:toggle()\
event:handle()\
elseif event:is( 3 ) then\
event:handle()\
end\
end\
\
Style.addToTemplate( Checkbox, {\
[\"colour\"] = 256;\
[\"colour.checked\"] = 256;\
[\"colour.pressed\"] = 128;\
[\"checkColour\"] = 32768;\
[\"checkColour.pressed\"] = 256;\
} )","sheets.elements.Checkbox",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("\
\
\
\
\
\
\
\
\
-- needs to update to new exception system\
\
class \"Container\" extends \"Sheet\" {}\
\
function Container:draw()\
if self.changed then\
\
local children = self.children\
local cx, cy, cc\
\
self:resetCursorBlink()\
\
if self.onPreDraw then\
self:onPreDraw()\
end\
\
for i = 1, #children do\
local child = children[i]\
if child:isVisible() then\
child:draw()\
child.canvas:drawTo( self.canvas, child.x, child.y )\
\
if child.cursor_active then\
cx, cy, cc = child.x + child.cursor_x, child.y + child.cursor_y, child.cursor_colour\
end\
end\
end\
\
if cx then\
self:setCursorBlink( cx, cy, cc )\
end\
\
if self.onPostDraw then\
self:onPostDraw()\
end\
\
self.changed = false\
end\
end\
\
function Container:onPreDraw()\
self.canvas:clear( self.style:getField \"colour\" )\
end\
\
Style.addToTemplate( Container, {\
[\"colour\"] = 1;\
} )","sheets.elements.Container",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"Draggable\" extends \"Sheet\" implements (IHasText) {\
down = false;\
}\
\
function Draggable:Draggable( x, y, width, height, text )\
self.text = text\
return self:Sheet( x, y, width, height )\
end\
\
function Draggable:onPreDraw()\
self.canvas:clear( self.down and self.style:getField \"colour.pressed\" or self.style:getField \"colour\" )\
self:drawText( self.down and \"pressed\" or \"default\" )\
end\
\
function Draggable:onMouseEvent( event )\
if event:is( 1 ) and self.down then\
if self.onDrop then\
self:onDrop( self.down.x, self.down.y )\
end\
self.down = false\
self:setChanged()\
elseif self.down and event:is( 4 ) and not event.handled and event.within then\
self:setX( self.x + event.x - self.down.x )\
self:setY( self.y + event.y - self.down.y )\
if self.onDrag then\
self:onDrag()\
end\
event:handle()\
return\
end\
\
if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then\
return\
end\
\
if event:is( 0 ) and not self.down then\
if self.onPickUp then\
self:onPickUp()\
end\
self.down = { x = event.x, y = event.y }\
self:setChanged()\
self:bringToFront()\
event:handle()\
elseif event:is( 2 ) then\
if self.onClick then\
self:onClick( event.button, event.x, event.y )\
end\
event:handle()\
elseif event:is( 3 ) then\
if self.onHold then\
self:onHold( event.button, event.x, event.y )\
end\
event:handle()\
end\
end\
\
Style.addToTemplate( Draggable, {\
[\"colour\"] = 512;\
[\"colour.pressed\"] = 8;\
[\"textColour\"] = 1;\
[\"textColour.pressed\"] = 1;\
[\"horizontal-alignment\"] = 1;\
[\"horizontal-alignment.pressed\"] = 1;\
[\"vertical-alignment\"] = 1;\
[\"vertical-alignment.pressed\"] = 1;\
} )","sheets.elements.Draggable",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"Image\" extends \"Sheet\" implements (IHasText) {\
down = false;\
image = nil;\
fill = nil;\
}\
\
function Image:Image( x, y, img )\
if type( img ) == \"string\" then\
if fs.exists( img ) then\
local h = fs.open( img, \"r\" )\
if h then\
img = h.readAll()\
h.close()\
end\
end\
img = image.decodePaintutils( img )\
elseif type( img ) ~= \"table\" then\
functionParameters.checkConstructor( self.class, 1, \"image\", \"string\", img ) -- definitely error\
end\
\
local width, height = #( img[1] or \"\" ), #img\
\
self.image = img\
return self:Sheet( x, y, width, height )\
end\
\
function Image:setWidth() end\
function Image:setHeight() end\
\
function Image:onPreDraw()\
local shader = self.style:getField( \"shader.\" .. ( self.down and \"pressed\" or \"default\" ) )\
\
if not self.fill then\
self.fill = self.canvas:getArea( 5 )\
end\
\
image.apply( self.image, self.canvas )\
\
if shader then\
self.canvas:mapShader( self.fill, shader )\
end\
end\
\
function Image:onMouseEvent( event )\
if event:is( 1 ) and self.down then\
self.down = false\
self:setChanged()\
end\
\
if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then\
return\
end\
\
if event:is( 0 ) and not self.down then\
self.down = true\
self:setChanged()\
event:handle()\
elseif event:is( 2 ) then\
if self.onClick then\
self:onClick( event.button, event.x, event.y )\
end\
event:handle()\
elseif event:is( 3 ) then\
if self.onHold then\
self:onHold( event.button, event.x, event.y )\
end\
event:handle()\
end\
end\
\
Style.addToTemplate( Image, {\
[\"shader\"] = false;\
[\"shader.pressed\"] = false;\
} )","sheets.elements.Image",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"KeyHandler\" extends \"Sheet\"\
{\
shortcuts = {};\
handlesKeyboard = true;\
}\
\
function KeyHandler:KeyHandler()\
self.shortcuts = {}\
return self:Sheet( 0, 0, 0, 0 )\
end\
\
function KeyHandler:addShortcut( shortcut, handler )\
functionParameters.check( 2,\
\"shortcut\", \"string\", shortcut,\
\"handler\", \"function\", handler\
)\
self.shortcuts[shortcut] = handler\
end\
\
function KeyHandler:removeShortcut( shortcut )\
functionParameters.check( 1,\
\"shortcut\", \"string\", shortcut\
)\
self.shortcuts[shortcut] = nil\
end\
\
function KeyHandler:onKeyboardEvent( event )\
if not event.handled and event:is( 7 ) then\
local shortcuts = self.shortcuts\
local k, v = next( shortcuts )\
\
while k do\
\
if event:matches( k ) then\
event:handle()\
v( self )\
return\
end\
\
k, v = next( shortcuts, k )\
end\
end\
end\
\
function KeyHandler:draw() end","sheets.elements.KeyHandler",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"Panel\" extends \"Sheet\" {}\
\
function Panel:onPreDraw()\
self.canvas:clear( self.style:getField \"colour\" )\
end\
\
Style.addToTemplate( Panel, {\
[\"colour\"] = 256;\
} )","sheets.elements.Panel",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("\
\
\
\
\
\
\
\
\
-- needs to update to new exception system\
\
class \"ScrollContainer\" extends \"Sheet\" {\
scrollX = 0;\
scrollY = 0;\
\
horizontalPadding = 0;\
verticalPadding = 0;\
\
heldScrollbar = false;\
down = false;\
}\
\
function ScrollContainer:ScrollContainer( x, y, width, height, element )\
if class.typeOf( x, Sheet ) then\
element = x\
x, y, width, height = x.x, x.y, x.width, x.height\
element.x, element.y = 0, 0\
end\
\
functionParameters.checkConstructor( self.class, 4,\
\"x\", \"number\", x,\
\"y\", \"number\", y,\
\"width\", \"number\", width,\
\"height\", \"number\", height,\
\"element\", element and Sheet, element\
)\
\
self:Sheet( x, y, width, height )\
\
if element then\
self:addChild( element )\
end\
end\
\
function ScrollContainer:setScrollX( scroll )\
if type( scroll ) ~= \"number\" then return error( \"expected number scroll, got \" .. class.type( scroll ) ) end\
\
self.scrollX = scroll\
return self:setChanged()\
end\
\
function ScrollContainer:setScrollY( scroll )\
if type( scroll ) ~= \"number\" then return error( \"expected number scroll, got \" .. class.type( scroll ) ) end\
\
self.scrollY = scroll\
return self:setChanged()\
end\
\
function ScrollContainer:getContentWidth()\
local width = self.horizontalPadding\
local children = self.children\
\
for i = 1, #self.children do\
local childWidth = children[i].x + children[i].width + self.horizontalPadding\
if childWidth > width then\
width = childWidth\
end\
end\
\
return width\
end\
\
function ScrollContainer:getContentHeight()\
local height = self.verticalPadding\
local children = self.children\
\
for i = 1, #self.children do\
local childWidth = children[i].y + children[i].height + self.verticalPadding\
if childWidth > height then\
height = childWidth\
end\
end\
\
return height\
end\
\
function ScrollContainer:getDisplayWidth( h, v )\
return v and self.width - 1 or self.width\
end\
\
function ScrollContainer:getDisplayHeight( h, v )\
return h and self.height - 1 or self.height\
end\
\
function ScrollContainer:getActiveScrollbars( cWidth, cHeight )\
if cWidth > self.width or cHeight > self.height then\
return cWidth >= self.width, cHeight >= self.height\
end\
return false, false\
end\
\
function ScrollContainer:getScrollbarSizes( cWidth, cHeight, horizontal, vertical )\
return math.floor( self:getDisplayWidth( horizontal, vertical ) / cWidth * self:getDisplayWidth( horizontal, vertical ) + .5 ), math.floor( self:getDisplayHeight( horizontal, vertical ) / cHeight * self.height + .5 )\
end\
\
function ScrollContainer:getScrollbarPositions( cWidth, cHeight, horizontal, vertical )\
return math.floor( self.scrollX / cWidth * self:getDisplayWidth( horizontal, vertical ) + .5 ), math.floor( self.scrollY / cHeight * self.height + .5 )\
end\
\
function ScrollContainer:draw()\
if self.changed then\
\
local children = self.children\
local cx, cy, cc\
local ox, oy = self.scrollX, self.scrollY\
\
self:resetCursorBlink()\
\
if self.onPreDraw then\
self:onPreDraw()\
end\
\
for i = 1, #children do\
local child = children[i]\
if child:isVisible() then\
child:draw()\
child.canvas:drawTo( self.canvas, child.x - ox, child.y - oy )\
\
if child.cursor_active then\
cx, cy, cc = child.x + child.cursor_x - ox, child.y + child.cursor_y - oy, child.cursor_colour\
end\
end\
end\
\
if cx then\
self:setCursorBlink( cx, cy, cc )\
end\
\
if self.onPostDraw then\
self:onPostDraw()\
end\
\
self.changed = false\
end\
end\
\
function ScrollContainer:handle( event )\
local c = {}\
local ox, oy = self.scrollX, self.scrollY\
local children = self.children\
for i = 1, #children do\
c[i] = children[i]\
end\
\
if self.down and event:is( 1 ) then\
self.down = false\
self.heldScrollbar = false\
self:setChanged()\
event:handle()\
elseif self.down and event:is( 4 ) then\
local cWidth, cHeight = self:getContentWidth(), self:getContentHeight()\
local h, v = self:getActiveScrollbars( cWidth, cHeight )\
\
if self.heldScrollbar == \"h\" then\
self.scrollX = math.max( math.min( math.floor( ( event.x - self.down ) / self:getDisplayWidth( h, v ) * cWidth ), cWidth - self:getDisplayWidth( h, v ) ), 0 )\
self:setChanged()\
event:handle()\
elseif self.heldScrollbar == \"v\" then\
self.scrollY = math.max( math.min( math.floor( ( event.y - self.down ) / self.height * cHeight ), cHeight - self:getDisplayHeight( h, v ) ), 0 )\
self:setChanged()\
event:handle()\
end\
end\
\
if event:typeOf( MouseEvent ) and not event.handled and event:isWithinArea( 0, 0, self.width, self.height ) and event.within then\
local cWidth, cHeight = self:getContentWidth(), self:getContentHeight()\
local h, v = self:getActiveScrollbars( cWidth, cHeight )\
\
if event:is( 0 ) then\
if event.x == self.width - 1 and v then\
local px, py = self:getScrollbarPositions( cWidth, cHeight, h, v )\
local sx, sy = self:getScrollbarSizes( cWidth, cHeight, h, v )\
local down = event.y\
\
if down < px then\
self.scrollY = math.floor( down / self.height * cHeight )\
down = 0\
elseif down >= px + sx then\
self.scrollY = math.floor( ( down - sy + 1 ) / self.height * cHeight )\
down = sy - 1\
else\
down = down - py\
end\
\
self.heldScrollbar = \"v\"\
self.down = down\
self:setChanged()\
event:handle()\
elseif event.y == self.height - 1 and h then\
local px, py = self:getScrollbarPositions( cWidth, cHeight, h, v )\
local sx, sy = self:getScrollbarSizes( cWidth, cHeight, h, v )\
local down = event.x\
\
if down < px then\
self.scrollX = math.floor( down / self:getDisplayWidth( h, v ) * cWidth )\
down = 0\
elseif down >= px + sx then\
self.scrollX = math.floor( ( down - sx + 1 ) / self:getDisplayWidth( h, v ) * cWidth )\
down = sx - 1\
else\
down = down - px\
end\
\
self.heldScrollbar = \"h\"\
self.down = down\
self:setChanged()\
event:handle()\
end\
elseif event:is( 5 ) then\
if v then\
self:setScrollY( math.max( math.min( oy + event.button, cHeight - self:getDisplayHeight( h, v ) ), 0 ) )\
elseif h then\
self:setScrollX( math.max( math.min( ox + event.button, cWidth - self:getDisplayWidth( h, v ) ), 0 ) )\
end\
elseif event:is( 2 ) or event:is( 3 ) then\
event:handle()\
end\
end\
\
if event:typeOf( MouseEvent ) then\
local within = event:isWithinArea( 0, 0, self.width, self.height )\
for i = #c, 1, -1 do\
c[i]:handle( event:clone( c[i].x - ox, c[i].y - oy, within ) )\
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
elseif event:typeOf( KeyboardEvent ) and self.handlesKeyboard and self.onKeyboardEvent then\
self:onKeyboardEvent( event )\
elseif event:typeOf( TextEvent ) and self.handlesText and self.onTextEvent then\
self:onTextEvent( event )\
end\
end\
\
function ScrollContainer:onPreDraw()\
self.canvas:clear( self.style:getField \"colour\" )\
end\
\
function ScrollContainer:onPostDraw()\
local cWidth, cHeight = self:getContentWidth(), self:getContentHeight()\
local h, v = self:getActiveScrollbars( cWidth, cHeight )\
if h or v then\
local px, py = self:getScrollbarPositions( cWidth, cHeight, h, v )\
local sx, sy = self:getScrollbarSizes( cWidth, cHeight, h, v )\
\
if h then\
local c1 = self.style:getField( self.class, \"horizontal-bar\", \"default\" )\
local c2 = self.heldScrollbar == \"h\" and\
self.style:getField( self.class, \"horizontal-bar\", \"active\" )\
or self.style:getField( self.class, \"horizontal-bar\", \"bar\" )\
\
self.canvas:mapColour( self.canvas:getArea( 4, 0, self.height - 1, self:getDisplayWidth( h, v ) ), c1 )\
self.canvas:mapColour( self.canvas:getArea( 4, px, self.height - 1, sx ), c2 )\
end\
if v then\
local c1 = self.style:getField( self.class, \"vertical-bar\", \"default\" )\
local c2 = self.heldScrollbar == \"v\" and\
self.style:getField( self.class, \"vertical-bar\", \"active\" )\
or self.style:getField( self.class, \"vertical-bar\", \"bar\" )\
\
self.canvas:mapColour( self.canvas:getArea( 3, self.width - 1, 0, self.height ), c1 )\
self.canvas:mapColour( self.canvas:getArea( 3, self.width - 1, py, sy ), c2 )\
end\
end\
end\
\
function ScrollContainer:getChildrenAt( x, y )\
functionParameters.check( 2, \"x\", \"number\", x, \"y\", \"number\", y )\
\
local c = {}\
local ox, oy = self.scrollX, self.scrollY\
\
local children = self.children\
for i = 1, #children do\
c[i] = children[i]\
end\
\
local elements = {}\
\
for i = #c, 1, -1 do\
c[i]:handle( MouseEvent( EVENT_MOUSE_PING, x - c[i].x - ox, y - c[i].y - oy, elements, true ) )\
end\
\
return elements\
end\
\
function ScrollContainer:isChildVisible( child )\
functionParameters.check( 1, \"child\", Sheet, child )\
\
local ox, oy = self.scrollX, self.scrollY\
\
return child.x + child.width - ox > 0 and child.y + child.height - oy > 0 and child.x - ox < self.width and child.y - oy < self.height\
end\
\
Style.addToTemplate( ScrollContainer, {\
[\"colour\"] = 1;\
[\"horizontal-bar\"] = 128;\
[\"horizontal-bar.bar\"] = 256;\
[\"horizontal-bar.active\"] = 8;\
[\"vertical-bar\"] = 128;\
[\"vertical-bar.bar\"] = 256;\
[\"vertical-bar.active\"] = 8;\
} )","sheets.elements.ScrollContainer",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("\
\
\
\
\
\
\
\
\
class \"Text\" extends \"Sheet\" implements (IHasText) {}\
\
function Text:Text( x, y, width, height, text )\
self.text = text\
return self:Sheet( x, y, width, height )\
end\
\
function Text:onPreDraw()\
self.canvas:clear( self.style:getField \"colour\" )\
self:drawText \"default\"\
end\
\
Style.addToTemplate( Text, {\
[\"colour\"] = 1;\
[\"textColour\"] = 128;\
[\"horizontal-alignment\"] = 0;\
[\"vertical-alignment\"] = 3;\
} )","sheets.elements.Text",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("\
\
\
\
\
\
\
\
\
-- needs to update to new exception system\
\
local function getSimilarPattern( char )\
local pat = \"^[^_%w%s]+\"\
if char:find \"%s\" then\
pat = \"^%s+\"\
elseif char:find \"[%w_]\" then\
pat = \"^[%w_]+\"\
end\
return pat\
end\
\
local function extendSelection( text, forward, pos )\
local pat = getSimilarPattern( text:sub( pos, pos ) )\
if forward then\
return #( text:match( pat, pos ) or \"\" )\
else\
local reverse = text:reverse()\
local newpos = #text - pos + 1\
return #( reverse:match( pat, newpos ) or \"\" )\
end\
end\
\
local function mask( text, mask )\
if mask then\
return mask:rep( #text )\
end\
return text\
end\
\
class \"TextInput\" extends \"Sheet\" {\
text = \"\";\
cursor = 0;\
scroll = 0;\
selection = false;\
focussed = false;\
handlesKeyboard = true;\
handlesText = true;\
doubleClickData = false;\
}\
\
function TextInput:TextInput( x, y, width )\
return self:Sheet( x, y, width, 1 )\
end\
\
function TextInput:setText( text )\
self.text = tostring( text )\
return self:setChanged()\
end\
\
function TextInput:setScroll( scroll )\
if type( scroll ) ~= \"number\" then return error( \"expected number scroll, got \" .. class.type( scroll ) ) end\
\
self.scroll = scroll\
return self:setChanged()\
end\
\
function TextInput:setCursor( cursor )\
if type( cursor ) ~= \"number\" then return error( \"expected number cursor, got \" .. class.type( cursor ) ) end\
\
self.cursor = math.min( math.max( cursor, 0 ), #self.text )\
if self.cursor == self.selection then\
self.selection = nil\
end\
if self.cursor - self.scroll < 1 then\
self.scroll = math.max( self.cursor - 1, 0 )\
elseif self.cursor - self.scroll > self.width - 1 then\
self.scroll = self.cursor - self.width + 1\
end\
return self:setChanged()\
end\
\
function TextInput:setSelection( position )\
if type( position ) ~= \"number\" then return error( \"expected number position, got \" .. class.type( position ) ) end\
\
self.selection = position\
return self:setChanged()\
end\
\
function TextInput:getSelectedText()\
return self.selection and self.text:sub( math.min( self.cursor, self.selection ) + 1, math.max( self.cursor, self.selection ) )\
end\
\
function TextInput:write( text )\
text = tostring( text )\
\
if self.selection then\
self.text = self.text:sub( 1, math.min( self.cursor, self.selection ) ) .. text .. self.text:sub( math.max( self.cursor, self.selection ) + 1 )\
self:setCursor( math.min( self.cursor, self.selection ) + #text )\
self.selection = false\
else\
self.text = self.text:sub( 1, self.cursor ) .. text .. self.text:sub( self.cursor + 1 )\
self:setCursor( self.cursor + #text )\
end\
return self:setChanged()\
end\
\
function TextInput:focus()\
if not self.focussed then\
self.focussed = true\
if self.onFocus then\
self:onFocus()\
end\
return self:setChanged()\
end\
return self\
end\
\
function TextInput:unfocus()\
if self.focussed then\
self.focussed = false\
if self.onUnFocus then\
self:onUnFocus()\
end\
return self:setChanged()\
end\
return self\
end\
\
function TextInput:onPreDraw()\
self.canvas:clear( self.style:getField( \"colour.\" .. ( self.focussed and \"focussed\" or \"default\" ) ) )\
\
local masking = self.style:getField( \"mask.\" .. ( self.focussed and \"focussed\" or \"default\" ) )\
\
if self.selection then\
local min = math.min( self.cursor, self.selection )\
local max = math.max( self.cursor, self.selection )\
\
self.canvas:drawText( -self.scroll, 0, mask( self.text:sub( 1, min ), masking ), {\
textColour = self.style:getField( \"textColour.\" .. ( self.focussed and \"focussed\" or \"default\" ) );\
} )\
self.canvas:drawText( min - self.scroll, 0, mask( self.text:sub( min + 1, max ), masking ), {\
colour = self.style:getField \"colour.highlighted\";\
textColour = self.style:getField \"textColour.highlighted\";\
} )\
self.canvas:drawText( max - self.scroll, 0, mask( self.text:sub( max + 1 ), masking ), {\
textColour = self.style:getField( \"textColour.\" .. ( self.focussed and \"focussed\" or \"default\" ) );\
} )\
else\
self.canvas:drawText( -self.scroll, 0, mask( self.text, masking ), {\
textColour = self.style:getField( \"textColour.\" .. ( self.focussed and \"focussed\" or \"default\" ) );\
} )\
end\
\
if not self.selection and self.focussed and self.cursor - self.scroll >= 0 and self.cursor - self.scroll < self.width then\
self:setCursorBlink( self.cursor - self.scroll, 0, self.style:getField( \"textColour.\" .. ( self.focussed and \"focussed\" or \"default\" ) ) )\
end\
end\
\
function TextInput:onMouseEvent( event )\
if self.down and event:is( 4 ) then\
self.selection = self.selection or self.cursor\
self:setCursor( event.x + self.scroll + 1 )\
elseif self.down and event:is( 1 ) then\
self.down = false\
end\
\
if event.handled or not event:isWithinArea( 0, 0, self.width, self.height ) or not event.within then\
if event:is( 0 ) then\
self:unfocus()\
end\
return\
end\
\
if event:is( 0 ) then\
self:focus()\
self.selection = nil\
self:setCursor( event.x + self.scroll )\
self.down = true\
event:handle()\
elseif event:is( 2 ) then\
if self.doubleClickData and self.doubleClickData.x == event.x + self.scroll then\
local pos1, pos2 = event.x + self.scroll + 1, event.x + self.scroll + 1\
local pat = getSimilarPattern( self.text:sub( pos1, pos1 ) )\
while self.text:sub( pos1 - 1, pos1 - 1 ):find( pat ) do\
pos1 = pos1 - 1\
end\
while self.text:sub( pos2 + 1, pos2 + 1 ):find( pat ) do\
pos2 = pos2 + 1\
end\
self:setCursor( pos2 )\
self.selection = pos1 - 1\
timer.cancel( self.doubleClickData.timer )\
self.doubleClickData = false\
else\
if self.doubleClickData then\
timer.cancel( self.doubleClickData.timer )\
end\
local t = timer.queue( 0.3, function()\
self.doubleClickData = false\
end )\
self.doubleClickData = { x = event.x + self.scroll, timer = t }\
end\
elseif event:is( 3 ) then\
event:handle()\
end\
end\
\
function TextInput:onKeyboardEvent( event )\
if not self.focussed or event.handled then return end\
\
if event:is( 7 ) then\
if self.selection then\
if event:matches \"left\" then\
if event:isHeld \"leftShift\" or event:isHeld \"rightShift\" then\
local diff = 1\
if event:isHeld \"rightCtrl\" or event:isHeld \"leftCtrl\" then\
diff = extendSelection( self.text, false, self.cursor )\
end\
self:setCursor( self.cursor - diff )\
else\
self:setCursor( math.min( self.cursor, self.selection ) )\
self.selection = nil\
end\
event:handle()\
elseif event:matches \"right\" then\
if event:isHeld \"leftShift\" or event:isHeld \"rightShift\" then\
local diff = 1\
if event:isHeld \"rightCtrl\" or event:isHeld \"leftCtrl\" then\
diff = extendSelection( self.text, true, self.cursor + 1 )\
end\
self:setCursor( self.cursor + diff )\
else\
self:setCursor( math.max( self.cursor, self.selection ) )\
self.selection = nil\
end\
event:handle()\
elseif event:matches \"backspace\" or event:matches \"delete\" then\
self:write \"\"\
event:handle()\
end\
else\
if event:matches \"left\" then\
if event:isHeld \"leftShift\" or event:isHeld \"rightShift\" then\
self.selection = self.cursor\
end\
local diff = 1\
if event:isHeld \"rightCtrl\" or event:isHeld \"leftCtrl\" then\
diff = extendSelection( self.text, false, self.cursor )\
end\
self:setCursor( self.cursor - diff )\
event:handle()\
elseif event:matches \"right\" then\
if event:isHeld \"leftShift\" or event:isHeld \"rightShift\" then\
self.selection = self.cursor\
end\
local diff = 1\
if event:isHeld \"rightCtrl\" or event:isHeld \"leftCtrl\" then\
diff = extendSelection( self.text, true, self.cursor + 1 )\
end\
self:setCursor( self.cursor + diff )\
event:handle()\
elseif event:matches \"backspace\" and self.cursor > 0 then\
self.text = self.text:sub( 1, self.cursor - 1 ) .. self.text:sub( self.cursor + 1 )\
self:setCursor( self.cursor - 1 )\
event:handle()\
elseif event:matches \"delete\" then\
self:setText( self.text:sub( 1, self.cursor ) .. self.text:sub( self.cursor + 2 ) )\
event:handle()\
end\
end\
\
if event:matches \"leftCtrl-a\" or event:matches \"rightCtrl-a\" then\
self.selection = self.selection or self.cursor\
if self.selection > self.cursor then\
self.selection, self.cursor = self.cursor, self.selection\
end\
self:addAnimation( \"selection\", self.setSelection, Animation():setRounded():addKeyFrame( self.selection, 0, .15 ) )\
self:addAnimation( \"cursor\", self.setCursor, Animation():setRounded():addKeyFrame( self.cursor, #self.text, .15 ) )\
event:handle()\
elseif event:matches \"end\" then\
self:addAnimation( \"cursor\", self.setCursor, Animation():setRounded():addKeyFrame( self.cursor, #self.text, .15 ) )\
event:handle()\
elseif event:matches \"home\" then\
self:addAnimation( \"cursor\", self.setCursor, Animation():setRounded():addKeyFrame( self.cursor, 0, .15 ) )\
event:handle()\
elseif event:matches \"enter\" then\
self:unfocus()\
event:handle()\
if self.onEnter then\
return self:onEnter()\
end\
elseif event:matches \"tab\" then\
self:unfocus()\
event:handle()\
if self.onTab then\
return self:onTab()\
end\
elseif event:matches \"v\" and ( event:isHeld \"leftCtrl\" or event:isHeld \"rightCtrl\" ) then\
local text = clipboard.get \"plain-text\"\
if text then\
self:write( text )\
end\
elseif event:matches \"leftCtrl-c\" or event:matches \"rightCtrl-c\" then\
if self.selection then\
clipboard.put {\
[\"plain-text\"] = self:getSelectedText();\
}\
end\
elseif event:matches \"leftCtrl-x\" or event:matches \"rightCtrl-x\" then\
if self.selection then\
clipboard.put {\
[\"plain-text\"] = self:getSelectedText();\
}\
self:write \"\"\
end\
end\
\
event:handle()\
\
end\
end\
\
function TextInput:onTextEvent( event )\
if not event.handled and self.focussed then\
self:write( event.text )\
event:handle()\
end\
end\
\
Style.addToTemplate( TextInput, {\
[\"colour\"] = 256;\
[\"colour.focussed\"] = 256;\
[\"colour.highlighted\"] = 2048;\
[\"textColour\"] = 128;\
[\"textColour.focussed\"] = 128;\
[\"textColour.highlighted\"] = 1;\
[\"mask\"] = false;\
[\"mask.focussed\"] = false;\
} )","sheets.elements.TextInput",nil,_ENV)if not __f then error(__err,0)end __f()



end
f()
local sheets = {}
for k, v in pairs( env ) do
sheets[k] = v
end


return sheets
