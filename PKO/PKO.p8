pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--p8_redefs
--redefinitions of pico-8
--built-ins

_old_line = line
line=nil
function d_line(a,b,c)
	return _old_line(
		a.x,
		a.y,
		b.x,
		b.y,
		c)
end

_old_circ = circ
circ=nil
function s_circ(p,r,c)
	return _old_circ(
		p.x,
		p.y,
		r,
		c)
end

_old_circfill = circfill
circfill=nil
function f_circ(p,r,c)
	return _old_circfill(
		p.x,
		p.y,
		r,
		c)
end

_old_rect = rect
rect=nil
function s_rect(a,b,c)
	return _old_rect(
		a.x,
		a.y,
		b.x,
		b.y,
		c)
end

_old_rectfill = rectfill
rectfill=nil
function f_rect(a,b,c)
	return _old_rectfill(
		a.x,
		a.y,
		b.x,
		b.y,
		c)
end

_old_clip = clip
clip=nil
function setclip(r)
	return _old_clip(
		r.min.x,
		r.min.y,
		r.max.x,
		r.max.y
	)
end

_old_camera = camera
camera=nil
function setcam(p)
	return _old_camera(p.x,p.y)
end

_old_pset = pset
pset=nil
function d_point(p,c)
	return _old_pset(
		p.x,
		p.y,
		c
	)
end

_old_tostr = tostr
function tostr(s)
	if(not s) return "nil"
	if(type(s) == "string") return s
	if(type(s) == "number") return _old_tostr(s)
	if(type(s) == "boolean") return _old_tostr(s)
	
	if(s.__tostr) then
		return s:__tostr()
	else
		return _old_tostr(s)
	end
end

_old_print = print
function print(s,p,c)
	s = tostr(s)
	c = c or 7

	if(not p) return _old_print(s)

	return _old_print(
		s.."\n",
		p.x,
		p.y,
		c
	)
end

_old_mget = mget
function mget(p)
	return _old_mget(p.x, p.y)
end

_old_mset = mset
function mset(p,c)
	return _old_mset(p.x, p.y,c)
end

_old_atan2 = atan2
function atan2(v)
	return _old_atan2(v.y,v.x)
end

_old_sget = sget
function sget(pos)
	return _old_sget(pos.x,pos.y)
end

_old_spr = spr
function spr(s,p,sz)
	return _old_spr(
		s,
		p.x,
		p.y,
		sz.x,
		sz.y
	)
end--logging
--log functionality and
--wrappers for built-in
--string and print handling
-------------------------------
log_buf = {}
log_count = 1
log_limit = 1000
function log(s)
	local str = log_count..">"
	str = str..tostr(s)
	add(log_buf,str)
	if(#log_buf>log_limit) then
		del(log_buf,log_buf[1])
	end
	log_count += 1
end

function getcursor()
	cr = vec2:new()
	cr.x = peek(0x5f26)
	cr.y = peek(0x5f27)
	return cr
end
--object
--basic scene graph unit
-------------------------------
obj_count=0

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

-- get the class default object
-- a.k.a. metatable
function obj:cdo()
	return getmetatable(self)
end

function obj:is_a(t)
	local c = self:cdo()
	while c do
		if(c == t) return true
		c = c:cdo()
	end

	return false
end

function obj:init()
	obj_count+=1
	self.children = {}
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

function obj:__tostr()
	return self.name
end

function obj.__concat(lhs, rhs)
	if(type(lhs)=="table") then
		return lhs:__tostr()..rhs
	end

	if(type(rhs)=="table") then
		return lhs..rhs:__tostr()
	end
end

function obj:print(pf)
	pf=pf or ""
	local str = pf
	str=str..self:__tostr()
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

function obj:detach()
	if(self.parent) then
		self.parent:remchild(self)
		self.parent=nil
	end
end

function obj:destroy()
	self:detach()
	
	if(#self.children>0) then
 	while #self.children>0 do
 		self.children[1]:destroy()
 	end
	end
	
	obj_count-=1
end
--time
--wrapper for pico8 time
--functionality
-------------------------------
time={
	dt=nil
}

function time:update()
	if self.dt == nil then
		self.dt=1/self:fpstarget()
	end
end

function time:cpu_t()
	return stat(1)
end

function time:syscpu_t()
	return stat(2)
end

function time:fps()
	return stat(7)
end

function time:fpstarget()
	return stat(8)
end
--sprites
--wrapper for pico8 sprite
--functionality
-------------------------------
--sprite pos > sprite index
--@spos vec2 sprite pixel coords
--@return number sprite index
function spos2idx(spos)
	local dp = spos/8
	return stile2idx(
		vec2:new(
			flr(dp.x),
			flr(dp.y)
		)
	)
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

	local xb,xe,yb,ye=0,7,0,7

	if(xs<0) xb,xe=7,0
	if(ys<0) yb,ye=7,0
	
	local sp = sidx2pos(s)

	if(not f) then
		for x=xb,xe,xs do
			for y=yb,ye,ys do
				if(sget(vec2:new(sp.x+x,sp.y+y)) > 0) then
					return vec2:new(x,y)
				end
			end
		end
	else
		for y=yb,ye,ys do
			for x=xb,xe,xs do
				if(sget(vec2:new(sp.x+x,sp.y+y)) > 0) then
					return vec2:new(x,y)
				end
			end
		end
	end
end

--traces the edges of the
--given sprite in clockwise
--order to generate a
--simplified collision mesh
function convex_hull(s)
	local vs = {}

	local sp = sidx2pos(s)

	add(vs,trace_edge(s,1,1,true)-4)
	add(vs,trace_edge(s,-1,1,true)-4)

	add(vs,trace_edge(s,-1,1)-4)
	add(vs,trace_edge(s,-1,-1)-4)

	add(vs,trace_edge(s,-1,-1,true)-4)
	add(vs,trace_edge(s,1,-1,true)-4)

	add(vs,trace_edge(s,1,-1)-4)
	add(vs,trace_edge(s,1,1)-4)

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

	for v in all(vs) do
		if(v.x > 0) v.x += 1
		if(v.y > 0) v.y += 1
	end

	return vs
end
--vec2
--two dimensional vector
-------------------------------
vec2={
	x=0,
	y=0
}

function vec2:new(x,y)
	self.__index=self
	return setmetatable({
		x=x or 0,
		y=y or 0
	}, self)
end

function vec2:is_a(t)
	return t == vec2
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

function vec2:copy()
	return vec2:new(self.x,self.y)
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

function vec2:rotate(a)
	local x = self.x * cos(a) + self.y * sin(a)
	local y = -self.x * sin(a) + self.y * cos(a)
	return vec2:new(x,y)
end

function vec2:perp_cw()
	return vec2:new(-self.y,self.x)
end

function vec2:perp_ccw()
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

function vec2:__tostr()
	return "x:"..self.x..
	",y:"..self.y
end

function vec2.__concat(lhs,rhs)
	if(type(lhs)=="table") then
		return lhs:__tostr()..rhs
	end

	if(type(rhs)=="table") then
		return lhs..rhs:__tostr()
	end
end

geo={
	name="geo",
	vs=nil,				--vertices
	be=nil,				--box extents
	cr=nil					--circle radius
}

function geo:new(v)
	self.__index=self

	local o = setmetatable({}, self)

	if(type(v) == "table") then
		if(v.is_a and v:is_a(vec2)) then
			o.be = v
			o:calculate_circle()
		else
			o.vs=v
			o:calculate_box()
			o:calculate_circle()
		end
	else
		o.cr = v
	end

	return o
end

	function geo:calculate_box()
	local bmin = nil
	local bmax = nil

	for v in all(self.vs) do
		if(bmin == nil) then
			bmin = vec2:new(v.x,v.y)
		else
			if(bmin.x > v.x) bmin.x = v.x
			if(bmin.y > v.y) bmin.y = v.y
		end
		if(bmax == nil) then
			bmax = vec2:new(v.x,v.y)
		else
			if(bmax.x < v.x) bmax.x = v.x
			if(bmax.y < v.y) bmax.y = v.y
		end
	end

	self.be=vec2:new(
		(bmax.x-bmin.x)/2,
		(bmax.y-bmin.y)/2
	)
end

function geo:calculate_circle()
	self.cr=max(self.be.x,self.be.y)
end

function geo:__eq(rhs)
	if(self.cr!=rhs.cr) return false
	if(self.be!=rhs.be) return false
	if(#self.vs != #rhs.vs) return false
	for i = 1, #self.vs do
		if(self.vs[i] != rhs.vs[i]) return false
	end
	return true
end

--collision
--wrapper for collision
--functionality
-------------------------------
resp={
	n=vec2:new(), --normal
	pd=0,         --penetrate dist
	cp=vec2:new() --contact point
}

function resp:new(n,pd,cp)
	self.__index=self
	return setmetatable({
		n=n or vec2:new(),
		pd=pd or 0,
		cp=cp or vec2:new()
	}, self)
end

function resp:flip()
	self.n = -self.n
	self.cp += self.n*self.pd
end

col={
	sprite_geo={},
	map_geo={}
}

function col:init(numspr)
	numspr = numspr or 128

	print("generating sprite collision...")
	for i=0,numspr-1 do
		if(fget(i)>0) then
		 local vs = convex_hull(i)
			self.sprite_geo[i] =
				geo:new(vs)
		end
	end

	print("generating map collision...")
	self:generate_map_geo()
end

function col:generate_map_geo(min,max)
	min = min or vec2:new(0,0)
	max = max or vec2:new(63,31)
	
	-- create geo for each map tile
	for y = min.y,max.y do
		self.map_geo[y+1] = {}
		for x = min.x,max.x do
			self.map_geo[y+1][x+1] = {}
			local p = vec2:new(x,y)
			local s = mget(p)
			if s > 0 then
				self.map_geo[y+1][x+1] = {
					t=trs:new((p*8)+4),
					geo=self.sprite_geo[s]
				}
			end
		end
	end

	local square_geo = geo:new({
		vec2:new(4,-4),
		vec2:new(4,4),
		vec2:new(-4,4),
		vec2:new(-4,-4),
	})
		
	-- merge vertical lines of square tiles
	for y = 1,#self.map_geo do
		for x = 1,#self.map_geo[y] do
			local sg = self.map_geo[y][x]
				if sg.geo != nil and sg.geo == square_geo and sg.t.s == vec2:new(1,1) then
				for e = y+1,#self.map_geo do
					local eg = self.map_geo[e][x]
					if(eg.geo == nil) break
					if(eg.geo != square_geo) break
					if(eg.t.s != vec2:new(1,1)) break
					self.map_geo[e][x] = {ptr=vec2:new(x,y)}
					local nx = x - 1
					local ny = y + ((e-y)-1)/2
					self.map_geo[y][x].t.t =	vec2:new(
						(nx*8)+4,
						(ny*8)
					)
					self.map_geo[y][x].t.s.y = (e-y)+1
				end
			end
		end
	end

	-- merge horizontal lines of square tiles
	for y = 1,#self.map_geo do
		for x = 1,#self.map_geo[y] do
			local sg = self.map_geo[y][x]
			if sg.geo != nil and sg.geo == square_geo and sg.t.s == vec2:new(1,1) then
				for e = x+1,#self.map_geo[y] do
					local eg = self.map_geo[y][e]
					if(eg.geo == nil) break
					if(eg.geo != square_geo) break
					self.map_geo[y][e] = {ptr=vec2:new(x,y)}
					local nx = x + ((e-x)-1)/2
					local ny = (y-1)
					self.map_geo[y][x].t.t =	vec2:new(
						(nx*8),
						(ny*8)+4
					)
					self.map_geo[y][x].t.s.x = (e-x)+1
				end
			end
		end
	end
end

--unified collision test
function col:isect(at,ag,bt,bg)
	if(not self:c_isect_c(at,ag.cr,bt,bg.cr)) return nil
	if(not self:b_isect_b(at,ag.be,bt,bg.be)) return nil
	return self:py_isect_py(at,ag.vs,bt,bg.vs)
end

--circle intersect circle
function col:c_isect_c(at,ar,bt,br)
	return (bt.t-at.t):len() <
								(max(at.s.x,at.s.y) * ar) +
								(max(bt.s.x,bt.s.y) * br)
end

function col:b_isect_b(at,ae,bt,be)
	local ap = at.t
	local bp = bt.t
	local sae = ae * at.s
	local sbe = be * bt.s

	local a1 = ap - sae
	local a2 = ap + sae
	local b1 = bp - sbe
	local b2 = bp + sbe

	return a1.x < b2.x and
								a2.x > b1.x and
								a1.y < b2.y and
								a2.y > b1.y
end

--poly intersect poly
function col:py_isect_py(at,avs,bt,bvs)
	local ap = at.t
	local as = at.s
	local bp = bt.t
	local bs = bt.s
	local d = ap - bp
	local dn = d:normalize()

	local f = self:py_get_face(ap,bt,bvs)
	local fv1 = f.v1
	local fv2 = f.v2
	local fd = fv2 - fv1
	local fdn = fd:normalize()
	local fn = fdn:perp_ccw()

	local lscd = d - fv1
	local lecd = d - fv2
	
	local clp = fdn:dot(lscd)
	local rn = fn
	
	if(clp < 0) then
		rn = (d-fv1):normalize()
	end

	if(clp > fd:len()) then
		rn = (d-fv2):normalize()
	end

	local amin = nil
	for v in all(avs) do
		local apr = rn:dot(v*as)
		if amin==nil or amin > apr then
			amin = apr
		end
	end

	local bmax = nil
	for v in all(bvs) do
		local bpr = rn:dot(bp+(v*bs)-ap)
		if bmax==nil or bmax < bpr then
			bmax = bpr
		end
	end

	if(amin < bmax) then
		local fp = fdn:dot(d-fv1)

		local rcp = bp + fv1 + (fdn * fp)
		
		if(clp < 0) then
			rn = (d-fv1):normalize()
			rcp = bp + fv1
		end

		if(clp > fd:len()) then
			rn = (d-fv2):normalize()
			rcp = bp + fv2
		end

		return resp:new(
			rn,
			bmax - amin,
			rcp
		)
	end
end

function col:py_get_face(p,pt,pvs)
	local pp = pt.t
	local ps = pt.s

	local d = p - pp
	local dn = d:normalize()
	local da = atan2(dn)

	for i=1,#pvs do
		local v1 = pvs[i]*ps
		local v2 = pvs[i+1] or pvs[1]
		v2 *= ps

		local a1 = atan2(v1)
		local a2 = atan2(v2)

		local fi = false
		if a1 < a2 then
			if da >= a1 and da <= a2 then
				fi = true
			end
		else
			if da >= a1 or da <= a2 then
				fi = true
			end
		end

		if fi then
			return { v1=v1, v2=v2 }
		end
	end
end
--input
--collection of input wrappers
-------------------------------
--enable devkit input
poke(0x5f2d,1)

--controller
--wrapper for pico8 gamepad
-------------------------------
controller = {
	p=0,							--player index
	dpad=vec2:new(),

	a=false,			--a button
	_la=false,	--last a button
	ap=false,		--a pressed
	
	b=false,			--b button
	_lb=false,	--last b button
	bp=false			--b pressed
}

function controller:new(p)
	self.__index=self
	return setmetatable({
		p=p or 0
	}, self)
end

function controller:update()
	local wx = 0
	if(btn(0,self.p)) wx -= 1
	if(btn(1,self.p)) wx += 1

	local wy = 0
	if(btn(2,self.p)) wy -= 1
	if(btn(3,self.p)) wy += 1

	self.dpad = vec2:new(wx,wy)

	self._la = self.a
	self.a=btn(4,self.p)
	self.ap=self.a and not self._la

	self._lb = self.b
	self.b=btn(5,self.p)
	self.bp=self.b and not self._lb
end

--controller
--wrapper for keyboard input
-------------------------------
kb = {
	kp=nil,
	kc=nil
}

function kb:update()
	self.kp=stat(30)
	self.kc=stat(31)
end

function kb:keyp(char)
	return self.kp and self.kc == char
end

--mouse
--wrapper for mouse input
-------------------------------
mouse = {
	mp=vec2:new(),
	mb=0
}

function mouse:update()
	self.mp=vec2:new(stat(32),stat(33))
	self.mb=stat(34)
end



--engine
--collection of engine
--functionality
-------------------------------
engine={
	_sg=obj:new(nil,{
		name="root"
	}),
	_sg_wrap=nil,
	_dev_ui=nil,
	_scenes={},
	_active_scene=nil
}

engine._sg_wrap = obj:new(
	engine._sg,
	{
		name="scene wrapper"
	}
)

function engine:set_active_scene(am)
	for m in all(self._scenes) do
		if(m.name == am) then
			if self._active_scene != nil then
				self._active_scene.sg:detach()
			end
			self._active_scene = m
			if self._active_scene != nil then
				self._sg_wrap:addchild(m.sg)
			end
			break
		end
	end
end

function engine:get_active_scene()
	return self._active_scene
end

--initialization
-------------------------------
function _init()
	cls()
	print "ko engine"
	print "-------------------"

	print "initializing..."
	if not engine._active_scene then
		print "error: no scene loaded"
		return
	end

	
	if(debug != nil) then
		debug.ts_init_b=time:cpu_t()
		print "debug ui..."
		engine._dev_ui=dbg_ui:new(nil)
	end

	--enable color literals
	print "color literals..."
	poke(0x5f34,1)

	--initialize engine
	print "collision..."
	col:init()

	--initialize scenes
	print "scenes..."
	for m in all(engine._scenes) do
		m:init()
	end
	
	if(debug != nil) then
		engine._sg:addchild(engine._dev_ui)
		debug.ts_init_e=time:cpu_t()
	end
end

--main loop
-------------------------------
function _update60()
	if(not engine._active_scene) return
	
	time:update()

	local dm = debug != nil
	if(dm) then
		debug.ts_update_s=time:cpu_t()
	end

	--update input
	controller:update()
	if(dm) then
		kb:update()
		mouse:update()
	end

	--update scenegraph
	engine._sg:update()

	if(dm) then
		debug.ts_update_e=time:cpu_t()
	end
end

--render loop
-------------------------------
function _draw()
	if(not engine._active_scene) return

	local dm = debug != nil
	if(dm) then
		debug.ts_draw_s=time:cpu_t()
	end

	-- draw scenegraph
	engine._sg:draw()
	
	if(dm) then
		debug.ts_draw_e=time:cpu_t()
	end
end

--trs
--transform
-------------------------------
trs={
	t=nil,		--translate
	r=0,				--rotate
	s=nil,			--scale
	a=false		--absolute
}

function trs:new(t,r,s,a)
	local t = t or vec2:new()
	local r = r or 0
	local s = s or vec2:new(1,1)
	local a = a or false
	
	self.__index=self
	return setmetatable({
		t = t,
		r = r or 0,
		s = s,
		a = a
	}, self)
end

function trs:is_a(t)
	return t == trs
end

function trs:__mul(rhs)
	return trs:new(
		self.t+rhs.t,
		self.r+rhs.r,
		self.s*rhs.s
	)
end

function trs:__tostr()
	return "trs t:"..self.t..
								",r:"..self.r..
								",s:"..self.s
end

function trs.__concat(lhs,rhs)
	if(type(lhs)=="table") then
		return lhs:__tostr()..rhs
	end

	if(type(rhs)=="table") then
		return lhs..rhs:__tostr()
	end
end

--primitive
--object with transform
-------------------------------
prim=obj:subclass({
	name="primitive",
	trs=nil											--transform
})

function prim:init()
	obj.init(self)
	self.trs = self.trs or trs:new()
end

function prim:t()
	local t = trs:new()

	local c = self
	while c != nil do
		local ct = c.trs
		if(ct) then
			t = t * ct
			if(ct.a) return t
		end
		c = c.parent
	end

	return t
end

function prim:__tostr()
	return
		obj.__tostr(self).." - "..
		self.trs:__tostr()
end

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

	local cp = drawstate:campos()
	local d = self:t().t - cp
	--if(d.x<0 or d.y<0 or d.x>127 or d.y>127) return
	
	self:g_draw()
	
 prim.draw(self)
end

function graphic:g_draw()
end

function graphic:col_mask(m)
	m = m or 255
	return band(self.cm,m) > 0
end
--drawstate
--wrapper for pico8
--internal draw state
-------------------------------
drawstate={}

function drawstate:campos()
	return vec2:new(
		peek4(0x5f26),
		peek4(0x5f28)
	)
end

function drawstate:getclip()
	local x1 = peek(0x5f20)
	local y1 = peek(0x5f21)
	return rect:new(
		x1,
		y1,
		peek(0x5f22)-x1,
		peek(0x5f23)-y1
	)
end

--pointer
--mouse pointer
-------------------------------
pointer=prim:subclass({
	name="pointer"
})

function pointer:init()
	prim.init(self)
	self.trs.a = true
end

function pointer:update()
	prim.update(self)
	self.trs.t = drawstate:campos() + mouse.mp
end

--shape
--graphic with
--stroke/fill colors
-------------------------------
shape=graphic:subclass({
	name="shape",
	s=true,
	sc=6,
	f=true,
	fc=7,
	cm=255
})

function shape:g_draw()
	if(not self.v) return
	
	if(self.f) self:draw_fill()
	if(self.s) self:draw_stroke()
	
	graphic.g_draw(self)
end

function shape:draw_stroke()
end

function shape:draw_fill()
end

--box
--rect shape
-------------------------------
box=shape:subclass({
	name="box",
	sz=nil						--size
})

function box:init()
	shape.init(self)
	self.sz = self.sz or
											vec2:new(4,4)
end

function box:draw_fill()
	local t = self:t()
	local p = t.t
	local sz = self.sz * t.s
	f_rect(
		p-sz,
		p+sz,
 	self.fc
 )
end

function box:draw_stroke()
	local t = self:t()
	local p = t.t
	local sz = self.sz * t.s
	s_rect(
		p-sz,
		p+sz,
 	self.sc
 )
end

--text
--text graphic
-------------------------------
text=graphic:subclass({
	name="text",
	str=""
})

function text:g_draw()
	if(not self.v) return
	
	print(
		self.str,
		self:t().t
	)
	
	graphic.g_draw(self)
end
--debug panel
-------------------------------
dbg_panel=graphic:subclass({
	name="debug panel",
	sz=nil,
	sy=0,
	key=nil,
	v=false
})

function dbg_panel:init()
	self.trs = self.trs or
												trs:new(
													vec2:new(61,66)
												)

	graphic.init(self)

	self.sz = self.sz or
												vec2:new(61,56)

	box:new(self,{
		sz=self.sz,
		sc=0x1107.0000,
		fc=0x1100.5a5a
	})
end

function dbg_panel:update()
	if(not self.v) return

	local sy = self.sy
	
	if(kb:keyp("-")) sy -= 114
	if(kb:keyp("=")) sy += 114
	if(kb:keyp("[")) sy -= 6
	if(kb:keyp("]")) sy += 6
	
	self.sy = max(sy,0)
	
	graphic.update(self)
end

function dbg_panel:__tostr()
	local w = self.w

	return
		prim.__tostr(self).." "..
		"w:"..flr(w)..","..
		"w:"..flr(w)
end

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
		trs=trs:new(vec2:new(-58,-54))
	})
end

function dbg_ovr:update()
	dbg_panel.update(self)
	
	if(not self.v) return
	
	local str = ""
	
	--memory
	local mem=stat(0)
	
	--cpu
	local icpu = debug.ts_init_e-debug.ts_init_s
	
	local ucpu = debug.ts_update_e-debug.ts_update_s
	local dcpu = debug.ts_draw_e-debug.ts_draw_s
	local tcpu = ucpu+dcpu

	local fps = time:fps()
	local tfps = time:fpstarget()
	
	str=str..
		"    memory: "..mem.." kib\n"..
		"\n"..
		"   init cpu: "..(icpu*100).." %\n"..
		"\n"..
		" update cpu: "..(ucpu*100).." %\n"..
		"   draw cpu: "..(dcpu*100).." %\n"..
		"  total cpu: "..(tcpu*100).." %\n"..
		"\n"..
		"target fps: "..tfps.."\n"..
		"       fps: "..fps.."\n"..
		"\n"..
		" obj_count: "..obj_count
		
	self.tw.str=str
end

--primitive
--object with transform
-------------------------------
clip=obj:subclass({
	name="clip",
	r=nil								-- clipping rect
})

function clip:init()
	obj.init(self)
	self.r = self.r or rect:new()
end

function clip:draw()
	local cclip=drawstate:getclip()
	setclip(self.r)
	obj.draw(self)
	setclip(cclip)
end

function clip:__tostr()
	return obj.__tostr(self).." - r:"..self.r
end

--rect
--rectangle
-------------------------------
rect={
	min=vec2:new(),
	max=vec2:new()
}

function rect:new(x1,y1,x2,y2)
	x1 = x1 or 0
	y1 = y1 or 0
	x2 = x2 or 1
	y2 = y2 or 1
	
	self.__index=self
	return setmetatable({
		min=vec2:new(x1,y1),
		max=vec2:new(x2,y2)
	}, self)
end

function rect:is_a(t)
	return t == rect
end

function rect:__tostr()
	return "min:"..self.min..
	",max:"..self.max
end

function rect.__concat(lhs,rhs)
	if(type(lhs)=="table") then
		return lhs:__tostr()..rhs
	end

	if(type(rhs)=="table") then
		return lhs..rhs:__tostr()
	end
end


--debug log
-------------------------------
dbg_log=dbg_panel:subclass({
	name="log",
	key="2",
	cw=nil,
	tw=nil
})

function dbg_log:init()
	dbg_panel.init(self)

	local cw=clip:new(self,{
		r=rect:new(2,10,124,116)
	})
	self.cw = cw
	
	self.tw=text:new(cw,{
		trs=trs:new(vec2:new(-58,-54))
	})
end

function dbg_log:update()
	dbg_panel.update(self)
	
	if(not self.v) return
	
	local str=""
	for s in all(log_buf) do
		str = str..s.."\n"
	end
	
	local tw = self.tw
	tw.trs.t.y=-54-self.sy
	tw.str=str
end
--debug scenegraph
-------------------------------
dbg_sg=dbg_panel:subclass({
	name="scenegraph",
	key="3",
	cw=nil,
	tw=nil
})

function dbg_sg:init()
	dbg_panel.init(self)

	self.cw=clip:new(self,{
		r=rect:new(2,12,122,112)
	})
	
	self.tw=text:new(self.cw,{
		trs=trs:new(vec2:new(-58,-54))
	})
end

function dbg_sg:update()
	dbg_panel.update(self)
	
	if(not self.v) return

	local tw = self.tw
	tw.trs.t.y=-54-self.sy
	tw.str=engine:get_active_scene().sg:print()
end


--debug ui
dbg_ui=graphic:subclass({
	name="debug ui",
	trs=trs:new(),
	tabs=nil,
	at=nil,
	tw=nil,
	pw=nil,
	wrap=nil
})

function dbg_ui:init()
	graphic.init(self)
	
	local wrap=graphic:new(self,{
		name="wrap"
	})
	self.wrap = wrap
	
	local bg=box:new(wrap,{
		trs=trs:new(vec2:new(61,5)),
		sz=vec2:new(61,4),
		sc=0x1107.0000,
		fc=0x1100.5a5a
	})
	
	self.tw=text:new(bg,{
		trs=trs:new(vec2:new(-58,-2))
	})
	
	local tabs = {}
	tabs["1"]=
		dbg_ovr:new(wrap)
	tabs["2"]=
		dbg_log:new(wrap)
	tabs["3"]=
		dbg_sg:new(wrap)
	self.tabs=tabs

	self.pw=pointer:new(self.wrap)
end

function dbg_ui:update()
	graphic.update(self)
	self.trs.t=drawstate:campos()+2

	local tabs = self.tabs
	local at = self.at
	
	for k,tab in pairs(tabs) do
 	if(kb:keyp(k)) then
 		if(at!=k) then
				at=k
				self.tw.str=tab.name
			else
				at=nil
			end
 	end
	end
	
	for k,tab in pairs(tabs) do
		tab.v=k==at
	end
	
	self.at = at
	self.wrap.v = at != nil
end
--debug coordinate axis
-------------------------------
dbg_axis=graphic:subclass({
	name="debug axis",
	axis=nil,
	sz=5,
	a=0
})

function dbg_axis:init()
	graphic.init(self)
	self.axis = self.axis or
													vec2:new(0,1)
end

function dbg_axis:g_draw()
	local trs = self:t()
	local t = trs.t

	local o = (self.axis*self.sz):rotate(trs.r)

	d_line(
		t,
		t + o,
		12
	)

	d_line(
		t,
		t + o:perp_ccw(),
		8
	)
end
dbg_spr_col=obj:subclass({
	name="debug map collision"
})

function dbg_spr_col:init()
	obj.init(self)
	
	for k,geo in pairs(col.sprite_geo) do
		circle:new(self,{
			trs=trs:new(
				vec2:new(
					4+(k%16)*10,
					4+flr(k/16)*10
				)
			),
			r=geo.cr,
			sc=9,
			f=false
		})
		box:new(self,{
			trs=trs:new(
				vec2:new(
					4+(k%16)*10,
					4+flr(k/16)*10
				)
			),
			sz=geo.be,
			sc=11,
			f=false
		})
		poly:fromsprite(self,k,{
			trs=trs:new(
				vec2:new(
					4+(k%16)*10,
					4+flr(k/16)*10
				)
			),
		})
	end
end

--poly
--n-sided shape
-------------------------------
poly=shape:subclass({
	name="poly",
	vs=nil							--vertices
})

function poly:init()
	shape.init(self)
	self.vs = self.vs or {}
end

function poly:fromsprite(p,s,t)
	t = t or {}
	t.geo=col.sprite_geo[s]
	assert(t.geo)
	t.cm=fget(s)
	return poly:new(p,t)
end

function poly:draw_stroke()
	local p = self:t().t
	local s = self:t().s
	local vs = self.geo.vs

	for i=1,#vs do
		local v1 = vs[i]:copy()
		local v2 = (vs[i+1] or vs[1]):copy()

		if(v1.x > 0) v1.x -= 1
		if(v1.y > 0) v1.y -= 1
		if(v2.x > 0) v2.x -= 1
		if(v2.y > 0) v2.y -= 1

		v1 *= s
		v1 += p

		v2 *= s
		v2 += p

		d_line(v1,v2,self.sc)
	end

	for i=1,#vs do
		local v1 = vs[i]:copy()

		if(v1.x > 0) v1.x -= 1
		if(v1.y > 0) v1.y -= 1

		v1 *= s
		v1 += p

		d_point(v1,8)
	end
end

dbg_map_col=obj:subclass({
	name="debug map collision"
})

function dbg_map_col:init()
	obj.init(self)
	
	for y in all(col.map_geo) do
		for x in all(y) do
			if x.geo != nil then
				poly:new(self,{
					trs=x.t,
					geo=x.geo
				})
				
				circle:new(self,{
					trs=x.t,
					r=x.geo.cr,
					sc=9,
					f=false
				})

				box:new(self,{
					trs=x.t,
					sz=x.geo.be,
					sc=11,
					f=false
				})
			end
		end
	end
end

debug={
	ts_init_s = 0,
	ts_init_e = 0,
	ts_update_s = 0,
	ts_update_e = 0,
	ts_draw_s = 0,
	ts_draw_e = 0
}
scene={
	name="scene",
	sg=nil
}

function scene:new(t)
	self.__index=self
	local o = setmetatable(
		t or {},
		self
	)
	o.sg = obj:new(nil)
	add(engine._scenes, o)
	return o
end

function scene:init()
	self.sg.name = self.name
end

--primitive
--object with transform
-------------------------------
clear=obj:subclass({
	name="clear",
	c=0	--color
})

function clear:draw()
	cls(self.c)
	obj.draw(self)
end

function clear:__tostr()
	return obj.__tostr(self).." - c:"..self.c
end

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
	
	d_point(
		self:t().t,
 	self.c
 )
	
	graphic.g_draw(self)
end
--debug game
--debugging scene

debug_game=scene:new({
	name="debug game",
	cp_axis=nil,
	pd_axis=nil
})

--initialization
-------------------------------
function debug_game:init()
	scene.init(self)

	--initial scene clear
	clear:new(self.sg)
	camera:new(self.sg,{
		trs=trs:new(vec2:new(64,64))
	})

	--debug ui
	if(debug != nil) then
		local p1 = poly:fromsprite(self.sg,1,{
			trs=trs:new(
				vec2:new(32,64),
				0,
				vec2:new(3,3)
			)
		})

		local p2 = poly:fromsprite(self.sg,3,{
			trs=trs:new(
				vec2:new(96,64),
				0,
				vec2:new(4,4)
			)
		})

		local cp_axis = dbg_axis:new(self.sg)
		local pd_axis = dbg_axis:new(self.sg)
		p1.update = function(self)
			dot.update(self)
			
			local r = col:isect(p1:t(),p1.geo,p2:t(),p2.geo)
			if r != nil then
				cp_axis.trs.t = r.cp
				cp_axis.trs.r = atan2(r.n)
				pd_axis.trs.t = r.cp+(-r.n*r.pd)
				pd_axis.trs.r = atan2(r.n)
			end
		end
	end
end

--map
--map graphic
-------------------------------
obj_map=graphic:subclass({
	name="map",
	mtile=nil,
	sz=nil
})

function obj_map:init()
	graphic.init(self)
	self.mtile = self.mtile or
														vec2:new()
	self.sz = self.sz or
											vec2:new(16,16)
end

function obj_map:update()
	local cp = drawstate:campos()
	local ts = cp % 8
	self.trs.t = cp - ts
	local mt = self.trs.t/8
	self.mtile.x = flr(mt.x)
	self.mtile.y = flr(mt.y)
	graphic.update(self)
end

function obj_map:g_draw()
	if(not self.v) return
	
	local pos=self:t().t
	
	map(
		self.mtile.x-1,
		self.mtile.y-1,
		pos.x-8,
		pos.y-8,
		self.sz.x+2,
		self.sz.y+2
	)
	
	graphic.g_draw(self)
end
--map
--wrapper for pico8 map
--functionality
-------------------------------
--map pos > map tile
--@pos vec2 map pixel coords
--@return vec2 map tile coords
function mpos2tile(pos)
	return vec2:new(
		flr(pos.x/8),
		flr(pos.y/8)
	)
end

--map tile > map pos
--@mtile vec2 map tile coords
--@return vec2 map pixel coords
function mtile2pos(mtile)
	return mtile*8
end

function map_sprite_at(p,max)
	max=max or vec2:new(255,127)

	if(p.x < 0 or
				p.y < 0) then
		return -1
	end

	local mp = mpos2tile(p)

	if(mp.x > max.x or
				mp.y > max.y) then
		return -1
	end

	--fetch sprite from map
	return mget(mp)
end

function map_sprites_in(p1,p2,max)
	max=max or vec2:new(255,127)

	local mp1 = mpos2tile(p1)
	local mp2 = mpos2tile(p2)

	ss={}

	for x=mp1.x,mp2.x do
		for y=mp1.y,mp2.y do
			local s = mget(vec2:new(x,y))
			if(s>0) then
				local st = {
					trs=trs:new(
						vec2:new(
							(x*8)+4,
							(y*8)+4
						)
					),
					s=s
				}
				add(ss,st)
			end
		end
	end

	return ss
end

function map_isect(ot,og)
	local op = ot.t
	local ocr = og.cr
	local o1 = mpos2tile(op - ocr)
	local o2 = mpos2tile(op + ocr)

	local crs = {}
	for y = max(o1.y+1,1),o2.y+1 do
		for x = max(o1.x+1,1),o2.x+1 do
			local mg = col.map_geo[y][x]
			if(mg.ptr) mg = col.map_geo[mg.ptr.y][mg.ptr.x]
			if(mg.geo != nil) then
				local r = col:isect(
					ot,
					og,
					mg.t,
					mg.geo
				)
				if(r) add(crs,r)
			end
		end
	end

	return crs
end

function map_contains(p,m)
	m = m or 255
	
	local s = map_sprite_at(p)

	if(s>0) then
		local sp = sidx2pos(s)
		local cm = fget(s)

		if(band(m,cm) == 0) then
			return false
		end

		return sget(sp+(p%8))>0
	end

	return false
end

function map_find_sprites(s,tm)
	tm = tm or vec2:new(255,127)

	local coords = {}
	for y=0,tm.y-1 do
		for x=0,tm.x-1 do
			local p = vec2:new(x,y)
			local ms = mget(p)
			if(ms == s) then
				add(coords,p)
			end
		end
	end

	return coords
end

--spawner
--replaces sprites in the map
--with their object
--counterpart
-------------------------------
spawner=obj:subclass({
	name="spawner",
	objs=nil
})

function spawner:init()
	prim.init(self)

	self.objs = self.objs or {}

	for obj in all(self.objs) do
		local ps = map_find_sprites(obj.s)
		for p in all(ps) do
			mset(p, 0)
			col.map_geo[p.y+1][p.x+1]={}

			obj.o:new(obj.p,{
				trs = trs:new((p*8)+4)
			})
		end
	end
end

--sprite
--sprite graphic
-------------------------------
sprite=graphic:subclass({
	name="sprite",
	sz=nil,			--size
	s=0																	--sprite
})

function sprite:init()
	self.sz = self.sz or
											vec2:new(1,1)
end

function sprite:g_draw()
	if(not self.v) return
	
	spr(
		self.s,
		self:t().t,
		self.sz
	)
	
	graphic.g_draw(self)
end

--actor
--dynamic primitive
-------------------------------
actor=prim:subclass({
	name="actor",
	s=0,					--sprite
	h=5,					--health
	_sc=nil,	--sprite component
	_geo=nil,	--geometry
})

function actor:init()
	prim.init(self)

	self._sc=sprite:new(self,{
		trs=trs:new(vec2:new(-4,-4)),
		s=self.s
	})
	self._geo = col.sprite_geo[self.s]
end

function actor:damage(d)
	self.h -= d
	if self.h <= 0 then
		self.die()
	end
end

function actor:die()
	self.destroy()
end

--move
--object for moving a parent
-------------------------------
move=obj:subclass({
	name="move",
	dp=nil,
	geo=nil,
	da=nil         --debug axis
})

function move:init()
	obj.init(self)
	self.dp = self.dp or vec2:new()
	self.da = dbg_axis:new(self)
	self.da.trs.a = true
end

function move:update()
	self.parent.trs.t += self.dp
	self.dp=vec2:new()
	
	if(self.geo) then
		local crs = map_isect(
			self.parent:t(),
			self.geo
		)

		local i = 5
		while i > 0 do
			local ccp = nil
			local ccr = nil
			for cr in all(crs) do
				local d = self.parent:t().t - cr.cp
				local dl = d:len()
				if ccp == nil or ccp < dl then
					ccp = dl
					ccr = cr
				end
			end

			if(ccr != nil) self:collision(ccr)

			crs = map_isect(
				self.parent:t(),
				self.geo
			)

			if(#crs == 0) break
			i -= 1
		end
	end
end

function move:collision(r)
	self.parent.trs.t += r.n * (r.pd+0.0001)
	self.da.trs.t = r.cp
	self.da.trs.r = atan2(r.n)
end

--octo_move
--8-way move
-------------------------------
octo_move=move:subclass({
	name="8-way move",
	v=nil,									--velocity
	mv=80,									--max velocity
	ac=600,								--acceleration
	dc=400,								--deceleration
	wv=nil									--wish vector
})

function octo_move:init()
	move.init(self)
	self.v = self.v or vec2:new()
	self.wv = self.wv or vec2:new()
end

function octo_move:update()
	local v = self.v
	local mv = self.mv
	local dc = self.dc
	local wv = self.wv
	local dt = time.dt

	if(wv.x==0) then
		local dv=min(
			dc*dt,
			abs(v.x)
		)*sgn(v.x)
		
		v.x-=dv
	end
	
	if(wv.y==0) then
		local dv=min(
			dc*dt,
			abs(v.y)
		)*sgn(v.y)
		
		v.y-=dv
	end
	
	v += wv * self.ac * dt

	if(v:len() > mv) then
		v = v:normalize() * mv
	end

	self.v = v
	self.dp = v * dt
	
	move.update(self)
end

function octo_move:collision(r)
	move.collision(self,r)
	local pv = r.n:dot(self.v)
	self.v -= r.n * pv
end

--trail
--line strip trail effect
-------------------------------
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
	local pos=self:t().t
	for i=1,self.ld-1 do
		add(self.ds,pos)
	end
end

function trail:update()
	local pos = self:t().t
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
	local pos = self:t().t

	for i=1,self.ld-1 do
		local p=1-(i/self.ld)
		local c=self.cs[ceil(p*#self.cs)]

		local fp=self.ds[i]
		local tp=self.ds[i+1] or self:t().t
		d_line(fp,tp,c)
	end
	
	graphic.g_draw(self)
end

--cam
--primitive to control camera
-------------------------------
camera=prim:subclass({
	name="camera",
	min=nil,
	max=nil
})

function camera:update()
	local p = self:t().t
	p -= 64
	if self.min then
		p.x = max(p.x,self.min.x)
		p.y = max(p.y,self.min.y)
	end
	if self.max then
		p.x = min(p.x,self.max.x)
		p.y = min(p.y,self.max.y)
	end
	setcam(p)
	prim.update(self)
end

--proj_move
--projectile move
-------------------------------
proj_move=obj:subclass({
	name="projectile move",
	a=0,
	s=80
})

function proj_move:update()
	local a = self.a

	self.dp = vec2:new(
		cos(a),
		sin(a)
	) * self.s * time.dt
	
	move.update(self)
end

--missile
--homing projectile
-------------------------------
missile=prim:subclass({
	name="missile",
	sa=0,					--start angle
	ss=80,				--start speed
	d=2,						--duration
	cm=7,					--collision mask
	mc=nil				--move component
})

function missile:init()
	prim.init(self)
	self.mc=proj_move:new(self,{
		a=self.sa,
		s=self.ss
	})
	self:trail()
	self:graphic()
end

function missile:update()
	--self.mc.a += 0.25 * time.dt

	self.d -= time.dt
	if(self.d <= 0) self:destroy()
	
	prim.update(self)

	local p = self:t().t
	if(map_contains(p, self.cm)) then
		self:destroy()
	end
end

function missile:graphic()
	return circle:new(self,{
		sc=6,
		fc=7
	})
end

function missile:trail()
	return trail:new(self,{
		cs={6,12,13,1}
	})
end

--laser
--reflective projectile
-------------------------------
laser=missile:subclass({
	name="laser"
})

function laser:graphic()
	return dot:new(self)
end

function laser:trail()
	return trail:new(self)
end

--pko
--player avatar
-------------------------------
pko=actor:subclass({
	name="pko",
	s=1,
	mc=nil,	--move component
	tc=nil,	--trail component
	cc=nil		--camera component
})

function pko:init()
	actor.init(self)

	self.mc=octo_move:new(self,{
		geo=self._geo
	})
	self.tc=trail:new(self)
	self.cc=camera:new(self,{
		min=vec2:new(0,0),
		max=vec2:new(386,128)
	})
end

function pko:update()
	self.mc.wv=controller.dpad

	if(controller.ap) then
		self:burst(missile,16)
	end

	if(controller.bp) then
		self:burst(laser,16)
	end
 
	prim.update(self)
end

function pko:burst(t,num)
	for i=0,num-1 do
		t:new(
			pko_game.layers.missiles,
			{
				trs=trs:new(self.trs.t),
				sa=i/num
			}
		)
	end
end

--tree
--destructible tree
-------------------------------
tut_sat=actor:subclass({
	name="tutorial satellite",
	s=2
})

--tree
--destructible tree
-------------------------------
tree=actor:subclass({
	name="tree",
	s=3
})

--circle
--circle shape
-------------------------------
circle=shape:subclass({
	name="circle",
	r=1,								   --radius
})

function circle:draw_fill()
	local t = self:t()
	f_circ(
		t.t,
		self.r * max(t.s.x,t.s.y),
 	self.fc
 )
end

function circle:draw_stroke()
	local t = self:t()
	s_circ(
		t.t,
		self.r * max(t.s.x,t.s.y),
 	self.sc
 )
end
--pko_game
--game scene

pko_game=scene:new({
	name="pko game",
	bg=nil,

	layers={
		actors=nil,
		player=nil,
		missiles=nil
	},
	
	l_pl=nil,
	l_ms=nil,
	
	pnt_g=nil,
	test=nil,
	col_vis=nil
})

--initialization
-------------------------------
function pko_game:init()
	scene.init(self)

	--initial scene clear
	clear:new(self.sg)

	--background
	self.bg=obj_map:new(self.sg,{
		name="background"
	})

	--layers
	local la=obj:new(
		self.sg,{
			name="layer: actors"
		}
	)
	
	local lp=obj:new(
		self.sg,
		{
			name="layer: player"
		}
	)
	
	local lm=obj:new(
		self.sg,
		{
			name="layer: missiles"
		}
	)

	self.layers.actors = la
	self.layers.player = lp
	self.layers.missiles = lm

	--actors
	spawner:new(
		self.sg,{
		objs={
			{
				s=1,
				o=pko,
				p=lp
			},
			{
				s=2,
				o=tut_sat,
				p=la
			},
			{
				s=3,
				o=tree,
				p=la
			}
		}
	})

	--debug ui
	if(debug != nil) then
		self.pnt_g=dot:new(engine._dev_ui.pw)

		self.test=circle:new(
			self.layers.player,{
			trs=trs:new(vec2:new(32,32)),
			r=8,
			geo=geo:new(8)
		})

		--dbg_map_col:new(self.sg)
	end
end

engine:set_active_scene("pko game")
__gfx__
0000000007800e806000000d000b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e8c79182060ee0d000bb3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070020d9450200788200033bb330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000c06d0100e87c22000b33300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000c00c10010e8c1220033bb330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000c6510000e8220000b44300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006005000d02205003094030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c100c10d000000500094000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
0077777766666666dddddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0777777766666666ddddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7777777766666666dddddddd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666dddddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666dddddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666dddddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666dddddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666dddddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666dddddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666dddddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76666666dddddddd5555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
dddddddd555555551111111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0ddddddd555555551111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddddd555555551111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000ddddd555555551111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000dddd555555551111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000ddd555555551110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000dd555555551100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000d111111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0003020400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000010001000000000000000000000000000101010000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5151616161616161616161616161515151516161616161616161616161616161616161616161616161616161616161616161616161616161616161616161515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5162000000000000000000000000605151620000000000000000000000000000000000000000000000000000000000000000000000000000000000000000605100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000006062000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000002000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000004042000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000001000000000000005052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000404141414200000000005052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000040515151515142000000005052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5203034051515151515151420303035052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5141415151515151515151514141415152000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151515151515151515151515152000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
6200000000000000000000000000006052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000040414141414141414141414200000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000050515151515151515151515200000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000050515151515151515151515200000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000050515151515151515151515200000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000050515151515151515151515200000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000052000000000000000000000000000000000050515151515151515151515200000000000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000051420000000000000000000000000000004051515151515151515151515142000000000000000000000000000000405100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000051514141414141414141414141414141415151515151515151515151515151414141414141414141414141414141515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
