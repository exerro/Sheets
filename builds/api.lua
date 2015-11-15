



































































 



























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

local __f,__err=load("class={}local e=setmetatable({},{__index=class})local t={}local a={}\
local o\
local i={__add=true,__sub=true,__mul=true,__div=true,__mod=true,__pow=true,__unm=true,__len=true,__eq=true,__lt=true,__lte=true,__tostring=true,__concat=true}local function n(d)return\"[Class] \"..d:type()end local function s(d,l)return tostring(d)..\
tostring(l)end\
local function h(d)if not o then\
return error\"no class to define\"end for l,u in pairs(d)do o[l]=u end o=nil end\
local function r(d,l)local u={}if l.super then u.super=r(d,l.super)end\
setmetatable(u,{__index=function(c,m)\
if type(l[m])==\
\"function\"then\
return function(f,...)if f==u then f=d end d.super=u.super local w={l[m](f,...)}\
d.super=u return unpack(w)end else return l[m]end end,__newindex=l,__tostring=function(c)\
return\
\"[Super] \"..tostring(l)..\" of \"..tostring(d)end})return u end\
function e:new(...)local d={__index=self,__INSTANCE=true}\
local l=setmetatable({class=self,meta=d},d)if self.super then l.super=r(l,self.super)end for c,m in\
pairs(self.meta)do if i[c]then d[c]=m end end if d.__tostring==n then function d:__tostring()return\
self:tostring()end end function l:type()return\
self.class:type()end function l:typeOf(c)\
return self.class:typeOf(c)end\
if not self.tostring then function l:tostring()return\
\"[Instance] \"..self:type()end end local u=self while u do\
if u[u.meta.__type]then u[u.meta.__type](l,...)break end u=u.super end return l end function e:extends(d)self.super=d self.meta.__index=d end function e:type()return\
tostring(self.meta.__type)end function e:typeOf(d)return\
d==self or(self.super and\
self.super:typeOf(d))or false end\
function class:new(d)\
if type(\
d or self)~=\"string\"then return\
error(\"expected string class name, got \"..type(d or self))end\
local l={__index=e,__CLASS=true,__tostring=n,__concat=s,__call=e.new,__type=d or self}local u=setmetatable({meta=l},l)t[d]=u o=u _ENV[d]=u return\
function(c)if not o then return\
error\"no class to define\"end for m,f in pairs(c)do o[m]=f end o=nil end end\
function class.type(d)local l=type(d)if l==\"table\"then\
pcall(function()local u=getmetatable(d)\
l=(\
(u.__CLASS or u.__INSTANCE)and d:type())or l end)end return l end\
function class.typeOf(d,l)\
if type(d)==\"table\"then\
local u,c=pcall(function()\
return getmetatable(d).__CLASS or\
getmetatable(d).__INSTANCE or error()end)return u and d:typeOf(l)end return false end function class.isClass(d)\
return pcall(function()\
if not getmetatable(d).__CLASS then error()end end),nil end\
function class.isInstance(d)return\
pcall(function()if not\
getmetatable(d).__INSTANCE then error()end end),nil end setmetatable(class,{__call=class.new})\
function extends(d)\
if not o then return\
error\"no class to extend\"elseif not t[d]then return\
error(\"no such class '\"..tostring(d)..\"'\")end o:extends(t[d])return h end\
function interface(d)a[d]={}_ENV[d]=a[d]\
return function(l)if type(l)~=\"table\"then return\
error(\"expected table t, got \"..class.type(l))end\
_ENV[d]=l a[d]=l end end\
function implements(d)\
if not o then return error\"no class to modify\"elseif not a[d]then return error(\"no interface by name '\"..\
tostring(d)..\"'\")end for l,u in pairs(a[d])do o[l]=u end return h end","sheets.class",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("timer={}local e={}local a=0 local o,i=os.clock()\
function timer.new(t)\
parameters.check(1,\"n\",\"number\",t)local n,s=o+t,false\
for h=1,#e do if e[h].time==n then s=e[h].ID break end end return s or os.startTimer(t)end\
function timer.queue(t,n)\
parameters.check(2,\"n\",\"number\",t,\"response\",\"function\",n)local s,h=o+t,false\
for r=1,#e do if e[r].time==s then h=e[r].ID break end end local a=h or os.startTimer(t)\
e[#e+1]={time=s,response=n,ID=a}return a end\
function timer.cancel(t)\
parameters.check(1,\"ID\",\"number\",t)for n=#e,1,-1 do\
if e[n].ID==t then return table.remove(e,n).time-o end end return 0 end function timer.step()i=o o=os.clock()end\
function timer.getDelta()return o-i end function timer.update(a)local t=false for n=#e,1,-1 do if e[n].ID==a then\
table.remove(e,n).response()t=true end end\
return t end\
timer.step()","sheets.timer",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("local e={}clipboard={}function clipboard.put(t)\
parameters.check(1,\"modes\",\"table\",t)e=t end function clipboard.get(t)\
parameters.check(1,\"mode\",\"string\",t)return e[t]end\
function clipboard.clear()e={}end","sheets.clipboard",nil,_ENV)if not __f then error(__err,0)end __f()




















local e={[1]=256,[2]=16384,[4]=1024,[8]=512,[16]=2,[32]=8192,[64]=4,[128]=32768,[256]=128,[512]=2048,[1024]=128,[2048]=128,[4096]=32768,[8192]=128,[16384]=4096,[32768]=32768}
local t={[1]=1,[2]=16,[4]=64,[8]=1,[16]=1,[32]=1,[64]=1,[128]=256,[256]=1,[512]=8,[1024]=4,[2048]=512,[4096]=16384,[8192]=32,[16384]=2,[32768]=128}
local a={[1]=1,[2]=256,[4]=256,[8]=256,[16]=1,[32]=256,[64]=1,[128]=128,[256]=256,[512]=128,[1024]=128,[2048]=128,[4096]=32768,[8192]=128,[16384]=128,[32768]=32768}
local o={[1]=32768,[2]=2048,[4]=8192,[8]=4096,[16]=2048,[32]=1024,[64]=8192,[128]=256,[256]=128,[512]=16384,[1024]=8192,[2048]=16,[4096]=8,[8192]=1024,[16384]=512,[32768]=1}shader={}function shader.darken(i,...)return e[i]or i,...end function shader.lighten(i,...)return t[i]or
i,...end
function shader.greyscale(i,...)return a[i]or i,...end function shader.inverse(i,...)return o[i]or i,...end
local __f,__err=load("\
local e,t=load(\"local function e(l,u,m,f)local d=l>m and l or m\\\
local c=(l+u<m+f and l+u or m+f)-d return d,c end local t,a,o,i local function n(d)return\\\
setmetatable(d,{__add=t,__sub=a,__mod=o,__tostring=i})end\\\
function t(d,l)\\\
local u,m,f=1,1,0 local w={}\\\
while d[u]or l[m]do\\\
if\\\
d[u]and(not l[m]or d[u]<=l[m])then if w[f]~=d[u]then f=f+1 w[f]=d[u]end u=u+1 elseif l[m]and\\\
(not d[u]or d[u]>l[m])then if w[f]~=l[m]then f=f+1 w[f]=l[m]end m=m+1 end end return n(w)end\\\
function a(d,l)local u,m,f=1,1,1 local w={}\\\
while d[u]do while l[m]and l[m]<d[u]do m=m+1 end if\\\
d[u]~=l[m]then w[f]=d[u]f=f+1 end u=u+1 end return n(w)end\\\
function o(d,l)local u,m,f=1,1,1 local w={}\\\
while d[u]do while l[m]and l[m]<d[u]do m=m+1 end if\\\
d[u]==l[m]then w[f]=d[u]f=f+1 end u=u+1 end return n(w)end\\\
function i(d)return\\\"Area of \\\"..#d..\\\" coordinates\\\"end local s,h=term.getSize()local r={}function r.setDimensions(d,l)s,h=d,l end function r.new(d)\\\
return n(d)end function r.blank()return n{}end function r.fill()local d={}for l=1,s*h do d[l]=l end return\\\
n(d)end\\\
function r.point(d,l)if\\\
d>=0 and d<s and l>=0 and l<h then return n{l*s+d+1}end return n{}end\\\
function r.box(d,l,u,c)d,u=e(0,s,d,u)l,c=e(0,h,l,c)local m=l*s+d local f,w={},1 for y=1,c do\\\
for d=1,u do f[w]=m+d w=w+1 end m=m+s end return n(f)end\\\
function r.circle(d,l,u)local c=u*u local m={}local f=1\\\
for w=math.floor(l-u),math.ceil(l+u)do\\\
if w>0 and w<h then local y=l-w local p=(\\\
c-y*y)^.5 local v=w*s+1 local g=math.floor(d-p+.5)local k,q=e(0,s,g,math.ceil(\\\
d+p-.5)-g+1)for b=k,k+\\\
q-1 do m[f]=v+b f=f+1 end end end return n(m)end\\\
function r.correctedCircle(d,l,u)local c=u*u local m={}local f=1\\\
for w=math.floor(l-u+1),math.ceil(l+u-1)do\\\
if\\\
w>=0 and w<h then local y=l-w local p=(c-y*y)^.5*1.5 local v=w*s+1\\\
local g=math.floor(d-p+.5)\\\
local k,q=e(0,s,g,math.ceil(d+p-.5)-g+1)for b=k,k+q-1 do m[f]=v+b f=f+1 end end end return n(m)end\\\
function r.hLine(d,l,u)if l>=0 and l<h then d,u=e(0,s,d,u)local c=l*s+d local m={}for f=1,u do m[f]=c+f end\\\
return n(m)end return n{}end\\\
function r.vLine(d,l,u)if d>=0 and d<s then l,u=e(0,h,l,u)local c=l*s+d+1 local m={}\\\
for f=1,u do m[f]=c c=c+s end return n(m)end return n{}end\\\
function r.line(d,l,u,c)if d>u then d,u=u,d l,c=c,l end local f,w=u-d,c-l\\\
if f==0 then if w==0 then\\\
return newPointArea(d,l,s,h)end return newVLineArea(d,l,w,s,h)elseif w==0 then return\\\
newHLineArea(d,l,f,s,h)end local y={}\\\
if d>=0 and d<s and l>=0 and l<h then\\\
y[1]=\\\
math.floor(l+.5)*s+math.floor(d+.5)+1\\\
if u>=0 and u<s and c>=0 and c<h then y[2]=math.floor(c+.5)*s+math.floor(\\\
u+.5)+1 end elseif u>=0 and u<s and c>=0 and c<h then y[1]=math.floor(c+.5)*s+math.floor(\\\
u+.5)+1 end local p=w/f local v=l-p*d local b=math.min(1/math.abs(p),1)local g=\\\
#y+1 for m=math.max(d,0),math.min(u,s-1),b do\\\
local k=math.floor(p*m+v+.5)\\\
if k>0 and k<h then y[g]=k*s+math.floor(m+.5)+1 g=g+1 end end return n(y)end return r\",\"area\",\
nil,_ENV)if not e then error(t,0)end local a=e()\
local function o(l,u,m,f)local d=l>m and l or m local c=(\
l+u<m+f and l+u or m+f)-d return d,c end local i,n=table.insert,table.remove local s,h=math.min,math.max\
local r=math.floor\
class\"Canvas\"{width=0,height=0,colour=1,pixels={}}\
function Canvas:Canvas(d,l)d=d or 0 l=l or 0\
if type(d)~=\"number\"then return\
error(\"element attribute #1 'width' not a number (\"..\
class.type(d)..\")\",2)end\
if type(l)~=\"number\"then return\
error(\"element attribute #2 'height' not a number (\"..class.type(l)..\")\",2)end self.width=d self.height=l self.pixels={}local u={1,1,\" \"}for c=1,d*l do\
self.pixels[c]=u end end\
function Canvas:setWidth(d)if type(d)~=\"number\"then return\
error(\"expected number width, got \"..class.type(d))end\
d=math.floor(d)local l,u=self.height,self.pixels local c=self.width\
local m={self.colour,1,\" \"}while c<d do for f=1,l do i(u,(c+1)*f,m)end c=c+1 end while\
c>d do for f=l,1,-1 do n(u,c*f)end c=c-1 end self.width=c end\
function Canvas:setHeight(d)if type(d)~=\"number\"then return\
error(\"expected number height, got \"..class.type(d))end\
d=math.floor(d)local l,u=self.width,self.pixels local c=self.height\
local m={self.colour,1,\" \"}while c<d do for f=1,l do u[#u+1]=m end c=c+1 end while c>d do\
for f=1,l do u[#u]=nil end c=c-1 end self.height=c end\
function Canvas:getPixel(d,l)local u=self.width\
if\
d>=0 and d<u and l>=0 and l<self.height then local c=self.pixels[l*u+d+1]return c[1],c[2],c[3]end end\
function Canvas:mapColour(d,l)if type(d)~=\"table\"then return\
error(\"expected table coords, got \"..class.type(d))end if\
type(l)~=\"number\"then return\
error(\"expected number colour, got \"..class.type(l))end\
local u={l,1,\" \"}local c=self.pixels for m=1,#d do c[d[m]]=u end end\
function Canvas:mapColours(d,l)if type(d)~=\"table\"then return\
error(\"expected table coords, got \"..class.type(d))end if\
type(l)~=\"table\"then return\
error(\"expected table colours, got \"..class.type(l))end\
local u=self.pixels local c=#l\
for m=1,#d do u[d[m]]={l[(m-1)%c+1],1,\" \"}end end\
function Canvas:mapPixel(d,l)if type(d)~=\"table\"then return\
error(\"expected table coords, got \"..class.type(d))end if\
type(l)~=\"table\"then return\
error(\"expected table pixel, got \"..class.type(l))end\
local u=self.pixels for c=1,#d do u[d[c]]=l end end\
function Canvas:mapPixels(d,l)if type(d)~=\"table\"then return\
error(\"expected table coords, got \"..class.type(d))end if\
type(l)~=\"table\"then return\
error(\"expected table pixels, got \"..class.type(l))end\
local u=self.pixels for c=1,#d do u[d[c]]=l[c]end end\
function Canvas:mapShader(d,l)if type(d)~=\"table\"then return\
error(\"expected table coords, got \"..class.type(d))end\
if\
type(l)~=\"function\"then return\
error(\"expected function shader, got \"..class.type(l))end local u=self.pixels local c=self.width local m={}\
for f=1,#d do local w=d[f]local y=u[w]\
local p=(w-1)%c local v,b,g=l(y[1],y[2],y[3],p,(w-1-p)/c)\
m[f]=\
(v or b or g)and{v or y[1],b or y[2],g or y[3]}end for f=1,#d do local w=m[f]if w then u[d[f]]=w end end end\
function Canvas:shift(a,d,l,u)local c=self.width if type(a)==\"number\"then d,l,u=a,d,l a={}for w=1,c*self.height do\
a[w]=w end end local m=l*c+d\
local f=self.pixels for w=1,#a do f[w]=f[w+m]or u end end\
function Canvas:drawColour(d,l)if type(d)~=\"table\"then return\
error(\"expected table coords, got \"..class.type(d))end if\
type(l)~=\"number\"then return\
error(\"expected number colour, got \"..class.type(l))end if\
l==0 then return end local u={l,1,\" \"}local c=self.pixels for m=1,#d do c[d[m]]=u end end\
function Canvas:drawColours(d,l)if type(d)~=\"table\"then return\
error(\"expected table coords, got \"..class.type(d))end if\
type(l)~=\"table\"then return\
error(\"expected table colours, got \"..class.type(l))end\
local u=#l local c=self.pixels for m=1,#d do if l[m]~=0 then\
c[d[m]]={l[(m-1)%u+1],1,\" \"}end end end\
function Canvas:drawPixel(d,l)if type(d)~=\"table\"then return\
error(\"expected table coords, got \"..class.type(d))end if\
type(l)~=\"table\"then return\
error(\"expected table pixel, got \"..class.type(l))end\
local u=self.pixels\
if l[1]==0 and(l[2]==0 or l[3]==\"\")then return elseif\
l[1]==0 or l[2]==0 or l[3]==\"\"then local c,m,f=l[1],l[2],l[3]\
for w=1,#d do local y=d[w]local p,v,b,g if c==0 then p=u[y]\
v=p[1]end\
if m==0 or f==\"\"then p=p or u[y]b=p[2]g=p[3]end u[y]={v or c,b or m,g or f}end else for c=1,#d do u[d[c]]=l end end end\
function Canvas:drawPixels(d,l)if type(d)~=\"table\"then return\
error(\"expected table coords, got \"..class.type(d))end if\
type(l)~=\"table\"then return\
error(\"expected table pixels, got \"..class.type(l))end\
local u=#l local c=self.pixels local m=u<#d\
for f=1,#d do\
local w=m and l[(f-1)%u+1]or l[f]local y,p,v=w[1],w[2],w[3]local b if y==0 then b=c[d[f]]y=b[1]end if\
p==0 or v==\"\"then b=b or c[d[f]]p=b[2]v=b[3]end\
c[d[f]]={y,p,v}end end\
function Canvas:clear(d)\
if d and type(d)~=\"number\"then return\
error(\"expected number colour, got \"..class.type(d))end local l={d or self.colour,d and 1 or 0,\" \"}for u=1,self.width*\
self.height do self.pixels[u]=l end end\
function Canvas:clone(d)if d and not class.isClass(d)then\
return error(\"expected Class class, got \"..\
class.type(d))end\
local l=(d or self.class)(self.width,self.height)l.pixels=self.pixels return l end\
function Canvas:copy(d)if d and not class.isClass(d)then\
return error(\"expected Class class, got \"..\
class.type(d))end\
local l=(d or self.class)(self.width,self.height)local u,c=l.pixels,self.pixels for m=1,#c do u[m]=c[m]end return l end\
function Canvas:drawTo(d,l,u)l,u=l or 0,u or 0 if not class.typeOf(d,Canvas)then\
return error(\
\"expected Canvas canvas, got \"..class.type(d))end if type(l)~=\"number\"then\
return error(\
\"expected number offsetX, got \"..class.type(l))end if type(u)~=\"number\"then\
return error(\
\"expected number offsetY, got \"..class.type(u))end local c,m=self.width,self.height\
local f,w=d.width,d.height local y={}local p={}local v=1 local g=self.pixels local k,q=o(0,f,l,c)k=k-l+1 q=k+q-1 for b=0,m-1 do\
local j=b+u\
if j>=0 and j<w then local x=b*c local z=j*f+l for _=k,q do\
if g[x+_]then p[v]=g[x+_]y[v]=z+_ v=v+1 end end end end\
d:drawPixels(y,p)end\
function Canvas:getArea(l,u,m,f,w)a.setDimensions(self.width,self.height)\
if l==5 then return\
a.fill()elseif l==0 then if type(u)~=\"number\"then return\
error(\"expected number x, got \"..class.type(u))end if type(m)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(m))end if type(f)~=\
\"number\"then return\
error(\"expected number width, got \"..class.type(f))end if\
type(w)~=\"number\"then return\
error(\"expected number height, got \"..class.type(w))end return\
a.box(u,m,f,w)elseif l==6 then if type(u)~=\"number\"then return\
error(\"expected number x, got \"..class.type(u))end if type(m)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(m))end return\
a.point(u,m)elseif l==4 then if type(u)~=\"number\"then return\
error(\"expected number x, got \"..class.type(u))end if type(m)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(m))end if type(f)~=\
\"number\"then return\
error(\"expected number width, got \"..class.type(f))end return\
a.hLine(u,m,f)elseif l==3 then if type(u)~=\"number\"then return\
error(\"expected number x, got \"..class.type(u))end if type(m)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(m))end if type(f)~=\
\"number\"then return\
error(\"expected number height, got \"..class.type(f))end return\
a.vLine(u,m,f)elseif l==2 then if type(u)~=\"number\"then return\
error(\"expected number x1, got \"..class.type(u))end if type(m)~=\
\"number\"then return\
error(\"expected number y1, got \"..class.type(m))end if\
type(f)~=\"number\"then return\
error(\"expected number x2, got \"..class.type(f))end if type(w)~=\
\"number\"then return\
error(\"expected number y2, got \"..class.type(w))end return\
a.line(u,m,f,w)elseif l==1 then if type(u)~=\"number\"then return\
error(\"expected number x, got \"..class.type(u))end if type(m)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(m))end if type(f)~=\
\"number\"then return\
error(\"expected number radius, got \"..class.type(f))end return\
a.circle(u,m,f)elseif l==7 then if type(u)~=\"number\"then return\
error(\"expected number x, got \"..class.type(u))end if type(m)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(m))end if type(f)~=\
\"number\"then return\
error(\"expected number radius, got \"..class.type(f))end return\
a.correctedCircle(u,m,f)else\
return error(\"unexpected mode: \"..tostring(l))end end","sheets.graphics.Canvas",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("class\"DrawingCanvas\"extends\"Canvas\"{}\
function DrawingCanvas:drawPoint(e,t,a)if\
type(e)~=\"number\"then return\
error(\"expected number x, got \"..class.type(e))end if type(t)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(t))end if type(a)~=\
\"table\"then return\
error(\"expected table options, got \"..class.type(a))end local o=\
a.colour or 0 local i=a.textColour or 1 local n=a.character or\" \"if\
type(o)~=\"number\"then return\
error(\"expected number colour, got \"..class.type(o))end\
if\
type(i)~=\"number\"then return\
error(\"expected number textColour, got \"..class.type(i))end\
if type(n)~=\"string\"then return\
error(\"expected string character, got \"..class.type(n))end if\
e>=0 and t>=0 and e<self.width and t<self.height then\
self:drawPixel({t*self.width+e+1},{o,i,n})end end\
function DrawingCanvas:drawBox(e,t,a,o,i)if type(e)~=\"number\"then return\
error(\"expected number x, got \"..class.type(e))end if type(t)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(t))end if type(a)~=\
\"number\"then return\
error(\"expected number width, got \"..class.type(a))end if\
type(o)~=\"number\"then return\
error(\"expected number height, got \"..class.type(o))end if\
type(i)~=\"table\"then return\
error(\"expected table options, got \"..class.type(i))end local n=\
i.colour or 0 local s=i.textColour or 1 local h=i.character or\" \"if\
type(n)~=\"number\"then return\
error(\"expected number colour, got \"..class.type(n))end\
if\
type(s)~=\"number\"then return\
error(\"expected number textColour, got \"..class.type(s))end\
if type(h)~=\"string\"then return\
error(\"expected string character, got \"..class.type(h))end if h==\" \"then\
self:drawColour(self:getArea(0,e,t,a,o),n)else\
self:drawPixel(self:getArea(0,e,t,a,o),{n,s,h})end end\
function DrawingCanvas:drawCircle(e,t,a,o)if type(e)~=\"number\"then return\
error(\"expected number x, got \"..class.type(e))end if type(t)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(t))end if type(a)~=\
\"number\"then return\
error(\"expected number radius, got \"..class.type(a))end if\
type(o)~=\"table\"then return\
error(\"expected table options, got \"..class.type(o))end local i=\
o.colour or 0 local n=o.textColour or 1 local s=o.character or\" \"local h=\
o.corrected or false if type(i)~=\"number\"then\
return error(\"expected number colour, got \"..\
class.type(i))end if type(n)~=\"number\"then\
return error(\
\"expected number textColour, got \"..class.type(n))end if type(s)~=\"string\"then\
return error(\
\"expected string character, got \"..class.type(s))end if s==\" \"then\
self:drawColour(self:getArea(h and 7 or 1,e,t,a),i)else\
self:drawPixel(self:getArea(h and 7 or 1,e,t,a),{i,n,s})end end\
function DrawingCanvas:drawLine(e,t,a,o,i)if type(e)~=\"number\"then return\
error(\"expected number x1, got \"..class.type(e))end if type(t)~=\
\"number\"then return\
error(\"expected number y1, got \"..class.type(t))end if\
type(a)~=\"number\"then return\
error(\"expected number x2, got \"..class.type(a))end if type(o)~=\
\"number\"then return\
error(\"expected number y2, got \"..class.type(o))end if\
type(i)~=\"table\"then return\
error(\"expected table options, got \"..class.type(i))end local n=\
i.colour or 0 local s=i.textColour or 1 local h=i.character or\" \"if\
type(n)~=\"number\"then return\
error(\"expected number colour, got \"..class.type(n))end\
if\
type(s)~=\"number\"then return\
error(\"expected number textColour, got \"..class.type(s))end\
if type(h)~=\"string\"then return\
error(\"expected string character, got \"..class.type(h))end if h==\" \"then\
self:drawColour(self:getArea(2,e,t,a,o),n)else\
self:drawPixel(self:getArea(2,e,t,a,o),{n,s,h})end end\
function DrawingCanvas:drawHorizontalLine(e,t,a,o)if type(e)~=\"number\"then return\
error(\"expected number x, got \"..class.type(e))end if type(t)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(t))end if type(a)~=\
\"number\"then return\
error(\"expected number width, got \"..class.type(a))end if\
type(o)~=\"table\"then return\
error(\"expected table options, got \"..class.type(o))end local i=\
o.colour or 0 local n=o.textColour or 1 local s=o.character or\" \"if\
type(i)~=\"number\"then return\
error(\"expected number colour, got \"..class.type(i))end\
if\
type(n)~=\"number\"then return\
error(\"expected number textColour, got \"..class.type(n))end\
if type(s)~=\"string\"then return\
error(\"expected string character, got \"..class.type(s))end if s==\" \"then\
self:drawColour(self:getArea(4,e,t,a),i)else\
self:drawPixel(self:getArea(4,e,t,a),{i,n,s})end end\
function DrawingCanvas:drawVerticalLine(e,t,a,o)if type(e)~=\"number\"then return\
error(\"expected number x, got \"..class.type(e))end if type(t)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(t))end if type(a)~=\
\"number\"then return\
error(\"expected number height, got \"..class.type(a))end if\
type(o)~=\"table\"then return\
error(\"expected table options, got \"..class.type(o))end local i=\
o.colour or 0 local n=o.textColour or 1 local s=o.character or\" \"if\
type(i)~=\"number\"then return\
error(\"expected number colour, got \"..class.type(i))end\
if\
type(n)~=\"number\"then return\
error(\"expected number textColour, got \"..class.type(n))end\
if type(s)~=\"string\"then return\
error(\"expected string character, got \"..class.type(s))end if s==\" \"then\
self:drawColour(self:getArea(3,e,t,a),i)else\
self:drawPixel(self:getArea(3,e,t,a),{i,n,s})end end\
function DrawingCanvas:drawText(e,t,a,o)if type(e)~=\"number\"then return\
error(\"expected number x, got \"..class.type(e))end if type(t)~=\
\"number\"then return\
error(\"expected number y, got \"..class.type(t))end if type(a)~=\
\"string\"then return\
error(\"expected string text, got \"..class.type(a))end if\
type(o)~=\"table\"then return\
error(\"expected table options, got \"..class.type(o))end local i=\
o.colour or 0 local n=o.textColour or 1 if type(i)~=\"number\"then\
return error(\
\"expected number colour, got \"..class.type(i))end if type(n)~=\"number\"then\
return error(\
\"expected number textColour, got \"..class.type(n))end if t<0 or t>=self.height then\
return end local s=self.width\
local h=t*s+ (e>0 and e or 0)local r=e>=0 and 0 or-e local d,l={},{}\
local u,c=s- (e>0 and e or 0),#a-r\
for m=1,u<c and u or c do d[m]={i,n,a:sub(m+r,m+r)}l[m]=h+m end self:drawPixels(l,d)end","sheets.graphics.DrawingCanvas",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("local e=term.redirect local t={}\
for a=0,15 do t[2^a]=(\"%x\"):format(a)end class\"ScreenCanvas\"extends\"Canvas\"{last={}}\
function ScreenCanvas:ScreenCanvas(a,o)a=\
a or 0 o=o or 0\
if type(a)~=\"number\"then return\
error(\"element attribute #1 'width' not a number (\"..class.type(a)..\
\")\",2)end\
if type(o)~=\"number\"then return\
error(\"element attribute #2 'height' not a number (\"..class.type(o)..\")\",2)end local i={}self.last={}for n=1,a*o do self.last[n]=i end return\
self:Canvas(a,o)end\
function ScreenCanvas:reset()local a={}for o=1,width*height do self.last[o]=a end end\
function ScreenCanvas:drawToTerminals(a,o,i)o=o or 0 i=i or 0 if type(a)~=\"table\"then\
return error(\"expected table terminals, got \"..\
class.type(a))end if type(o)~=\"number\"then\
return error(\
\"expected number x, got \"..class.type(o))end\
if type(i)~=\"number\"then return error(\"expected number y, got \"..\
class.type(i))end local n=1 local s,h=self.pixels,self.last local r=self.width\
for d=1,self.height do local l=false\
for u=1,r do\
local c=s[n]local m=h[n]if c[1]~=m[1]or c[2]~=m[2]or c[3]~=m[3]then\
l=true h[n]=c end n=n+1 end\
if l then local u,c,m={},{},{}n=n-r\
for f=1,r do local w=s[n]u[f]=t[w[1]]or\"0\"\
c[f]=t[w[2]]or\"0\"m[f]=w[3]==\"\"and\" \"or w[3]n=n+1 end for n=1,#a do a[n].setCursorPos(o+1,i+d)\
a[n].blit(table.concat(m),table.concat(c),table.concat(u))end end end end\
function ScreenCanvas:drawToTerminal(a,o,i)return self:drawToTerminals({a},o,i)end\
function ScreenCanvas:drawToScreen(a,o)return self:drawToTerminal(term,a,o)end","sheets.graphics.ScreenCanvas",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("local e={}\
for t=0,15 do e[2^t]=(\"%x\"):format(t)e[(\"%x\"):format(t)]=\
2^t e[(\"%X\"):format(t)]=2^t end image={}\
function image.decodePaintutils(t,a)local o={}\
for i in t:gmatch\"[^\\n]+\"do local n={}for s=1,#i do\
n[s]={e[i:sub(s,s)]or 0,1,\" \"}end o[#o+1]=n end return o end function image.encodePaintutils(t)end\
function image.apply(t,a)local o,i={},{}local s=1\
for n=0,\
math.min(#t,a.height)-1 do local h=n*a.width for r=1,math.min(#t[n+1],a.width)do\
o[s]=t[n+1][r]i[s]=h+r s=s+1 end end a:mapPixels(i,o)end","sheets.graphics.image",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("local e={}local t\
local function a(o)for n=1,#o do\
if o[n].catch==t.name or o[n].default or\
o[n].catch==t.class then return o[n].handler(t)end end return\
Exception.throw(t)end\
class\"Exception\"{name=\"undefined\",data=\"undefined\",trace={},ID=0}\
function Exception:Exception(o,i,n)self.name=o self.data=i self.trace={}n=(n or 1)+2\
for s=1,5 do\
local h=select(2,pcall(error,\"\",\
n+s)):gsub(\": $\",\"\")if h==\"pcall\"then break else self.trace[s]=h end end end function Exception:getTraceback(o,i)o=o or\"\"i=i or\"\\n\"return\
o..table.concat(self.trace,i)end\
function Exception:getDataAndTraceback(o)\
return\
textutils.serialize(self.data)..\
\"\\n\"..self:getTraceback((\" \"):rep(o or 1)..\"in \",\"\\n\"..\
(\" \"):rep(o or 1)..\"in \")end\
function Exception:tostring()return tostring(self.name)..\
\" exception:\\n \"..self:getDataAndTraceback(2)end function Exception.getExceptionById(o)return e[o]end\
function Exception.throw(o,i,n)\
if\
class.isClass(o)then o=o(i,(n or 1)+1)elseif type(o)==\"string\"then\
o=Exception(o,i,(n or 1)+1)elseif not class.typeOf(o,Exception)then return\
Exception.throw(\"IncorrectParameterException\",\
\"expected class, string, or Exception e, got \"..class.type(o))end t=o\
error(\"SHEETS_EXCEPTION\\nPut code in a try block to catch the exception.\",0)end\
function Exception.try(o)local i,n=pcall(o)\
if not i and\
n==\"SHEETS_EXCEPTION\\nPut code in a try block to catch the exception.\"then return a end return error(n,0)end function Exception.catch(o)\
return function(a)return{catch=o,handler=a}end end function Exception.default(a)\
return{default=true,handler=a}end","sheets.exceptions.Exception",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("class\"IncorrectParameterException\"extends\"Exception\"\
function IncorrectParameterException:IncorrectParameterException(e,t)return\
self:Exception(\"IncorrectParameterException\",e,t)end","sheets.exceptions.IncorrectParameterException",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("class\"IncorrectConstructorException\"extends\"Exception\"\
function IncorrectConstructorException:IncorrectConstructorException(e,t)return\
self:Exception(\"IncorrectConstructorException\",e,t)end","sheets.exceptions.IncorrectConstructorException",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("parameters={}\
function parameters.checkConstructor(e,t,...)local a={...}\
for o=1,t*3,3 do local i=a[o]\
local n=a[o+1]local s=a[o+2]\
if type(n)==\"string\"then if type(s)~=n then\
Exception.throw(IncorrectConstructorException,\
e:type()..\" expects \"..n..\
\" \"..i..\" when created, got \"..class.type(s),4)end else\
if not\
class.typeOf(s,n)then\
Exception.throw(IncorrectConstructorException,e:type()..\" expects \"..\
n:type()..\" \"..i..\" when created, got \"..\
class.type(s),4)end end end end\
function parameters.check(e,...)local t={...}\
for a=1,e*3,3 do local o=t[a]local i=t[a+1]local n=t[a+2]\
if\
type(i)==\"string\"then if type(n)~=i then\
Exception.throw(IncorrectParameterException,\"expected \"..i..\" \"..o..\", got \"..\
class.type(n),3)end else if not\
class.typeOf(n,i)then\
Exception.throw(IncorrectParameterException,\"expected \"..i:type()..\" \"..o..\
\", got \"..class.type(n),3)end end end end","sheets.parameters",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("interface\"IAnimation\"{}\
function IAnimation:IAnimation()self.animations={}end\
function IAnimation:addAnimation(e,t,a)\
parameters.check(3,\"label\",\"string\",e,\"setter\",\"function\",t,\"animation\",Animation,a)self.animations[e]={setter=t,animation=a}if a.value then\
t(self,a.value)end return a end\
function IAnimation:stopAnimation(e)\
parameters.check(1,\"label\",\"string\",e)local t=self.animations[e]self.animations[e]=nil return t end\
function IAnimation:updateAnimations(e)\
parameters.check(1,\"dt\",\"number\",e)local t={}local a=self.animations local o,i=next(a)\
while a[o]do local n=i.animation\
n:update(e)if n.value then i.setter(self,n.value)end if n:finished()then\
t[#t+1]=o end o,i=next(a,o)end for n=1,#t do self.animations[t[n]]=nil end end","sheets.interfaces.IAnimation",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
local function e(a,o,i,n,s,h,r)r=r or\"transition\"\
parameters.check(3,\"to\",\"number\",s,\"time\",\"number\",h or 0,\"easing\",type(r)==\
\"string\"and\"string\"or\"function\",r)\
local d=Animation():setRounded():addKeyFrame(n,s,h or.3,r)a:addAnimation(o,i,d)return d end\
local function t(a,o,i,n,s,h)if not a.parent then return end\
local r=Animation():setRounded():addKeyFrame(n,s,h,\
o==\"in\"and\"entrance\"or\"exit\")if i then a:addAnimation(\"y\",a.setY,r)else\
a:addAnimation(\"x\",a.setX,r)end if o==\"exit\"then\
function r.onFinish()a:remove()end end return r end interface\"IAttributeAnimator\"{}\
function IAttributeAnimator:animateValue(a,o,i,n,s,h)s=\
s or\"transition\"\
parameters.check(5,\"value\",\"string\",a,\"from\",\"number\",o,\"to\",\"number\",i,\"time\",\"number\",n or\
0,\"easing\",type(s)==\"string\"and\"string\"or\"function\",s)\
local r=(h and Animation():setRounded()or Animation()):addKeyFrame(o,i,n,s)\
local d=self[\"set\"..a:sub(1,1):upper()..a:sub(2)]return self:addAnimation(a,d,r)end function IAttributeAnimator:animateX(a,o,i)\
return e(self,\"x\",self.setX,self.x,a,o,i)end function IAttributeAnimator:animateY(a,o,i)return\
e(self,\"y\",self.setY,self.y,a,o,i)end function IAttributeAnimator:animateZ(a,o,i)return\
e(self,\"z\",self.setZ,self.z,a,o,i)end\
function IAttributeAnimator:animateWidth(a,o,i)return\
e(self,\"width\",self.setWidth,self.width,a,o,i)end function IAttributeAnimator:animateHeight(a,o,i)\
return e(self,\"height\",self.setHeight,self.height,a,o,i)end\
function IAttributeAnimator:animateIn(a,o,i)a=\
a or\"top\"i=i or.3\
parameters.check(3,\"side\",\"string\",a,\"to\",\"number\",o or 0,\"time\",\"number\",i)\
if a==\"top\"then return t(self,\"in\",true,self.y,o or 0,i)elseif a==\"left\"then return t(self,\"in\",false,self.x,\
o or 0,i)elseif a==\"right\"then\
return t(self,\"in\",false,self.x,o or\
self.parent.width-self.width,i)elseif a==\"bottom\"then return\
t(self,\"in\",true,self.y,o or self.parent.height-self.height,i)else\
throw(IncorrectParameterException(\"invalid side '\"..a..\"'\",2))end end\
function IAttributeAnimator:animateOut(a,o,i)a=a or\"top\"i=i or.3\
parameters.check(3,\"side\",\"string\",a,\"to\",\"number\",\
o or 0,\"time\",\"number\",i)\
if a==\"top\"then\
return t(self,\"out\",true,self.y,o or-self.height,i)elseif a==\"left\"then\
return t(self,\"out\",false,self.x,o or-self.width,i)elseif a==\"right\"then\
return t(self,\"out\",false,self.x,o or self.parent.width,i)elseif a==\"bottom\"then return\
t(self,\"out\",true,self.y,o or self.parent.height,i)else\
throw(IncorrectParameterException(\"invalid side '\"..a..\"'\",2))end end","sheets.interfaces.IAttributeAnimator",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("interface\"IChildContainer\"{children={}}\
function IChildContainer:IChildContainer()\
self.children={}self.meta.__add=self.addChild function self.meta:__concat(e)\
self:addChild(e)return self end end\
function IChildContainer:addChild(e)\
parameters.check(1,\"child\",Sheet,e)local t=self.children\
if e.parent then e.parent:removeChild(e)end e.parent=self self:setChanged()for a=1,#t do if t[a].z>e.z then\
table.insert(t,a,e)return e end end\
t[#t+1]=e return e end\
function IChildContainer:removeChild(e)\
for t=1,#self.children do if self.children[t]==e then\
e.parent=nil self:setChanged()\
return table.remove(self.children,t)end end end\
function IChildContainer:getChildById(e)\
parameters.check(1,\"id\",\"string\",e)\
for t=#self.children,1,-1 do\
local a=self.children[t]:getChildById(e)\
if a then return a elseif self.children[t].id==e then return self.children[t]end end end\
function IChildContainer:getChildrenById(e)\
parameters.check(1,\"id\",\"string\",e)local a={}\
for t=#self.children,1,-1 do\
local o=self.children[t]:getChildrenById(e)for t=1,#o do a[#a+1]=o[t]end if self.children[t].id==e then\
a[#a+1]=self.children[t]end end return a end\
function IChildContainer:getChildrenAt(e,t)\
parameters.check(2,\"x\",\"number\",e,\"y\",\"number\",t)local a={}local o=self.children for n=1,#o do a[n]=o[n]end local i={}for n=#a,1,-1 do\
a[n]:handle(MouseEvent(EVENT_MOUSE_PING,\
e-a[n].x,t-a[n].y,i,true))end return i end\
function IChildContainer:isChildVisible(e)\
parameters.check(1,\"child\",Sheet,e)\
return\
e.x+e.width>0 and e.y+e.height>0 and e.x<self.width and e.y<self.height end\
function IChildContainer:repositionChildZIndex(e)local t=self.children\
for a=1,#t do\
if t[a]==e then while t[a-1]and\
t[a-1].z>e.z do t[a-1],t[a]=e,t[a-1]a=a-1 end\
while\
t[a+1]and t[a+1].z<e.z do t[a+1],t[a]=e,t[a+1]a=a+1 end self:setChanged()break end end end","sheets.interfaces.IChildContainer",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("interface\"ISize\"{width=0,height=0}\
function ISize:setWidth(e)\
parameters.check(1,\"width\",\"number\",e)\
if self.width~=e then self.width=e self.canvas:setWidth(e)\
self:setChanged()for t=1,#self.children do\
self.children[t]:onParentResized()end end return self end\
function ISize:setHeight(e)\
parameters.check(1,\"height\",\"number\",e)if self.height~=e then self.height=e self.canvas:setHeight(e)\
for t=1,#\
self.children do self.children[t]:onParentResized()end end return self end","sheets.interfaces.ISize",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("local e,t\
interface\"IHasText\"{text=\"\",text_lines=nil}\
function IHasText:autoHeight()\
if not self.text_lines then self:wrapText(true)end return self:setHeight(#self.text_lines)end\
function IHasText:setText(a)\
parameters.check(1,\"text\",\"string\",a)self.text=a self:wrapText()self:setChanged()return self end function IHasText:wrapText(a)\
self.text_lines=t(self.text,self.width,not a and self.height)end\
function IHasText:drawText(a)\
local o,i=0,self.text_lines a=a or\"default\"\
local n=self.style:getField(\"horizontal-alignment.\"..a)\
local s=self.style:getField(\"vertical-alignment.\"..a)if not i then self:wrapText()i=self.text_lines end if s==1 then o=math.floor(\
self.height/2-#i/2+.5)elseif s==4 then o=\
self.height-#i end\
for h=1,#i do local r=0\
if n==1 then\
r=math.floor(\
self.width/2-#i[h]/2+.5)elseif n==2 then r=self.width-#i[h]end\
self.canvas:drawText(r,o+h-1,i[h],{colour=0,textColour=self.style:getField(\"textColour.\"..a)})end end function IHasText:onPreDraw()self:drawText\"default\"end\
function e(a,o)if\
a:sub(1,o):find\"\\n\"then return a:match\"^(.-)\\n[^%S\\n]*(.*)$\"end if#a<o then\
return a end\
for n=o+1,1,-1 do if a:sub(n,n):find\"%s\"then\
return\
a:sub(1,n-1):gsub(\"[^%S\\n]+$\",\"\"),a:sub(n+1):gsub(\"^[^%S\\n]+\",\"\")end end return a:sub(1,o),a:sub(o+1)end function t(a,o,i)local n,s={}\
while a and(not i or#n<i)do s,a=e(a,o)n[#n+1]=s end return n end","sheets.interfaces.IHasText",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("class\"Event\"{event=\"Event\"}\
function Event:tostring()return self.name end function Event:is(e)return self.event==e end function Event:handle(e)\
self.handled=true self.handler=e end","sheets.events.Event",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("class\"KeyboardEvent\"\
extends\"Event\"{event=\"KeyboardEvent\",key=0,held={}}\
function KeyboardEvent:KeyboardEvent(e,t,a)self.event=e self.key=t self.held=a end\
function KeyboardEvent:matches(e)local a for t in e:gmatch\"(.*)%-\"do if not self.held[t]or\
(a and self.held[t]<a)then return false end\
a=self.held[t]end return self.key==\
keys[e:gsub(\".+%-\",\"\")]end function KeyboardEvent:isHeld(e)\
return self.key==keys[e]or self.held[e]end","sheets.events.KeyboardEvent",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("class\"MiscEvent\"\
extends\"Event\"{event=\"MiscEvent\",parameters={}}\
function MiscEvent:MiscEvent(e,...)self.event=e self.parameters={...}end","sheets.events.MiscEvent",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("class\"MouseEvent\"\
extends\"Event\"{event=\"MouseEvent\",x=0,y=0,button=0,within=true}function MouseEvent:MouseEvent(e,t,a,o,i)self.event=e self.x=t self.y=a self.button=o\
self.within=i end\
function MouseEvent:isWithinArea(e,t,a,o)\
parameters.check(4,\"x\",\"number\",e,\"y\",\"number\",t,\"width\",\"number\",a,\"height\",\"number\",o)return self.x>=e and self.y>=t and self.x<e+a and\
self.y<t+o end\
function MouseEvent:clone(e,t,a)\
parameters.check(2,\"x\",\"number\",e,\"y\",\"number\",t)\
local o=MouseEvent(self.event,self.x-e,self.y-t,self.button,self.within and a or false)o.handled=self.handled\
function o.handle()o.handled=true self:handle()end return o end","sheets.events.MouseEvent",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("class\"TextEvent\"\
extends\"Event\"{event=\"TextEvent\",text=\"\"}function TextEvent:TextEvent(e,t)self.event=e self.text=t end","sheets.events.TextEvent",nil,_ENV)if not __f then error(__err,0)end __f()

local __f,__err=load("local e,t=math.sin,math.cos local a=math.pi/2 local function o(s,h,r)return s+\
h* (3*r*r-2*r*r*r)end local function i(s,h,r)return\
-h*t(r*a)+h+s end\
local function n(s,h,r)return s+h*e(r*a)end\
class\"Animation\"{frame=1,frames={},value=nil,rounded=false}function Animation:Animation()self.frames={}end function Animation:setRounded(s)self.rounded=\
s~=false return self end\
function Animation:addKeyFrame(s,h,r,d)r=\
r or.5 d=d or o\
if not d or d==\"transition\"then d=o elseif d==\"entrance\"then d=n elseif d==\"exit\"then d=i end\
parameters.check(4,\"initial\",\"number\",s,\"final\",\"number\",h,\"duration\",\"number\",r,\"easing\",\"function\",d)local l={ease=true,clock=0,duration=r,initial=s,difference=h-s,easing=d}self.frames[\
#self.frames+1]=l if#self.frames==1 then\
self.value=s end return self end\
function Animation:addPause(s)s=s or 1\
parameters.check(1,\"pause\",\"number\",s)local h={clock=0,duration=s}\
self.frames[#self.frames+1]=h return self end\
function Animation:frameFinished()if type(self.onFrameFinished)==\"function\"then\
self:onFrameFinished(self.frame)end self.frame=self.frame+1 if\
not\
self.frames[self.frame]and type(self.onFinish)==\"function\"then self:onFinish()end end\
function Animation:update(s)\
parameters.check(1,\"dt\",\"number\",s)local h=self.frames[self.frame]\
if h then\
h.clock=math.min(h.clock+s,h.duration)\
if h.ease then\
local r=h.easing(h.initial,h.difference,h.clock/h.duration)if self.rounded then r=math.floor(r+.5)end self.value=r if h.clock>=\
h.duration then self:frameFinished()end end\
if h.clock>=h.duration then self:frameFinished()end end end\
function Animation:finished()return not self.frames[self.frame]end","sheets.Animation",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("local function e(a)return error(tostring(a),0)end local t\
class\"Application\"{name=\"UnNamed Application\",path=\"\",terminateable=true,running=true,screens={},screen=\
nil,mouse=nil,keys={},changed=false}\
function Application:Application()\
self.screens={Screen(self,term.getSize()):addTerminal(term)}self.screen=self.screens[1]self.keys={}end\
function Application:isKeyPressed(a)\
parameters.check(1,\"key\",\"string\",a)return self.keys[a]~=nil end function Application:stop()self.running=false return self end\
function Application:addScreen()\
local a=Screen(self,term.getSize())self.screens[#self.screens+1]=a return a end\
function Application:removeScreen(a)\
parameters.check(1,\"screen\",Screen,a)\
for o=#self.screens,1,-1 do if self.screens[o]==a then\
return table.remove(self.screens,o)end end end\
function Application:event(a,...)local o={...}local i={}\
local function n(s)for h=#i,1,-1 do i[h]:handle(s)end end if a==\"timer\"and timer.update(...)then return end for s=1,#\
self.screens do i[s]=self.screens[s]end\
return t(self,n,a,o,...)end function Application:draw()\
if self.changed then for a=1,#self.screens do\
self.screens[a]:draw()end self.changed=false end end\
function Application:update()\
local a=timer.getDelta()timer.step()for o=1,#self.screens do\
self.screens[o]:update(a)end\
if self.onUpdate then self:onUpdate(a)end end function Application:load()self.changed=true\
if self.onLoad then return self:onLoad()end end\
function Application:run()\
Exception.try(function()\
self:load()local a=timer.new(0)\
while self.running do local o={coroutine.yield()}\
if\
o[1]==\"timer\"and o[2]==a then a=timer.new(.05)elseif o[1]==\"terminate\"and\
self.terminateable then self:stop()else self:event(unpack(o))end self:update()self:draw()end end){Exception.default(e)}end\
function t(a,o,i,n,...)\
if i==\"mouse_click\"then\
a.mouse={x=n[2]-1,y=n[3]-1,down=true,button=n[1],timer=os.startTimer(1),time=os.clock(),moved=false}\
o(MouseEvent(0,n[2]-1,n[3]-1,n[1],true))elseif i==\"mouse_up\"then\
o(MouseEvent(1,n[2]-1,n[3]-1,n[1],true))a.mouse.down=false os.cancelTimer(a.mouse.timer)\
if\
not\
a.mouse.moved and os.clock()-a.mouse.time<1 and n[1]==a.mouse.button then o(MouseEvent(2,n[2]-1,\
n[3]-1,n[1],true))end elseif i==\"mouse_drag\"then\
o(MouseEvent(4,n[2]-1,n[3]-1,n[1],true))a.mouse.moved=true os.cancelTimer(a.mouse.timer)elseif i==\
\"mouse_scroll\"then\
o(MouseEvent(5,n[2]-1,n[3]-1,n[1],true))elseif i==\"monitor_touch\"then elseif i==\"chatbox_something\"then elseif i==\"char\"then\
o(TextEvent(9,n[1]))elseif i==\"paste\"then\
if a.keys.leftShift or a.keys.rightShift then\
o(KeyboardEvent(7,keys.v,{leftCtrl=true,rightCtrl=true}))else o(TextEvent(11,n[1]))end elseif i==\"key\"then\
a.keys[keys.getName(n[1])or n[1]]=os.clock()o(KeyboardEvent(7,n[1],a.keys))elseif i==\"key_up\"then a.keys[\
keys.getName(n[1])or n[1]]=nil\
o(KeyboardEvent(8,n[1],a.keys))elseif i==\"term_resize\"then a.width,a.height=term.getSize()for s=1,#a.screens do\
a.screens[s]:onParentResized()end elseif\
i==\"timer\"and n[1]==a.mouse.timer then\
o(MouseEvent(3,a.mouse.x,a.mouse.y,a.mouse.button,true))else o(MiscEvent(i,...))end end","sheets.Application",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("class\"Screen\"implements\"IAnimation\"implements\"IChildContainer\"\
implements\"ISize\"{terminals={},monitors={},canvas=\
nil,parent=nil,changed=true}\
function Screen:Screen(e,t,a)self.parent=e self.terminals={}self.monitors={}\
self.canvas=ScreenCanvas(t,a)self.width=t self.height=a end function Screen:setChanged(e)self.changed=e~=false\
if e~=false then self.parent.changed=true end return self end\
function Screen:addMonitor(e)\
parameters.check(1,\"side\",\"string\",e)if peripheral.getType(e)~=\"monitor\"then\
throw(IncorrectParameterException,\
\"expected monitor on side '\"..e..\"', got \"..peripheral.getType(e),2)end\
local t=peripheral.wrap(e)self.monitors[e]=t return self:addTerminal(t)end\
function Screen:removeMonitor(e)\
parameters.check(1,\"side\",\"string\",e)local t=self.monitors[e]if t then self.monitors[e]=nil\
self:removeTerminal(t)end return self end\
function Screen:usesMonitor(e)return self.monitors[e]~=nil end\
function Screen:addTerminal(e)\
parameters.check(1,\"terminal\",\"table\",e)self.terminals[#self.terminals+1]=e return\
self:setChanged()end\
function Screen:removeTerminal(e)\
parameters.check(1,\"terminal\",\"table\",e)\
for t=#self.terminals,1,-1 do if self.terminals[t]==e then self:setChanged()return\
table.remove(self.terminals,t)end end return self end\
function Screen:draw()\
if self.changed then local e=self.canvas local t={}local a,o,i e:clear()for n=1,#self.children do\
t[n]=self.children[n]end\
for n=1,#t do local s=t[n]if s:isVisible()then s:draw()\
s.canvas:drawTo(e,s.x,s.y)\
if s.cursor_active then a,o,i=s.x+s.cursor_x,s.y+s.cursor_y,s.cursor_colour end end end e:drawToTerminals(self.terminals)self.changed=false\
for n=1,#\
self.terminals do\
if a then\
self.terminals[n].setCursorPos(a+1,o+1)self.terminals[n].setTextColour(i)\
self.terminals[n].setCursorBlink(true)else\
self.terminals[n].setCursorBlink(false)end end end end\
function Screen:handle(e)local t={}local a=self.children for o=1,#a do t[o]=a[o]end\
if\
e:typeOf(MouseEvent)then local o=e:isWithinArea(0,0,self.width,self.height)for n=#t,1,-1 do\
t[n]:handle(e:clone(t[n].x,t[n].y,o))end else for o=#t,1,-1 do t[o]:handle(e)end end end\
function Screen:update(e)local t={}\
for a=1,#self.children do t[a]=self.children[a]end for a=1,#t do t[a]:update(e)end end","sheets.Screen",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("class\"Sheet\"implements\"IAnimation\"\
implements\"IAttributeAnimator\"implements\"IChildContainer\"\
implements\"ISize\"{x=0,y=0,z=0,id=\"ID\",style=nil,parent=nil,canvas=nil,changed=true,cursor_x=0,cursor_y=0,cursor_colour=0,cursor_active=false,handlesKeyboard=false,handlesText=false}\
function Sheet:Sheet(e,t,a,o)\
parameters.checkConstructor(self.class,4,\"x\",\"number\",e,\"y\",\"number\",t,\"width\",\"number\",a,\"height\",\"number\",o)self.x=e self.y=t self.width=a self.height=o self:IAnimation()\
self:IChildContainer()self.style=Style(self)self.canvas=DrawingCanvas(a,o)end\
function Sheet:setX(e)\
parameters.check(1,\"x\",\"number\",e)if self.x~=e then self.x=e if self.parent then\
self.parent:setChanged(true)end end return self end\
function Sheet:setY(e)\
parameters.check(1,\"y\",\"number\",e)if self.y~=e then self.y=e if self.parent then\
self.parent:setChanged(true)end end return self end\
function Sheet:setZ(e)\
parameters.check(1,\"z\",\"number\",e)\
if self.z~=e then self.z=e if self.parent then\
self.parent:repositionChildZIndex(self)end end return self end function Sheet:setID(e)self.id=tostring(e)return self end\
function Sheet:setStyle(e,t)\
parameters.check(1,\"style\",Style,e)self.style=e:clone(self)\
if t and self.children then for a=1,#self.children do\
self.children[a]:setStyle(e,true)end end self:setChanged(true)return self end\
function Sheet:setParent(e)\
if\
e and(not class.isInstance(e)or\
not e:implements(IChildContainer))then return\
error(\"expected IChildContainer parent, got \"..class.type(e))end if e then e:addChild(self)else self:remove()end\
return self end function Sheet:remove()\
if self.parent then return self.parent:removeChild(self)end end\
function Sheet:isVisible()return self.parent and\
self.parent:isChildVisible(self)end function Sheet:bringToFront()\
if self.parent then return self:setParent(self.parent)end return self end\
function Sheet:setChanged(e)self.changed=\
e~=false\
if\
e~=false and self.parent and not self.parent.changed then self.parent:setChanged()end return self end\
function Sheet:setCursorBlink(e,t,a)a=a or 128\
parameters.check(3,\"x\",\"number\",e,\"y\",\"number\",t,\"colour\",\"number\",a)self.cursor_active=true self.cursor_x=e self.cursor_y=t\
self.cursor_colour=a return self end\
function Sheet:resetCursorBlink()self.cursor_active=false return self end\
function Sheet:tostring()return\"[Instance] \"..\
self.class:type()..\" \"..tostring(self.id)end function Sheet:onParentResized()end\
function Sheet:update(e)local t={}local a=self.children\
self:updateAnimations(e)if self.onUpdate then self:onUpdate(e)end\
for o=1,#a do t[o]=a[o]end for o=#t,1,-1 do t[o]:update(e)end end\
function Sheet:draw()\
if self.changed then local e=self.children local t,a,o\
self:resetCursorBlink()if self.onPreDraw then self:onPreDraw()end\
for n=1,#e do local i=e[n]\
i:draw()i.canvas:drawTo(self.canvas,i.x,i.y)\
if i.cursor_active then t,a,o=i.x+\
i.cursor_x,i.y+i.cursor_y,i.cursor_colour end end if t then self:setCursorBlink(t,a,o)end if self.onPostDraw then\
self:onPostDraw()end self.changed=false end end\
function Sheet:handle(e)local t={}local a=self.children for o=1,#a do t[o]=a[o]end\
if\
e:typeOf(MouseEvent)then local o=e:isWithinArea(0,0,self.width,self.height)for n=#t,1,-1 do\
t[n]:handle(e:clone(t[n].x,t[n].y,o))end else for o=#t,1,-1 do t[o]:handle(e)end end\
if e:typeOf(MouseEvent)then\
if\
e:is(EVENT_MOUSE_PING)and\
e:isWithinArea(0,0,self.width,self.height)and e.within then e.button[#e.button+1]=self end self:onMouseEvent(e)elseif\
e:typeOf(KeyboardEvent)and self.handlesKeyboard and self.onKeyboardEvent then\
self:onKeyboardEvent(e)elseif\
e:typeOf(TextEvent)and self.handlesText and self.onTextEvent then self:onTextEvent(e)end end\
function Sheet:onMouseEvent(e)\
if\
not e.handled and e:isWithinArea(0,0,self.width,self.height)and e.within then if\
not e:is(EVENT_MOUSE_DRAG)and not e:is(EVENT_MOUSE_SCROLL)then\
e:handle(self)end end end","sheets.Sheet",nil,_ENV)if not __f then error(__err,0)end __f()
local __f,__err=load("\
local function e(o)if not o:find\"%.\"then return o..\".default\"end return o end\
local function t(o)return o:gsub(\"%..-$\",\"\",1)..\".default\"end local a={}class\"Style\"{fields={},object=nil}\
function Style.addToTemplate(o,i)if not\
class.isClass(o)then\
throw(IncorrectParameterException(\"expected Class class, got \"..class.type(o),2))end if type(i)~=\"table\"then\
throw(IncorrectParameterException(\
\"expected table fields, got \"..class.type(i),2))end a[o]=a[o]or{}for n,s in\
pairs(i)do a[o][e(n)]=s end end\
function Style:Style(o)if not class.isInstance(o)then\
throw(IncorrectConstructorException(\
\"Style expects Instance object when created, got \"..class.type(o),3))end a[o.class]=\
a[o.class]or{}self.fields={}self.object=o end\
function Style:clone(o)if not class.isInstance(o)then\
throw(IncorrectInitialiserException(\"expected Instance object, got \"..\
class.type(o),2))end\
local i=Style(o or self.object)for n,s in pairs(self.fields)do i.fields[n]=s end return i end function Style:setField(o,i)\
parameters.check(1,\"field\",\"string\",o)self.fields[e(o)]=i self.object:setChanged()\
return self end\
function Style:getField(o)\
parameters.check(1,\"field\",\"string\",o)o=e(o)local i=t(o)\
if self.fields[o]~=nil then return self.fields[o]elseif\
self.fields[i]~=nil then return self.fields[i]elseif\
a[self.object.class][o]~=nil then return a[self.object.class][o]end return a[self.object.class][i]end","sheets.Style",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("class\"Button\"extends\"Sheet\"\
implements\"IHasText\"{down=false}\
function Button:Button(e,t,a,o,i)self.text=i return self:Sheet(e,t,a,o)end\
function Button:onPreDraw()\
self.canvas:clear(\
self.down and self.style:getField\"colour.pressed\"or self.style:getField\"colour\")\
self:drawText(self.down and\"pressed\"or\"default\")end\
function Button:onMouseEvent(e)if e:is(1)and self.down then self.down=false\
self:setChanged()end if\
e.handled or not\
e:isWithinArea(0,0,self.width,self.height)or not e.within then return end\
if\
e:is(0)and not self.down then self.down=true self:setChanged()e:handle()elseif e:is(2)then if self.onClick then\
self:onClick(e.button,e.x,e.y)end e:handle()elseif e:is(3)then if self.onHold then\
self:onHold(e.button,e.x,e.y)end e:handle()end end\
Style.addToTemplate(Button,{[\"colour\"]=512,[\"colour.pressed\"]=8,[\"textColour\"]=1,[\"textColour.pressed\"]=1,[\"horizontal-alignment\"]=1,[\"horizontal-alignment.pressed\"]=1,[\"vertical-alignment\"]=1,[\"vertical-alignment.pressed\"]=1})","sheets.elements.Button",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("class\"Checkbox\"\
extends\"Sheet\"{down=false,checked=false}\
function Checkbox:Checkbox(e,t,a)self.checked=a self:Sheet(e,t,1,1)end function Checkbox:setWidth()end function Checkbox:setHeight()end\
function Checkbox:toggle()self.checked=\
not self.checked\
if self.onToggle then self:onToggle()end\
if self.checked and self.onCheck then self:onCheck()elseif not self.checked and\
self.onUnCheck then self:onUnCheck()end self:setChanged()end\
function Checkbox:onPreDraw()\
self.canvas:drawPoint(0,0,{colour=self.style:getField(\"colour.\"..\
(\
(self.down and\"pressed\")or(self.checked and\"checked\")or\"default\")),textColour=self.style:getField(\
\"checkColour.\".. (self.down and\"pressed\"or\"default\")),character=\
self.checked and\"x\"or\" \"})end\
function Checkbox:onMouseEvent(e)if e:is(1)and self.down then self.down=false\
self:setChanged()end if\
e.handled or not\
e:isWithinArea(0,0,self.width,self.height)or not e.within then return end\
if\
e:is(0)and not self.down then self.down=true self:setChanged()e:handle()elseif e:is(2)then\
self:toggle()e:handle()elseif e:is(3)then e:handle()end end\
Style.addToTemplate(Checkbox,{[\"colour\"]=256,[\"colour.checked\"]=256,[\"colour.pressed\"]=128,[\"checkColour\"]=32768,[\"checkColour.pressed\"]=256})","sheets.elements.Checkbox",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("class\"Container\"extends\"Sheet\"{}\
function Container:draw()\
if self.changed then\
local e=self.children local t,a,o self:resetCursorBlink()\
if self.onPreDraw then self:onPreDraw()end\
for n=1,#e do local i=e[n]if i:isVisible()then i:draw()\
i.canvas:drawTo(self.canvas,i.x,i.y)\
if i.cursor_active then t,a,o=i.x+i.cursor_x,i.y+i.cursor_y,i.cursor_colour end end end if t then self:setCursorBlink(t,a,o)end if self.onPostDraw then\
self:onPostDraw()end self.changed=false end end function Container:onPreDraw()\
self.canvas:clear(self.style:getField\"colour\")end\
Style.addToTemplate(Container,{[\"colour\"]=1})","sheets.elements.Container",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("class\"Draggable\"extends\"Sheet\"\
implements\"IHasText\"{down=false}\
function Draggable:Draggable(e,t,a,o,i)self.text=i return self:Sheet(e,t,a,o)end\
function Draggable:onPreDraw()\
self.canvas:clear(\
self.down and self.style:getField\"colour.pressed\"or self.style:getField\"colour\")\
self:drawText(self.down and\"pressed\"or\"default\")end\
function Draggable:onMouseEvent(e)\
if e:is(1)and self.down then if self.onDrop then\
self:onDrop(self.down.x,self.down.y)end self.down=false self:setChanged()elseif\
\
self.down and e:is(4)and not e.handled and e.within then self:setX(self.x+e.x-self.down.x)self:setY(\
self.y+e.y-self.down.y)if self.onDrag then\
self:onDrag()end e:handle()return end\
if\
e.handled or not e:isWithinArea(0,0,self.width,self.height)or not e.within then return end\
if e:is(0)and not self.down then\
if self.onPickUp then self:onPickUp()end self.down={x=e.x,y=e.y}self:setChanged()\
self:bringToFront()e:handle()elseif e:is(2)then if self.onClick then\
self:onClick(e.button,e.x,e.y)end e:handle()elseif e:is(3)then if self.onHold then\
self:onHold(e.button,e.x,e.y)end e:handle()end end\
Style.addToTemplate(Draggable,{[\"colour\"]=512,[\"colour.pressed\"]=8,[\"textColour\"]=1,[\"textColour.pressed\"]=1,[\"horizontal-alignment\"]=1,[\"horizontal-alignment.pressed\"]=1,[\"vertical-alignment\"]=1,[\"vertical-alignment.pressed\"]=1})","sheets.elements.Draggable",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("class\"Image\"\
extends\"Sheet\"{down=false,image=nil,fill=nil}\
function Image:Image(e,t,a)\
if type(a)==\"string\"then if fs.exists(a)then local n=fs.open(a,\"r\")if n then\
a=n.readAll()n.close()end end\
a=image.decodePaintutils(a)elseif type(a)~=\"table\"then\
parameters.checkConstructor(self.class,1,\"image\",\"string\",a)end local o,i=# (a[1]or\"\"),#a self.image=a\
return self:Sheet(e,t,o,i)end function Image:setWidth()end function Image:setHeight()end\
function Image:onPreDraw()\
local e=self.style:getField(\
\"shader.\".. (self.down and\"pressed\"or\"default\"))\
if not self.fill then self.fill=self.canvas:getArea(5)end image.apply(self.image,self.canvas)if e then\
self.canvas:mapShader(self.fill,e)end end\
function Image:onMouseEvent(e)if e:is(1)and self.down then self.down=false\
self:setChanged()end if\
e.handled or not\
e:isWithinArea(0,0,self.width,self.height)or not e.within then return end\
if\
e:is(0)and not self.down then self.down=true self:setChanged()e:handle()elseif e:is(2)then if self.onClick then\
self:onClick(e.button,e.x,e.y)end e:handle()elseif e:is(3)then if self.onHold then\
self:onHold(e.button,e.x,e.y)end e:handle()end end\
Style.addToTemplate(Image,{[\"shader\"]=false,[\"shader.pressed\"]=false})","sheets.elements.Image",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("class\"KeyHandler\"\
extends\"Sheet\"{shortcuts={},handlesKeyboard=true}\
function KeyHandler:KeyHandler()self.shortcuts={}return self:Sheet(0,0,0,0)end\
function KeyHandler:addShortcut(e,t)\
parameters.check(2,\"shortcut\",\"string\",e,\"handler\",\"function\",t)self.shortcuts[e]=t end\
function KeyHandler:removeShortcut(e)\
parameters.check(1,\"shortcut\",\"string\",e)self.shortcuts[e]=nil end\
function KeyHandler:onKeyboardEvent(e)\
if not e.handled and e:is(7)then local t=self.shortcuts\
local a,o=next(t)while a do if e:matches(a)then e:handle()o(self)return end\
a,o=next(t,a)end end end function KeyHandler:draw()end","sheets.elements.KeyHandler",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("class\"Panel\"extends\"Sheet\"{}function Panel:onPreDraw()\
self.canvas:clear(self.style:getField\"colour\")end\
Style.addToTemplate(Panel,{[\"colour\"]=256})","sheets.elements.Panel",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("class\"ScrollContainer\"\
extends\"Sheet\"{scrollX=0,scrollY=0,horizontalPadding=0,verticalPadding=0,heldScrollbar=false,down=false}\
function ScrollContainer:ScrollContainer(e,t,a,o,i)if class.typeOf(e,Sheet)then i=e\
e,t,a,o=e.x,e.y,e.width,e.height i.x,i.y=0,0 end\
parameters.checkConstructor(self.class,4,\"x\",\"number\",e,\"y\",\"number\",t,\"width\",\"number\",a,\"height\",\"number\",o,\"element\",\
i and Sheet,i)self:Sheet(e,t,a,o)if i then self:addChild(i)end end\
function ScrollContainer:setScrollX(e)\
parameters.check(1,\"scroll\",\"number\",e)self.scrollX=e return self:setChanged()end\
function ScrollContainer:setScrollY(e)\
parameters.check(1,\"scroll\",\"number\",e)self.scrollY=e return self:setChanged()end\
function ScrollContainer:getContentWidth()local e=self.horizontalPadding local t=self.children for a=1,#\
self.children do\
local o=t[a].x+t[a].width+self.horizontalPadding if o>e then e=o end end return e end\
function ScrollContainer:getContentHeight()local e=self.verticalPadding local t=self.children for a=1,#\
self.children do\
local o=t[a].y+t[a].height+self.verticalPadding if o>e then e=o end end return e end function ScrollContainer:getDisplayWidth(e,t)\
return t and self.width-1 or self.width end\
function ScrollContainer:getDisplayHeight(e,t)return e and\
self.height-1 or self.height end\
function ScrollContainer:getActiveScrollbars(e,t)if e>self.width or t>self.height then return\
e>=self.width,t>=self.height end return false,\
false end\
function ScrollContainer:getScrollbarSizes(e,t,a,o)\
return\
math.floor(self:getDisplayWidth(a,o)/e*\
self:getDisplayWidth(a,o)+.5),math.floor(\
self:getDisplayHeight(a,o)/t*self.height+.5)end\
function ScrollContainer:getScrollbarPositions(e,t,a,o)\
return math.floor(\
self.scrollX/e*self:getDisplayWidth(a,o)+.5),math.floor(self.scrollY/t*\
self.height+.5)end\
function ScrollContainer:draw()\
if self.changed then local e=self.children local t,a,o\
local i,n=self.scrollX,self.scrollY self:resetCursorBlink()\
if self.onPreDraw then self:onPreDraw()end\
for s=1,#e do local h=e[s]\
if h:isVisible()then h:draw()\
h.canvas:drawTo(self.canvas,h.x-i,h.y-n)if h.cursor_active then\
t,a,o=h.x+h.cursor_x-i,h.y+h.cursor_y-n,h.cursor_colour end end end if t then self:setCursorBlink(t,a,o)end if self.onPostDraw then\
self:onPostDraw()end self.changed=false end end\
function ScrollContainer:handle(e)local t={}local a,o=self.scrollX,self.scrollY\
local i=self.children for n=1,#i do t[n]=i[n]end\
if self.down and e:is(1)then self.down=false\
self.heldScrollbar=false self:setChanged()e:handle()elseif self.down and e:is(4)then\
local n,s=self:getContentWidth(),self:getContentHeight()local r,d=self:getActiveScrollbars(n,s)\
if self.heldScrollbar==\"h\"then\
self.scrollX=math.max(math.min(math.floor((\
e.x-self.down)/self:getDisplayWidth(r,d)*n),\
n-self:getDisplayWidth(r,d)),0)self:setChanged()e:handle()elseif self.heldScrollbar==\"v\"then\
self.scrollY=math.max(math.min(math.floor((\
e.y-self.down)/self.height*s),\
s-self:getDisplayHeight(r,d)),0)self:setChanged()e:handle()end end\
if\
e:typeOf(MouseEvent)and not e.handled and\
e:isWithinArea(0,0,self.width,self.height)and e.within then local n,s=self:getContentWidth(),self:getContentHeight()\
local r,d=self:getActiveScrollbars(n,s)\
if e:is(0)then\
if e.x==self.width-1 and d then\
local h,l=self:getScrollbarPositions(n,s,r,d)local u,c=self:getScrollbarSizes(n,s,r,d)local m=e.y\
if m<h then self.scrollY=math.floor(\
m/self.height*s)m=0 elseif m>=h+u then\
self.scrollY=math.floor((\
m-c+1)/self.height*s)m=c-1 else m=m-l end self.heldScrollbar=\"v\"self.down=m self:setChanged()\
e:handle()elseif e.y==self.height-1 and r then\
local h,l=self:getScrollbarPositions(n,s,r,d)local u,c=self:getScrollbarSizes(n,s,r,d)local m=e.x\
if m<h then\
self.scrollX=math.floor(\
m/self:getDisplayWidth(r,d)*n)m=0 elseif m>=h+u then\
self.scrollX=math.floor((m-u+1)/self:getDisplayWidth(r,d)*n)m=u-1 else m=m-h end self.heldScrollbar=\"h\"self.down=m self:setChanged()\
e:handle()end elseif e:is(5)then\
if d then\
self:setScrollY(math.max(math.min(o+e.button,s-self:getDisplayHeight(r,d)),0))elseif r then\
self:setScrollX(math.max(math.min(a+e.button,n-self:getDisplayWidth(r,d)),0))end elseif e:is(2)or e:is(3)then e:handle()end end\
if e:typeOf(MouseEvent)then\
local n=e:isWithinArea(0,0,self.width,self.height)for s=#t,1,-1 do\
t[s]:handle(e:clone(t[s].x-a,t[s].y-o,n))end else for n=#t,1,-1 do t[n]:handle(e)end end\
if e:typeOf(MouseEvent)then\
if\
e:is(EVENT_MOUSE_PING)and\
e:isWithinArea(0,0,self.width,self.height)and e.within then e.button[#e.button+1]=self end self:onMouseEvent(e)elseif\
e:typeOf(KeyboardEvent)and self.handlesKeyboard and self.onKeyboardEvent then\
self:onKeyboardEvent(e)elseif\
e:typeOf(TextEvent)and self.handlesText and self.onTextEvent then self:onTextEvent(e)end end function ScrollContainer:onPreDraw()\
self.canvas:clear(self.style:getField\"colour\")end\
function ScrollContainer:onPostDraw()\
local e,t=self:getContentWidth(),self:getContentHeight()local a,o=self:getActiveScrollbars(e,t)\
if a or o then\
local i,n=self:getScrollbarPositions(e,t,a,o)local s,h=self:getScrollbarSizes(e,t,a,o)\
if a then\
local r=self.style:getField\"horizontal-bar\"\
local d=\
self.heldScrollbar==\"h\"and self.style:getField\"horizontal-bar.active\"or self.style:getField\"horizontal-bar.bar\"\
self.canvas:mapColour(self.canvas:getArea(4,0,self.height-1,self:getDisplayWidth(a,o)),r)\
self.canvas:mapColour(self.canvas:getArea(4,i,self.height-1,s),d)end\
if o then local r=self.style:getField\"vertical-bar\"\
local d=\
self.heldScrollbar==\"v\"and self.style:getField\"vertical-bar.active\"or\
self.style:getField\"vertical-bar.bar\"\
self.canvas:mapColour(self.canvas:getArea(3,self.width-1,0,self.height),r)\
self.canvas:mapColour(self.canvas:getArea(3,self.width-1,n,h),d)end end end\
function ScrollContainer:getChildrenAt(e,t)\
parameters.check(2,\"x\",\"number\",e,\"y\",\"number\",t)local a={}local o,i=self.scrollX,self.scrollY local n=self.children\
for h=1,#n do a[h]=n[h]end local s={}for h=#a,1,-1 do\
a[h]:handle(MouseEvent(EVENT_MOUSE_PING,e-a[h].x-o,t-a[h].y-i,s,true))end return s end\
function ScrollContainer:isChildVisible(e)\
parameters.check(1,\"child\",Sheet,e)local t,a=self.scrollX,self.scrollY\
return\
e.x+e.width-t>0 and\
e.y+e.height-a>0 and e.x-t<self.width and e.y-a<self.height end\
Style.addToTemplate(ScrollContainer,{[\"colour\"]=1,[\"horizontal-bar\"]=128,[\"horizontal-bar.bar\"]=256,[\"horizontal-bar.active\"]=8,[\"vertical-bar\"]=128,[\"vertical-bar.bar\"]=256,[\"vertical-bar.active\"]=8})","sheets.elements.ScrollContainer",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("class\"Text\"extends\"Sheet\"implements\"IHasText\"{}function Text:Text(e,t,a,o,i)\
self.text=i return self:Sheet(e,t,a,o)end\
function Text:onPreDraw()\
self.canvas:clear(self.style:getField\"colour\")self:drawText\"default\"end\
Style.addToTemplate(Text,{[\"colour\"]=1,[\"textColour\"]=128,[\"horizontal-alignment\"]=0,[\"vertical-alignment\"]=3})","sheets.elements.Text",nil,_ENV)if not __f then error(__err,0)end __f()


local __f,__err=load("local function e(o)local i=\"^[^_%w%s]+\"\
if o:find\"%s\"then i=\"^%s+\"elseif o:find\"[%w_]\"then i=\"^[%w_]+\"end return i end\
local function t(o,i,n)\
local s=e(o:sub(n,n))\
if i then return# (o:match(s,n)or\"\")else local h=o:reverse()local r=\
#o-n+1 return# (h:match(s,r)or\"\")end end local function a(o,a)if a then return a:rep(#o)end return o end\
class\"TextInput\"\
extends\"Sheet\"{text=\"\",cursor=0,scroll=0,selection=false,focussed=false,handlesKeyboard=true,handlesText=true,doubleClickData=false}\
function TextInput:TextInput(o,i,n)return self:Sheet(o,i,n,1)end\
function TextInput:setText(o)self.text=tostring(o)return self:setChanged()end\
function TextInput:setScroll(o)\
parameters.check(1,\"scroll\",\"number\",o)self.scroll=o return self:setChanged()end\
function TextInput:setCursor(o)\
parameters.check(1,\"cursor\",\"number\",o)\
self.cursor=math.min(math.max(o,0),#self.text)\
if self.cursor==self.selection then self.selection=nil end\
if self.cursor-self.scroll<1 then\
self.scroll=math.max(self.cursor-1,0)elseif self.cursor-self.scroll>self.width-1 then self.scroll=self.cursor-\
self.width+1 end return self:setChanged()end\
function TextInput:setSelection(o)\
parameters.check(1,\"position\",\"number\",o)self.selection=o return self:setChanged()end\
function TextInput:getSelectedText()\
return self.selection and\
self.text:sub(\
math.min(self.cursor,self.selection)+1,math.max(self.cursor,self.selection))end\
function TextInput:write(o)o=tostring(o)\
if self.selection then\
self.text=\
self.text:sub(1,math.min(self.cursor,self.selection))..o..\
self.text:sub(math.max(self.cursor,self.selection)+1)\
self:setCursor(math.min(self.cursor,self.selection)+#o)self.selection=false else\
self.text=self.text:sub(1,self.cursor)..o..self.text:sub(\
self.cursor+1)self:setCursor(self.cursor+#o)end return self:setChanged()end\
function TextInput:focus()\
if not self.focussed then self.focussed=true if self.onFocus then\
self:onFocus()end return self:setChanged()end return self end\
function TextInput:unfocus()\
if self.focussed then self.focussed=false if self.onUnFocus then\
self:onUnFocus()end return self:setChanged()end return self end\
function TextInput:onPreDraw()\
self.canvas:clear(self.style:getField(\"colour.\".. (\
self.focussed and\"focussed\"or\"default\")))\
local o=self.style:getField(\"mask.\"..\
(self.focussed and\"focussed\"or\"default\"))\
if self.selection then local i=math.min(self.cursor,self.selection)\
local n=math.max(self.cursor,self.selection)\
self.canvas:drawText(-self.scroll,0,a(self.text:sub(1,i),o),{textColour=self.style:getField(\
\"textColour.\".. (self.focussed and\"focussed\"or\"default\"))})\
self.canvas:drawText(i-self.scroll,0,a(self.text:sub(i+1,n),o),{colour=self.style:getField\"colour.highlighted\",textColour=self.style:getField\"textColour.highlighted\"})\
self.canvas:drawText(n-self.scroll,0,a(self.text:sub(n+1),o),{textColour=self.style:getField(\
\"textColour.\".. (self.focussed and\"focussed\"or\"default\"))})else\
self.canvas:drawText(-self.scroll,0,a(self.text,o),{textColour=self.style:getField(\"textColour.\".. (\
self.focussed and\"focussed\"or\"default\"))})end\
if not self.selection and self.focussed and\
self.cursor-self.scroll>=0 and\
self.cursor-self.scroll<self.width then\
self:setCursorBlink(self.cursor-\
self.scroll,0,self.style:getField(\"textColour.\"..\
(self.focussed and\"focussed\"or\"default\")))end end\
function TextInput:onMouseEvent(o)\
if self.down and o:is(4)then\
self.selection=self.selection or self.cursor self:setCursor(o.x+self.scroll+1)elseif self.down and\
o:is(1)then self.down=false end\
if\
o.handled or not o:isWithinArea(0,0,self.width,self.height)or not o.within then if o:is(0)then\
self:unfocus()end return end\
if o:is(0)then self:focus()self.selection=nil\
self:setCursor(o.x+self.scroll)self.down=true o:handle()elseif o:is(2)then\
if self.doubleClickData and self.doubleClickData.x==o.x+\
self.scroll then local i,n=\
o.x+self.scroll+1,o.x+self.scroll+1\
local s=e(self.text:sub(i,i))\
while self.text:sub(i-1,i-1):find(s)do i=i-1 end\
while self.text:sub(n+1,n+1):find(s)do n=n+1 end self:setCursor(n)self.selection=i-1\
timer.cancel(self.doubleClickData.timer)self.doubleClickData=false else if self.doubleClickData then\
timer.cancel(self.doubleClickData.timer)end\
local i=timer.queue(0.3,function()self.doubleClickData=false end)self.doubleClickData={x=o.x+self.scroll,timer=i}end elseif o:is(3)then o:handle()end end\
function TextInput:onKeyboardEvent(o)\
if not self.focussed or o.handled then return end\
if o:is(7)then\
if self.selection then\
if o:matches\"left\"then\
if\
o:isHeld\"leftShift\"or o:isHeld\"rightShift\"then local i=1 if o:isHeld\"rightCtrl\"or o:isHeld\"leftCtrl\"then\
i=t(self.text,false,self.cursor)end\
self:setCursor(self.cursor-i)else\
self:setCursor(math.min(self.cursor,self.selection))self.selection=nil end o:handle()elseif o:matches\"right\"then\
if\
o:isHeld\"leftShift\"or o:isHeld\"rightShift\"then local i=1 if o:isHeld\"rightCtrl\"or o:isHeld\"leftCtrl\"then\
i=t(self.text,true,self.cursor+1)end\
self:setCursor(self.cursor+i)else\
self:setCursor(math.max(self.cursor,self.selection))self.selection=nil end o:handle()elseif o:matches\"backspace\"or o:matches\"delete\"then\
self:write\"\"o:handle()end else\
if o:matches\"left\"then if o:isHeld\"leftShift\"or o:isHeld\"rightShift\"then\
self.selection=self.cursor end local i=1\
if\
o:isHeld\"rightCtrl\"or o:isHeld\"leftCtrl\"then i=t(self.text,false,self.cursor)end self:setCursor(self.cursor-i)o:handle()elseif\
o:matches\"right\"then if o:isHeld\"leftShift\"or o:isHeld\"rightShift\"then\
self.selection=self.cursor end local i=1\
if\
o:isHeld\"rightCtrl\"or o:isHeld\"leftCtrl\"then i=t(self.text,true,self.cursor+1)end self:setCursor(self.cursor+i)o:handle()elseif\
o:matches\"backspace\"and self.cursor>0 then\
self.text=\
self.text:sub(1,self.cursor-1)..self.text:sub(self.cursor+1)self:setCursor(self.cursor-1)o:handle()elseif\
o:matches\"delete\"then\
self:setText(self.text:sub(1,self.cursor)..\
self.text:sub(self.cursor+2))o:handle()end end\
if o:matches\"leftCtrl-a\"or o:matches\"rightCtrl-a\"then self.selection=self.selection or\
self.cursor if self.selection>self.cursor then\
self.selection,self.cursor=self.cursor,self.selection end\
self:addAnimation(\"selection\",self.setSelection,Animation():setRounded():addKeyFrame(self.selection,0,.15))\
self:addAnimation(\"cursor\",self.setCursor,Animation():setRounded():addKeyFrame(self.cursor,\
#self.text,.15))o:handle()elseif o:matches\"end\"then\
self:addAnimation(\"cursor\",self.setCursor,Animation():setRounded():addKeyFrame(self.cursor,\
#self.text,.15))o:handle()elseif o:matches\"home\"then\
self:addAnimation(\"cursor\",self.setCursor,Animation():setRounded():addKeyFrame(self.cursor,0,.15))o:handle()elseif o:matches\"enter\"then self:unfocus()o:handle()if self.onEnter then return\
self:onEnter()end elseif o:matches\"tab\"then self:unfocus()\
o:handle()if self.onTab then return self:onTab()end elseif o:matches\"v\"and(o:isHeld\"leftCtrl\"or\
o:isHeld\"rightCtrl\")then\
local i=clipboard.get\"plain-text\"if i then self:write(i)end elseif\
o:matches\"leftCtrl-c\"or o:matches\"rightCtrl-c\"then if self.selection then\
clipboard.put{[\"plain-text\"]=self:getSelectedText()}end elseif\
o:matches\"leftCtrl-x\"or o:matches\"rightCtrl-x\"then if self.selection then\
clipboard.put{[\"plain-text\"]=self:getSelectedText()}self:write\"\"end end o:handle()end end\
function TextInput:onTextEvent(o)if not o.handled and self.focussed then\
self:write(o.text)o:handle()end end\
Style.addToTemplate(TextInput,{[\"colour\"]=256,[\"colour.focussed\"]=256,[\"colour.highlighted\"]=2048,[\"textColour\"]=128,[\"textColour.focussed\"]=128,[\"textColour.highlighted\"]=1,[\"mask\"]=false,[\"mask.focussed\"]=false})","sheets.elements.TextInput",nil,_ENV)if not __f then error(__err,0)end __f()












