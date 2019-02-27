pico-8 cartridge // http://www.pico-8.com
version 8
__lua__
package={loaded={},_c={}}
package._c["src/engine"]=function()
require("engine/utility")
require("engine/scenegraph")
require("engine/debug")
end
package._c["engine/utility"]=function()
require("utility/math")
require("utility/vec2")
require("utility/graphics")
require("utility/input")
require("utility/sprites")
require("utility/map")
require("utility/collision")
require("utility/drawstate")
require("utility/perf")
end
package._c["utility/math"]=function()
function lerp(a,b,d)
	return a+d*(b-a)
end
end
package._c["utility/vec2"]=function()
--vec2
--two dimensional vector
-------------------------------
vec2={
	x=0,
	y=0
}

function vec2:new(ix,iy)
	self.__index=self
	return setmetatable({
		x=ix or 0,
		y=iy or 0
	}, self)
end

function vec2:__unm()
	return vec2:new(
		-self.x,
		-self.y
	)
end

function vec2:__add(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x+rhs.x,
 		self.y+rhs.y
 	)
	end
	
	return vec2:new(
		self.x+rhs,
		self.y+rhs
	)
end

function vec2:__sub(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x-rhs.x,
 		self.y-rhs.y
 	)
	end
	
	return vec2:new(
		self.x-rhs,
		self.y-rhs
	)
end

function vec2:__mul(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x*rhs.x,
 		self.y*rhs.y
 	)
	end
	
	return vec2:new(
		self.x*rhs,
		self.y*rhs
	)
end

function vec2:__div(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x/rhs.x,
 		self.y/rhs.y
 	)
 end
 
	return vec2:new(
		self.x/rhs,
		self.y/rhs
	)
end

function vec2:__mod(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x%rhs.x,
 		self.y%rhs.y
 	)
 end
 
	return vec2:new(
		self.x%rhs,
		self.y%rhs
	)
end

function vec2:__pow(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x^rhs.x,
 		self.y^rhs.y
 	)
 end
 
	return vec2:new(
		self.x^rhs,
		self.y^rhs
	)
end

function vec2:__concat(rhs)
	if(type(self)=="table") then
		return self:tostring()..rhs
	end

	if(type(rhs)=="table") then
		return self..rhs:tostring()
	end
end

function vec2:__eq(rhs)
	if(type(rhs)=="table") then
		return flr(self.x)==flr(rhs.x) and
			flr(self.y)==flr(rhs.y)
	end

	return self.x==rhs and
		self.y==rhs
end

function vec2:__lt(rhs)
	if(type(rhs)=="table") then
		return self.x<rhs.x and
			self.y<rhs.y
	end

	return self.x<rhs and
		self.y<rhs
end

function vec2:__le(rhs)
	if(type(rhs)=="table") then
		return self.x<=rhs.x and
			self.y<=rhs.y
	end

	return self.x<=rhs and
		self.y<=rhs
end

function vec2:sqlen()
	local sql = 0
	sql+=self.x^2
	sql+=self.y^2
	return sql
end

function vec2:len()
	return sqrt(self:sqlen())
end

function vec2:normalize()
	return self/self:len()
end

function vec2:perp_ccw()
	return vec2:new(-self.y,self.x)
end

function vec2:perp_cw()
	return vec2:new(self.y,-self.x)
end

function vec2:dot(rhs)
	local d=self.x*rhs.x
	d+=self.y*rhs.y
	return d
end

function vec2:lerp(tgt,d)
	d = max(d,0)
	d = min(d,1)
	return vec2:new(
		lerp(self.x,tgt.x,d),
		lerp(self.y,tgt.y,d)
	)
end

function vec2:tostring()
	return "x:"..flr(self.x)..
	",y:"..flr(self.y)
end
end
package._c["utility/graphics"]=function()
--enable color literals
poke(0x5f34,1)
end
package._c["utility/input"]=function()
--enable devkit input
poke(0x5f2d,1)

require("input/keyboard")
require("input/mouse")
end
package._c["input/keyboard"]=function()
--keyboard
-------------------------------
kp=nil
kc=nil

function update_kb()
	kp=stat(30)
	kc=stat(31)
end

function keyp(char)
	return kp and kc == char
end
end
package._c["input/mouse"]=function()
--mouse
-------------------------------
mp=vec2:new()
mb=0

function update_mouse()
	mp.x=stat(32)
	mp.y=stat(33)
	mb=stat(34)
end
end
package._c["utility/sprites"]=function()
_old_sget = sget
function sget(pos)
	return _old_sget(pos.x,pos.y)
end

--sprite pos > sprite index
--@spos vec2 sprite pixel coords
--@return number sprite index
function spos2idx(spos)
	local x=flr(spos.x/8)
	local y=flr(spos.y/8)
	return stile2idx(vec2:new(x,y))
end

--sprite tile > sprite index
--@spos vec2 sprite tile coords
--@return number sprite index
function stile2idx(stile)
	return (stile.y*16)+stile.x
end

--sprite index > sprite tile
--@sidx vec2 map tile coords
--@return number sprite tile coords
function sidx2tile(sidx)
	return vec2:new(
		sidx%16, 
		flr(sidx/16)
	)
end

--sprite index > sprite pos
--@sidx number sprite index
--@return number sprite pixel coords
function sidx2pos(sidx)
	return sidx2tile(sidx)*8
end

--walks along a sprite
--line by line in the specified
--direction and returns the
--first non-0 pixel's coords
function trace_edge(s,xs,ys,f)
	f = f or false

	local xb=0
	local xe=7
	local yb=0
	local ye=7

	if(xs<0) then
		xb=7
		xe=0
	end

	if(ys<0) then
		yb=7
		ye=0
	end
	
	if(not f) then
		local sp = sidx2pos(s)
		for x=xb,xe,xs do
			for y=yb,ye,ys do
				if(sget(vec2:new(sp.x+x,sp.y+y)) > 0) then
					return vec2:new(x,y)
				end
			end
		end
	else
		local sp = sidx2pos(s)
		for y=yb,ye,ys do
			for x=xb,xe,xs do
				if(sget(vec2:new(sp.x+x,sp.y+y)) > 0) then
					return vec2:new(x,y)
				end
			end
		end
	end

	return nil
end

--traces the edges of the
--given sprite in clockwise
--order to generate a
--simplified collision mesh
function convex_hull(s)
	local vs = {}

	local sp = sidx2pos(s)

	add(vs,trace_edge(s,1,1,true))
	add(vs,trace_edge(s,-1,1,true))
	add(vs,trace_edge(s,-1,1))
	add(vs,trace_edge(s,-1,-1))
	add(vs,trace_edge(s,-1,-1,true))
	add(vs,trace_edge(s,1,-1,true))
	add(vs,trace_edge(s,1,-1))
	add(vs,trace_edge(s,1,1))

	for i=#vs,1,-1 do
		if(not vs[i]) del(vs,vs[i])
	end

	for i=#vs,1,-1 do
		local v1 = vs[i]
		local v2 = vs[i-1] or vs[#vs]
		if(v1 == v2) then
			del(vs,v1)
		end
	end

	return vs
end
end
package._c["utility/map"]=function()
--map pos > map tile
--@pos vec2 map pixel coords
--@return vec2 map tile coords
function mpos2tile(pos)
	return pos/8
end

--map tile > map pos
--@mtile vec2 map tile coords
--@return vec2 map pixel coords
function mtile2pos(mtile)
	return mtile*8
end

_old_mget = mget
function mget(pos)
	return _old_mget(pos.x, pos.y)
end
end
package._c["utility/collision"]=function()
collision={
	sprite_geo={},
	debug=false
}

function collision:init(numspr)
	numspr = numspr or 128

	for i=0,numspr-1 do
		if(fget(i)>0) then
			local k = tostr(i)
		 local vs = convex_hull(i)
			self.sprite_geo[k] = vs

			if(self.debug) then
				poly:fromsprite(l_pl,i,{
					pos=vec2:new(
						(i%16)*10,
						flr(i/16)*10
					)
				})
			end
		end
	end
end
end
package._c["utility/drawstate"]=function()
function camerapos()
	return vec2:new(
		peek4(0x5f26),
		peek4(0x5f28)
	)
end

function getclip()
	local x1 = peek(0x5f20)
	local y1 = peek(0x5f21)
	local x2 = peek(0x5f22)
	local y2 = peek(0x5f23)
	return {
		x1,y1,
		x2-x1,y2-y1
	}
end
end
package._c["utility/perf"]=function()
function getfps()
	return stat(7)
end

function getfpstarget()
	return stat(8)
end
end
package._c["engine/scenegraph"]=function()
require("scenegraph/obj")
end
package._c["scenegraph/obj"]=function()
obj_count=0

--object
--basic scene graph unit
-------------------------------
obj={
	name="object",
	parent=nil,
	children=nil
}

function obj:subclass(t)
	self.__index=self
	return
		setmetatable(t or {}, self)
end

function obj:new(p,t)
	local o=obj.subclass(self,t)

	p=p or nil	
	if(p) p:addchild(o)
	o:init()
	
	return o
end

function obj:init()
	self.children = {}
	obj_count+=1
end

function obj:addchild(c)
	if(c.parent != nil) then
		c.parent:remchild(c)
	end
	
	add(self.children,c)
	c.parent=self
	
	return c
end

function obj:remchild(c)
	c.parent = nil
	del(self.children,c)
end

function obj:tostring()
	return self.name
end

function obj:print(pf)
	pf=pf or ""
	local str = pf
	str=str..self:tostring()
	str=str.."\n"
	
	for c in all(self.children) do
		str = str..c:print(pf.." ")
	end
	
	return str
end

function obj:update()
	for c in all(self.children) do
		c:update()
	end
end

function obj:draw()
	for c in all(self.children) do
		c:draw()
	end
end

function obj:destroy()
	if(self.parent) then
		self.parent:remchild(self)
		self.parent=nil
	end
	
	if(#self.children>0) then
 	while #self.children>0 do
 		self.children[1]:destroy()
 	end
	end
	
	obj_count-=1
end

function obj:__concat(rhs)
	if(type(self)=="table") then
		return self:tostring()..rhs
	end

	if(type(rhs)=="table") then
		return self..rhs:tostring()
	end
end

require("obj/prim")
require("obj/move")
end
package._c["obj/prim"]=function()
--primitive
--object with transform
-------------------------------
prim=obj:subclass({
	name="primitive",
	pos=vec2:new(),
	org=vec2:new()
})

function prim:getpos()
	local pos=vec2:new()
	local c=self
	while(c!=nil) do
		if(c.pos) pos+=c.pos
		if(c.org) pos+=c.org
		c=c.parent
	end

	return pos
end

function prim:tostring()
	return
		obj.tostring(self).." - "..
		self.pos:tostring()
end

require("prim/cam")
require("prim/graphic")
end
package._c["prim/cam"]=function()
--cam
--primitive to control camera
-------------------------------
cam=prim:subclass({
	name="camera",
	org=vec2:new(-64,-64)
})

function cam:update()
	local pos = self:getpos()

	camera(
		pos.x,
		pos.y
	)
	prim.update(self)
end
end
package._c["prim/graphic"]=function()
--graphic
--primitive with visual element
-------------------------------
graphic=prim:subclass({
	name="graphic",
	v=true,							--visible
	cm=nil,							--collision mask
	clip=nil,					--clip
	_cclip=nil				--cached clip
})

function graphic:draw()
	if(not self.v) return
	
	self:g_predraw()
	self:g_draw()
	self:g_postdraw()
	
 prim.draw(self)
end

function graphic:g_predraw()
	if(self.clip) then
		self._cclip=getclip()
		clip(
			self.clip[1],
			self.clip[2],
			self.clip[3],
			self.clip[4]
		)
	end
end

function graphic:g_draw()
end

function graphic:g_postdraw()
	if(self._cclip) then
		clip(
			self._cclip[1],
			self._cclip[2],
			self._cclip[3],
			self._cclip[4]
		)
		self._cclip=nil
	end
end

function graphic:contains(p,m)
	return false
end

require("graphic/dot")
require("graphic/map")
require("graphic/shape")
require("graphic/sprite")
require("graphic/stripe")
require("graphic/text")
end
package._c["graphic/dot"]=function()
--dot
--pixel graphic
-------------------------------
dot=graphic:subclass({
	name="dot",
	c=7,								--color
	cm=255						--collision mask
})

function dot:g_draw()
	if(not self.v) return
	
	local pos = self:getpos()
	pset(
		pos.x,
		pos.y,
 	self.c
 )
	
	graphic.g_draw(self)
end

function dot:contains(p,m)
	m = m or 255

	if(band(self.cm,m)==0) then
		return false
	end

	local pos = self:getpos()
	return p == pos
end

require("dot/cursor.lua")
end
package._c["dot/cursor.lua"]=function()
--cursor
--mouse cursor
-------------------------------
cursor=dot:subclass({
	name="cursor",
	org=vec2:new()
})

function cursor:update()
	dot.update(self)

	self.pos = camerapos() + mp
end
end
package._c["graphic/map"]=function()
--map
--map graphic
-------------------------------
obj_map=graphic:subclass({
	name="map",
	org=vec2:new(),
	mtile=vec2:new(0,0),
	sz=vec2:new(16,16)
})

function obj_map:g_draw()
	if(not self.v) return
	
	local pos=self:getpos()
	
	map(
		self.mtile.x,
		self.mtile.y,
		pos.x,
		pos.y,
		self.sz.x,
		self.sz.y
	)
	
	graphic.g_draw(self)
end

function obj_map:contains(p,m)
	m = m or 255

	local pos = self:getpos()
	local lpos = p-pos

	if(lpos.x < 0 or
		lpos.y < 0) then
		return false
	end

	if(lpos.x > self.sz.x*8 or
		lpos.y > self.sz.y*8) then
		return false
	end

	--fetch sprite from map
	local mp = mpos2tile(lpos)
	local s = mget(mp)

	--if a sprite is present
	if(s>0) then
		--get spritesheet coords
		local sp = sidx2pos(s)
		local cm = self.cm or fget(s)

		if(band(m,cm) == 0) then
			return false
		end

		return sget(sp+(lpos%8))>0
	end

	return false
end
end
package._c["graphic/shape"]=function()
--shape
--graphic with
--stroke/fill colors
-------------------------------
shape=graphic:subclass({
	name="shape",
	sc=6,
	fc=7,
	cm=255
})

function shape:g_draw()
	if(not self.v) return
	
	if(self.fc) self:draw_fill()
	if(self.sc) self:draw_stroke()
	
	graphic.g_draw(self)
end

function shape:draw_stroke()
end

function shape:draw_fill()
end

require("shape/box")
require("shape/circle")
require("shape/poly")
end
package._c["shape/box"]=function()
--box
--rect shape
-------------------------------
box=shape:subclass({
	name="box",
	sz=vec2:new(8,8)  --size
})

function box:draw_fill()
	local pos=self:getpos()
	pos -= self.org
	rectfill(
		pos.x,
		pos.y,
		pos.x+self.sz.x,
		pos.y+self.sz.y,
 	self.fc
 )
end

function box:draw_stroke()
	local pos=self:getpos()
	pos -= self.org
	rect(
		pos.x,
		pos.y,
		pos.x+self.sz.x,
		pos.y+self.sz.y,
 	self.sc
 )
end

function box:contains(p,m)
	m = m or 255

	if(band(self.cm,m)==0) then
		return false
	end

	local pos = self:getpos()
	local sz = self.sz

	local x = true
	x = x and p.x >= pos.x
	x = x and p.x <= pos.x+sz.x

	local y = true
	y = y and p.y >= pos.y
	y = y and p.y <= pos.y+sz.y

	return x and y
end
end
package._c["shape/circle"]=function()
--circle
--circle shape
-------------------------------
circle=shape:subclass({
	name="circle",
	r=1,								   --radius
})

function circle:draw_fill()
	local pos=self:getpos()
	circfill(
		pos.x,
		pos.y,
		self.r,
 	self.fc
 )
end

function circle:draw_stroke()
	local pos=self:getpos()
	circ(
		pos.x,
		pos.y,
		self.r,
 	self.sc
 )
end

function circle:contains(p,m)
	m = m or 255

	if(band(self.cm,m)==0) then
		return false
	end

	local pos = self:getpos()
	local d = p-pos
	return d:len() <= self.r
end
end
package._c["shape/poly"]=function()
--poly
--n-sided shape
-------------------------------
poly=shape:subclass({
	name="poly",
	vs={}   					--vertices
})

function poly:fromsprite(p,s,t)
	t = t or {}
	t.vs=collision.sprite_geo[tostr(s)]
	t.cm=fget(s)
	return poly:new(p, t)
end

function poly:draw_stroke()
	local pos = self:getpos()

	for i=1,#self.vs do
		local v1 = self.vs[i]
		v1 += pos

		local v2 =
			self.vs[i+1] or self.vs[1]
		v2 += pos

		line(
			v1.x,
			v1.y,
			v2.x,
			v2.y,
			self.sc
		)
	end

	for i=1,#self.vs do
		local v1 = self.vs[i] + pos
		pset(v1.x,v1.y,8)
	end

end

function poly:contains(p,m)
	m = m or 255

	if(band(self.cm,m)==0) then
		return false
	end

	local pos = self:getpos()
	local c=true

	for i=1,#self.vs do
		local v1 = self.vs[i]
		v1 += pos

		local v2 =
			self.vs[i+1] or self.vs[1]
		v2 += pos

		local d = (v2-v1)
		d=d:normalize()
		d=d:perp_ccw()

		if(d:dot(p-v1)<0) then
			c=false
		end
	end

	return c
end
end
package._c["graphic/sprite"]=function()
--sprite
--sprite graphic
-------------------------------
sprite=graphic:subclass({
	name="sprite",
	org=vec2:new(-4,-4),
	sz=vec2:new(1,1),			--size
	s=0																	--sprite
})

function sprite:g_draw()
	if(not self.v) return
	
	local pos = self:getpos()
	spr(
		self.s,
		pos.x,
		pos.y,
		self.sz.x,
		self.sz.y
	)
	
	graphic.g_draw(self)
end

function sprite:contains(p,m)
	m = m or 255

	--if a sprite is present
	if(self.s>0) then
		local cm =
			self.cm or fget(self.s)
		if(band(m,cm)==0) then
			return false
		end
		
		local pos = self:getpos()
		local lpos = p-pos
		
		if(lpos.x < 0 or
			lpos.y < 0) then
			return false
		end

		if(lpos.x > self.sz.x*8 or
			lpos.y > self.sz.y*8) then
			return false
		end
	
		--get spritesheet coords
		local sp = sidx2pos(self.s)

		return sget(sp+lpos)>0
	end

	return false
end
end
package._c["graphic/stripe"]=function()
--stripe
--line graphic
-------------------------------
stripe=graphic:subclass({
	name="stripe",
	tp=vec2:new(8,0),	--target pos
	at=true,										--abs target
	c=7								       --color
})

function stripe:g_draw()
	if(not self.v) return
	
	local pos = self:getpos()
	local t = self.tp
	if(not self.at) t += pos
	line(
		pos.x,
		pos.y,
		t.x,
		t.y,
 	self.c
 )
	
	graphic.g_draw(self)
end
end
package._c["graphic/text"]=function()
--text
--text graphic
-------------------------------
text=graphic:subclass({
	name="text",
	str=""
})

function text:g_draw()
	if(not self.v) return
	
	local pos=self:getpos()
	
	print(
		self.str,
		pos.x,
		pos.y
	)
	
	graphic.g_draw(self)
end
end
package._c["obj/move"]=function()
--move
--object for moving a parent
-------------------------------
move=obj:subclass({
	name="move",
	dp=vec2:new()
})

function move:update()
	self.parent.pos += self.dp
	self.dp=vec2:new()
end

--move_p
--projectile move
-------------------------------
move_p=obj:subclass({
	name="projectile move",
	a=0,
	s=80
})

function move_p:update()
	self.dp = vec2:new(
		cos(self.a),
		sin(self.a)
	) * self.s * dt
	
	move.update(self)
end
end
package._c["engine/debug"]=function()
require("debug/dbg_ui")
require("debug/dbg_panel")
require("debug/dbg_ovr")
require("debug/dbg_log")
require("debug/dbg_sg")
require("debug/dbg_axis")
end
package._c["debug/dbg_ui"]=function()
--debug ui
dbg_ui=graphic:subclass({
	name="debug ui",
	pos=vec2:new(2,2),
	tabs=nil,
	at=nil,
	tw=nil
})

function dbg_ui:init()
	graphic.init(self)
	
	local bg=box:new(self,{
		sz=vec2:new(123,8),
		sc=0x1107.0000,
		fc=0x1100.5a5a
	})
	
	self.tw=text:new(bg,{
		pos=vec2:new(2,2),
		str="foo"
	})
	
	self.tabs={}
	self.tabs["1"]=
		dbg_ovr:new(self)
	self.tabs["2"]=
		dbg_log:new(self)
	self.tabs["3"]=
		dbg_sg:new(self,{
			root=root
		})
end

function dbg_ui:update()
	graphic.update(self)
	self.pos=camerapos()+2
	
	for k,tab in pairs(self.tabs) do
 	if(keyp(k)) then
 		if(self.at!=k) then
				self.at=k
				self.tw.str=tab.name
			else
				self.at=nil
			end
 	end
	end
	
	for k,tab in pairs(self.tabs) do
		tab.v=k==self.at
	end
	
	self.v = self.at != nil
end
end
package._c["debug/dbg_panel"]=function()
--debug panel
-------------------------------
dbg_panel=graphic:subclass({
	name="debug panel",
	pos=vec2:new(0,8),
	sz=vec2:new(123,115),
	sy=0,
	key=nil,
	v=false,
	c={2,10,124,116}
})

function dbg_panel:init()
	graphic.init(self)
	local bg=box:new(self,{
		sz=self.sz,
		sc=0x1107.0000,
		fc=0x1100.5a5a
	})
end

function dbg_panel:update()
	if(not self.v) return
	
	if(keyp("-")) self.sy -= 114
	if(keyp("=")) self.sy += 114
	if(keyp("[")) self.sy -= 6
	if(keyp("]")) self.sy += 6
	
	self.sy = max(self.sy,0)
	
	graphic.update(self)
end

function dbg_panel:tostring()
	return
		prim.tostring(self).." "..
		"w:"..flr(self.w)..","..
		"w:"..flr(self.w)
end
end
package._c["debug/dbg_ovr"]=function()
--debug overlay
-------------------------------
dbg_ovr=dbg_panel:subclass({
	name="system info",
	key="1",
	mw=nil,		--memory widget
	cw=nil,		--cpu widget
	ow=nil			--object widget
})

function dbg_ovr:init()
	dbg_panel.init(self)
	
	self.tw=text:new(self,{
		pos=vec2:new(2,2)
	})
end

function dbg_ovr:update()
	dbg_panel.update(self)
	
	if(not self.v) return
	
	local str = ""
	
	--memory
	local mem=stat(0)
	
	--cpu
	local tcpu = stat(1)*100
	local scpu = stat(2)*100
	local ucpu = tcpu-scpu
	local fps = getfps()
	local tfps = getfpstarget()
	
	str=str..
		"    memory: "..mem.." kib\n"..
		"\n"..
		"system cpu: "..scpu.." %\n"..
		"  user cpu: "..ucpu.." %\n"..
		" total cpu: "..tcpu.." %\n"..
		"\n"..
		"target fps: "..tfps.."\n"..
		"       fps: "..fps.."\n"..
		"\n"..
		" obj_count: "..obj_count
		
	self.tw.str=str
end
end
package._c["debug/dbg_log"]=function()
--debug log
-------------------------------
dbg_log=dbg_panel:subclass({
	name="log",
	key="2",
	buf={},
	bl=30,
	tw=nil
})

function dbg_log:init()
	dbg_panel.init(self)
	
	self.tw=text:new(self,{
		pos=vec2:new(2,2)
	})
end

function dbg_log:update()
	dbg_panel.update(self)
	
	if(not self.v) return
	
	local str=""
	for s in all(self.buf) do
		str = str..s.."\n"
	end
	
	self.tw.pos.y=2-self.sy
	self.tw.str=str
end

function dbg_log:log(str)
	add(self.buf, str)
	if(#self.buf > self.bl) then
		del(
			self.buf,
			self.buf[1]
		)
	end
end

function dbg_log:clear()
	self.buf={}
end
end
package._c["debug/dbg_sg"]=function()
--debug scenegraph
-------------------------------
dbg_sg=dbg_panel:subclass({
	name="scenegraph",
	root=nil,
	key="3",
	tw=nil
})

function dbg_sg:init()
	dbg_panel.init(self)
	
	self.tw=text:new(self,{
		pos=vec2:new(2,2)
	})
end

function dbg_sg:update()
	dbg_panel.update(self)
	
	if(not self.v) return
	
	self.tw.pos.y=2-self.sy
	self.tw.str=root:print()
end
end
package._c["debug/dbg_axis"]=function()
--debug coordinate axis
-------------------------------
dbg_axis=prim:subclass({
	name="debug axis"
})

function dbg_axis:draw()
	local pos=self:getpos()

	line(
		pos.x,
		pos.y,
		pos.x+5,
		pos.y,
		12
	)
	
	line(
		pos.x,
		pos.y,
		pos.x,
		pos.y+5,
		11
	)
	
	prim.draw(self)
end
end
package._c["src/game"]=function()
require("game/effects")
require("game/projectiles")
require("game/pko")
end
package._c["game/effects"]=function()
require("effects/trail")
end
package._c["effects/trail"]=function()
trail=graphic:subclass({
	name="trail",
	cs={12,13,1}, --colors
	ld=16,								--line divisions
	ds=nil,							--divisions
	ln=32,								--length
	md=0,									--move delta
})

function trail:init()
	prim:init()
	self.ds={}
	local pos=self:getpos()
	for i=1,self.ld-1 do
		add(self.ds,pos)
	end
end

function trail:update()
	local pos = self:getpos()
	local dp = pos-self.ds[#self.ds]
 self.md = dp:len()/(self.ln/self.ld)
 
	if(self.md>=1) then
 	add(self.ds,pos)
 	if(#self.ds>self.ld) then
 		del(self.ds,self.ds[1])
 	end
	end
	
	graphic.update(self)
end

function trail:g_draw()
	local pos = self:getpos()

	for i=1,self.ld-1 do
		local p=1-(i/self.ld)
		local c=self.cs[ceil(p*#self.cs)]

		local fp=self.ds[i]
		local tp=self.ds[i+1] or self:getpos()
		line(fp.x,fp.y,tp.x,tp.y,c)
	end
	
	graphic.g_draw(self)
end
end
package._c["game/projectiles"]=function()
require("projectiles/missile")
require("projectiles/laser")
end
package._c["projectiles/missile"]=function()
missile=prim:subclass({
	name="missile",
	move=nil,
	sa=0,					--start angle
	ss=80,				--start speed
	d=2,						--duration
	cm=1						--collision mask
})

function missile:init()
	prim.init(self)
	circle:new(self)
	self.move=move_p:new(self,{
		a=self.sa,
		s=self.ss
	})
	self:trail()
end

function missile:update()
	--self.move.a += 0.25 * dt

	self.d -= dt
	if(self.d <= 0) self:destroy()
	
	prim.update(self)

	local pos =
		self:getpos()
	if(bg:contains(pos, self.cm)) then
		self:destroy()
	end
end

function missile:trail()
	return trail:new(self,{
		cs={6,12,13,1}
	})
end
end
package._c["projectiles/laser"]=function()
--laser
-------------------------------
laser=missile:subclass({
	name="laser"
})

function laser:init()
	prim.init(self)
	dot:new(self)
	self:trail()
end

function laser:trail()
	return trail:new(self)
end
end
package._c["game/pko"]=function()
pko=prim:subclass({
	name="pko",
	pos=vec2:new(64,64),
	vx=0,
	vy=0,
	ac=600,
	dc=600,
	mv=60,
	sc=nil,	--sprite component
	tc=nil,	--trail component
	cc=nil		--camera component
})

function pko:init()
	prim.init(self)
	self.sc=sprite:new(self,{
		s=1
	})
	self.tc=trail:new(self)
	self.cc=cam:new(self)
end

function pko:update()
	local wx = 0
	if(btn(0)) wx -= 1
	if(btn(1)) wx += 1
	
	local wy = 0
	if(btn(2)) wy -= 1
	if(btn(3)) wy += 1
	
	if(wx==0 and self.vx!=0) then
		local dv=min(
			self.dc*dt,
			abs(self.vx)
		)*sgn(self.vx)
		
		self.vx-=dv
	end
	
	if(wy==0 and self.vy!=0) then
		local dv=min(
			self.dc*dt,
			abs(self.vy)
		)*sgn(self.vy)
		
		self.vy-=dv
	end
	
	self.vx += wx * self.ac * dt
	self.vy += wy * self.ac * dt

	if(abs(self.vx) > self.mv) then
		self.vx=self.mv*sgn(self.vx)
	end
	
	if(abs(self.vy) > self.mv) then
		self.vy=self.mv*sgn(self.vy)
	end

	self.pos.x += self.vx * dt
	self.pos.y += self.vy * dt

	if(btnp(4)) then
		self:burst(missile,16)
	end
 
	prim.update(self)
end

function pko:burst(t,num)
	for i=0,num-1 do
		t:new(l_ms,{
			pos=self.pos,
			sa=i/num
		})
	end
end
end
function require(p)
local l=package.loaded
if (l[p]==nil) l[p]=package._c[p]()
if (l[p]==nil) l[p]=true
return l[p]
end
require("src/engine")
require("src/game")

--main

--config
-------------------------------
debug_mode=true

--variables
-------------------------------
dt=nil

root=nil

bg=nil

l_pl=nil
l_tr=nil
l_ms=nil

d_ui=nil
function log(str)
	d_ui.tabs["2"]:log(str)
end

crs=nil

player=nil

--initialization
-------------------------------
function _init()
	--setup scenegraph
	root=obj:new(nil,{
		name="root"
	})

	bg=obj_map:new(root,{
		name="background",
		w=16,
		h=16
	})
	
	l_pl=obj:new(root,{
		name="layer: player"
	})
	
	l_ms=obj:new(root,{
		name="layer: missiles"
	})
	
	l_ui=obj:new(root,{
		name="layer: ui"
	})
	
	player=pko:new(l_pl)

	--debug ui
	if(debug_mode) do
		d_ui=dbg_ui:new(l_ui)
		crs=cursor:new(l_ui)
	end
	--generate collision
	collision:init()
end

--main loop
-------------------------------
function _update60()
	if(dt==nil) then
		dt=1/getfpstarget()
	end
	
	if(debug_mode) then
		update_kb()
		update_mouse()
	end

	root:update()
end

--render loop
-------------------------------
function _draw()
	cls()
	root:draw()
end
__gfx__
0000000007800e80000b300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e8c7918200bb330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070020d94502033bb33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000c06d01000b3330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000c00c1001033bb33000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000c6510000b4430000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006005000309403000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c100c100009400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000777777777d000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000007766666666dd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000077766666666ddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000777766666666dddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007777766666666ddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0077777666666666dddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0777776666666666ddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777766666666666dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666666ddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7666666666dddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
766666666ddddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666dddddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666dddddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666ddddddd55555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666dddddd555555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666ddddd5555555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd555555555551111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddddddd555555555511111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddddd555555555111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ddddd555555551111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000dddd555555551111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ddd555555551110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000dd555555551100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000d111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__gff__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000010001000000000000000000000000000101010000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000002000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000404141420000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000040515151514142000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5202024051515151515151420200025000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5141414151515151515151514141415100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

