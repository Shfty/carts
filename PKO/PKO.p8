pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--engine
--collection of engine
--functionality
-------------------------------
--utility
--collection of utility
--functionality
-------------------------------

--enable color literals
poke(0x5f34,1)

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

--sprites
--wrapper for pico8 sprite
--functionality
-------------------------------
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
end

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

	return vs
end

--map
--wrapper for pico8 map
--functionality
-------------------------------
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
function mget(p)
	return _old_mget(p.x, p.y)
end

_old_mset = mset
function mset(p,c)
	return _old_mset(p.x, p.y,c)
end

--logging
--log functionality and
--wrappers for built-in
--string and print handling
-------------------------------
function getcursor()
	cr = vec2:new()
	cr.x = peek(0x5f26)
	cr.y = peek(0x5f27)
	return cr
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

log_buf = {}
log_count = 1
log_limit = 16
function log(s)
	local str = log_count..">"
	str = str..tostr(s)
	add(log_buf,str)
	if(#log_buf>log_limit) then
		del(log_buf,log_buf[1])
	end
	log_count += 1
end

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


--math
--utility math functions
-------------------------------
function lerp(a,b,d)
	return a+d*(b-a)
end

_old_atan2 = atan2
function atan2(v)
	return _old_atan2(v.y,v.x)
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
			if(bmin.y > v.y) bmin.x = v.x
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
	self.cr=self.be:len()
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

function resp:__tostr()
	return "n:"..self.n:__tostr()..
		",pd:"..self.pd
end

col={
	sprite_geo={},
	debug=true
}

function col:init(numspr)
	numspr = numspr or 128

	for i=0,numspr-1 do
		if(fget(i)>0) then
		 local vs = convex_hull(i)
			self.sprite_geo[i] =
				geo:new(vs)

			if(self.debug) then
				circle:new(l_pl,{
					pos=vec2:new(
						(i%16)*10,
						flr(i/16)*10
					),
					r=self.sprite_geo[i].cr,
					sc=9,
					f=false
				})
				box:new(l_pl,{
					pos=vec2:new(
						(i%16)*10,
						flr(i/16)*10
					),
					sz=self.sprite_geo[i].be*2,
					sc=11,
					f=false
				})
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

--unified collision test
function col:isect(ap,ag,bp,bg)
	r = r or false

	--use circle-circle to early out
	local cc = self:c_isect_c(ap,ag.cr,bp,bg.cr)
	if(not cc) return nil

	--if neither geo has a box,
	--return the circle-circle result
	if(not ag.be and not bg.be) return cc

	--if both geos have a box
	--test box-box
	local bb = nil
	if(ag.be and bg.be) then
		bb = self:b_isect_b(ap,ag.be,bp,bg.be)
		if (not bb) return nil
	end

	-- one geo has a box,
	-- test circle-box
	local bc = nil
	if(not ag.be and bg.be) then
		bc = self:c_isect_b(ap,ag.cr,bp,bg.be)
	else
		bc = self:c_isect_b(bp,bg.cr,ap,ag.be)
		if (bc) bc.n = -bc.n
	end
	if (not bc) return nil

	--if neither geo has a poly,
	--return the box/circle result
	if(not ag.vs and not bg.vs) return bb or bc

	--if both geos have a poly,
	--test poly-poly
	local pp = nil
	if(ag.vs and bg.vs) then
		pp = self:py_isect_py(ap,ag.vs,bp,bg.vs)
		if (not pp) return nil
	end

	-- one geo has a poly
	local pr = nil
	if(not ag.vs and bg.vs) then
		if(ag.be) then
			pr = self:b_isect_py(ap,ag.be,bp,bg.vs)
		else
			pr = self:c_isect_py(ap,ag.cr,bp,bg.vs)
		end
	else
		if(bg.be) then
			pr = self:b_isect_py(bp,bg.be,ap,ag.vs)
		else
			assert(ag.vs != nil)
			pr = self:c_isect_py(bp,bg.cr,ap,ag.vs)
		end

		if(pr) pr.n = -pr.n
	end

	return pr
end

--point in circle
function col:p_in_c(p,cp,cr)
	return (p - cp):len() <= cr
end

--point in box
function col:p_in_b(p,bp,be)
	local bmin = bp - be
	local bmax = bp + be

	local x = p.x >= bmin.x and
											p.x <= bmax.x

	local y = p.y >= bmin.y and
											p.y <= bmax.y

	return x and y
end

--point in polygon
function col:p_in_py(p,pp,pvs)
	local c=true

	for i=1,#pvs do
		local v1 = pvs[i]
		v1 += pp

		local v2 =
		pvs[i+1] or pvs[1]
		v2 += pp

		local d = v2-v1
		d=d:normalize()
		local n=d:perp_ccw()

		if(n:dot(p-v1)>0) then
			c=false
		end
	end

	return c
end

--point in sprite
function col:p_in_s(p,s)
	local d = p-s:getpos()
	local ms = s.sz*8

	if(d.x < 0 or	d.y < 0) return nil
	if(d.x > ms.x or	d.y > ms.y) return nil

	--get spritesheet coords
	local sp = sidx2pos(s.s)

	if sget(sp+d) > 0 then
		return resp:new()
	end
end

--circle intersect circle
function col:c_isect_c(ap,ar,bp,br)
	local d = bp-ap
	local dl = d:len()
	local dn = d:normalize();
	local tr = ar + br
	if dl <= tr then
		return resp:new(
			-dn,
			tr-dl,
			bp - dn * br
		)
	end
end

--circle intersect box
function col:c_isect_b(cp,cr,bp,be)
	vs={
		bp-be,
		bp+vec2:new(be.x,-be.y),
		bp+be,
		bp+vec2:new(-be.x,be.y)
	}

	local d = bp - cp
	local dn = d:normalize()

	local md = nil
	for i=1,4 do
		local v = vs[i]
		local pv = dn:dot(v-cp)
		if md == nil or pv < md then
			md = pv
		end
	end

	if(md < cr) then
	local x = true
		x = x and cp.x >= bp.x-be.x
		x = x and cp.x <= bp.x+be.x

		local y = true
		y = y and cp.y >= bp.y-be.y
		y = y and cp.y <= bp.y+be.y

		local n = -dn
		if(x and not y) n.x = 0
		if(y and not x) n.y = 0

		return resp:new(
			n,
			cr - md,
			cp + (dn * md)
		)
	end
end

--circle intersect poly
function col:c_isect_py(cp,cr,pp,pvs)
	local d = pp - cp
	local dn = d:normalize()

	local pmin = nil
	for v in all(pvs) do
		local pv = dn:dot(pp+v-cp)
		if pmin == nil or pv < pmin then
			pmin=pv
		end
	end

	if(pmin <= cr) then
		ic = cp+dn*pmin
		return resp:new(
			-dn,
			cr-pmin,
			cp + (dn*pmin)
		)
	end
end

--box intersect box
function col:b_isect_b(ap,ae,bp,be)
	local a1 = ap - ae
	local a2 = ap + ae
	local b1 = bp - be
	local b2 = bp + be

	local isect = a1.x <= b2.x and
															a2.x >= b1.x and
															a1.y <= b2.y and
															a2.y >= b1.y

	if isect then
		local mib = vec2:new(max(a1.x,b1.x),max(a1.y,b1.y))
		local mab = vec2:new(min(a2.x,b2.x),min(a2.y,b2.y))
		local ic = (mib+mab)/2
		local ms = mab-mib

		local d = ic-bp

		local n = vec2:new()
		local pd = 0
		local cp = 0

		if(abs(d.x * (be.y/be.x)) >= abs(d.y)) then
			n.x = sgn(d.x)
			pd=ms.x
			cp = bp + vec2:new(n.x * be.x,d.y)
		else
			n.y = sgn(d.y)
			pd=ms.y
			cp = bp + vec2:new(d.x,n.y * be.y)
		end

		return resp:new(
			n,
			pd,
			cp
		)
	end
end

--box intersect poly
function col:b_isect_py(bp,be,pp,pvs)
	bvs={
		bp-be,
		bp+vec2:new(be.x,-be.y),
		bp+be,
		bp+vec2:new(-be.x,be.y)
	}

	local d = pp - bp
	local dn = d:normalize()

	local bmax = nil
	for i=1,4 do
		local v = bvs[i]
		local pv = dn:dot(v-bp)
		if bmax == nil or pv > bmax then
			bmax = pv
		end
	end

	local pmin = nil
	for v in all(pvs) do
		local pv = dn:dot(pp+v-bp)
		if pmin == nil or pv < pmin then
			pmin=pv
		end
	end

	log(dn*pmin)

	if(pmin <= bmax) then
		ic = bp+dn*bmax
		return self:py_resp(ic,pp,pvs)
	end
end

--poly intersect poly
function col:py_isect_py(ap,avs,bp,bvs)
	local d = bp - ap
	local dn = d:normalize()

	local amax = nil
	for v in all(avs) do
		local apr = dn:dot(v)
		if amax==nil or amax < apr then
			amax = apr
		end
	end

	local bmin = nil
	for v in all(bvs) do
		local bpr = dn:dot(bp+v-ap)
		if bmin==nil or bmin > bpr then
			bmin = bpr
		end
	end

	if(amax >= bmin) then
		local ic = ap + (dn*amax)
		return self:py_resp(ic,bp,bvs)
	end
end

function col:py_resp(p,pp,pvs)
	local li = 0

	for i=1,#pvs do
		local v1 = pvs[i] + pp
		local v2 =	pvs[i+1] or pvs[1]
		v2 += pp

		local rp = p-pp
		local rv1 = v1-pp
		local rv2 = v2-pp

		local pa = atan2(rp)
		local v1a = atan2(rv1)
		local v2a = atan2(rv2)

		if(v1a < v2a and pa >= v1a and pa <= v2a) then
			if pa >= v1a and pa <= v2a then
				li = i
				break
			end
		else
			if pa >= v1a or pa <= v2a then
				li = i
				break
			end
		end
	end
	
	local v1 = pvs[li] + pp
	local v2 =	pvs[li+1] or pvs[1]
	v2 += pp

	local d = v2-v1
	local dn = d:normalize()
	local rp = p-v1
	local pr = dn:dot(rp)

	local n = dn:perp_ccw()
	local pd = -n:dot(rp)

	return resp:new(
		n,
		pd,
		v1 + (dn*pr)
	)
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

--primitive
--object with transform
-------------------------------
clip=obj:subclass({
	name="clip",
	r=rect:new()
})

function clip:draw()
	local cclip=drawstate:getclip()
	setclip(self.r)
	obj.draw(self)
	setclip(cclip)
end

function clip:__tostr()
	return obj.__tostr(self).." - r:"..self.r
end

--primitive
--object with transform
-------------------------------
prim=obj:subclass({
	name="primitive",
	pos=vec2:new(),			--position
	apos=false,
	org=vec2:new(),			--origin
	a=0														--angle
})

function prim:getpos()
	local pos=vec2:new()
	local c=self
	while c!=nil do
		local cp = c.pos
		local cap = c.apos
		local co = c.org

		if(cp) pos+=cp
		if(co) pos+=co

		if(cap) then
			break
		else
			c=c.parent
		end
	end

	return pos
end

function prim:__tostr()
	return
		obj.__tostr(self).." - "..
		self.pos:__tostr()
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
	local pos = self:getpos()
	local d = pos - cp
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
		self:getpos(),
 	self.c
 )
	
	graphic.g_draw(self)
end

--map
--map graphic
-------------------------------
obj_map=graphic:subclass({
	name="map",
	mtile=vec2:new(),
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

function obj_map:find_sprites(s)
	local coords = {}

	local ss = self.mtile
	local se = ss + self.sz

	for y=ss.y,se.y-1 do
		for x=ss.x,se.x-1 do
			local pos = vec2:new(x,y)
			local ms = mget(pos)
			if(ms == s) then
				add(coords,pos)
			end
		end
	end

	return coords
end

--todo: refactor into unified collision
function obj_map:contains(p,m)
	m = m or 255

	local pos = self:getpos()
	local lpos = p-pos

	if(lpos.x < 0 or
				lpos.y < 0) then
		return false
	end

	local ts = self.sz * 8

	if(lpos.x > ts.x or
				lpos.y > ts.y) then
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
	sz=vec2:new(4,4)  --size
})

function box:draw_fill()
	local pos=self:getpos()-self.org
	f_rect(
		pos-self.sz,
		pos+self.sz,
 	self.fc
 )
end

function box:draw_stroke()
	local pos=self:getpos()-self.org
	s_rect(
		pos-self.sz,
		pos+self.sz,
 	self.sc
 )
end

--circle
--circle shape
-------------------------------
circle=shape:subclass({
	name="circle",
	r=1,								   --radius
})

function circle:draw_fill()
	local pos=self:getpos()
	f_circ(
		pos,
		self.r,
 	self.fc
 )
end

function circle:draw_stroke()
	local pos=self:getpos()
	s_circ(
		pos,
		self.r,
 	self.sc
 )
end

--poly
--n-sided shape
-------------------------------
poly=shape:subclass({
	name="poly",
	vs={}   					--vertices
})

function poly:fromsprite(p,s,t)
	t = t or {}
	t.geo=col.sprite_geo[s]
	t.cm=fget(s)
	return poly:new(p,t)
end

function poly:draw_stroke()
	local pos = self:getpos()
	local vs = self.geo.vs

	for i=1,#vs do
		local v1 = vs[i] + pos
		local v2 = vs[i+1] or vs[1]
		v2 += pos

		d_line(v1,v2,self.sc)
	end

	for i=1,#vs do
		local v1 = vs[i] + pos
		d_point(v1,8)
	end
end


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
	
	spr(
		self.s,
		self:getpos(),
		self.sz
	)
	
	graphic.g_draw(self)
end

--stripe
--line graphic
-------------------------------
line=graphic:subclass({
	name="stripe",
	tp=vec2:new(8,0),	--target pos
	at=true,										--abs target
	c=7								       --color
})

function line:g_draw()
	if(not self.v) return
	
	local pos = self:getpos()
	local t = self.tp
	if(not self.at) t += pos
	d_line(pos,t,self.c)
	
	graphic.g_draw(self)
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
		self:getpos()
	)
	
	graphic.g_draw(self)
end


--cam
--primitive to control camera
-------------------------------
camera=prim:subclass({
	name="camera",
	org=vec2:new(-64,-64)
})

function camera:update()
	local pos = self:getpos()
	setcam(pos)
	prim.update(self)
end

--pointer
--mouse pointer
-------------------------------
pointer=prim:subclass({
	name="pointer",
	org=vec2:new(),
	apos=true
})

function pointer:update()
	prim.update(self)
	self.pos = drawstate:campos() + mouse.mp
end


--move
--object for moving a parent
-------------------------------
move=obj:subclass({
	name="move",
	dp=vec2:new(),
	geo=nil
})

function move:update()
	self.parent.pos += self.dp
	self.dp=vec2:new()
	
	if(self.geo) then
		cr = col:isect(
			self.parent:getpos(),
			self.geo,
			pko_game.test:getpos(),
			pko_game.test.geo
		)

		if cr then
			self:collision(cr)
		end
	end
end

function move:collision(r)
	self.parent.pos += r.n * r.pd
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

--octo_move
--8-way move
-------------------------------
octo_move=move:subclass({
	name="8-way move",
	v=vec2:new(),		--velocity
	mv=60,									--max velocity
	ac=600,								--acceleration
	dc=600,								--deceleration
	wv=vec2:new()		--wish vector
})

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



--debug
--collection of debugging
--functionality
-------------------------------

--debug ui
dbg_ui=graphic:subclass({
	name="debug ui",
	pos=vec2:new(2,2),
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

	self.pw=pointer:new(self)
	
	local bg=box:new(wrap,{
		sz=vec2:new(123,8),
		sc=0x1107.0000,
		fc=0x1100.5a5a
	})
	
	self.tw=text:new(bg,{
		pos=vec2:new(2,2)
	})
	
	local tabs = {}
	tabs["1"]=
		dbg_ovr:new(wrap)
	tabs["2"]=
		dbg_log:new(wrap)
	tabs["3"]=
		dbg_sg:new(wrap)
	self.tabs=tabs
end

function dbg_ui:update()
	graphic.update(self)
	self.pos=drawstate:campos()+2

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

--debug panel
-------------------------------
dbg_panel=graphic:subclass({
	name="debug panel",
	pos=vec2:new(0,8),
	sz=vec2:new(123,115),
	sy=0,
	key=nil,
	v=false
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
ts_init_s = 0
ts_init_e = 0
ts_update_s = 0
ts_update_e = 0
ts_draw_s = 0
ts_draw_e = 0

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
	local icpu = ts_init_e-ts_init_s
	
	local ucpu = ts_update_e-ts_update_s
	local dcpu = ts_draw_e-ts_draw_s
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
		pos=vec2:new(2,2)
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
	tw.pos.y=2-self.sy
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
		r=rect:new(2,10,124,116)
	})
	
	self.tw=text:new(self.cw,{
		pos=vec2:new(2,2)
	})
end

function dbg_sg:update()
	dbg_panel.update(self)
	
	if(not self.v) return

	local tw = self.tw
	tw.pos.y=2-self.sy
	tw.str=engine.sg:print()
end

--debug coordinate axis
-------------------------------
dbg_axis=prim:subclass({
	name="debug axis",
	axis=vec2:new(0,1),
	sz=5,
	a=0
})

function dbg_axis:draw()
	local pos=self:getpos()

	local o = (self.axis*self.sz):rotate(self.a)

	d_line(
		pos,
		pos + o,
		12
	)

	d_line(
		pos,
		pos + o:perp_ccw(),
		8
	)
	
	prim.draw(self)
end



engine={
	game=nil,
	sg=obj:new(nil,{
		name="root"
	}),
	dev_mode=true,
	dev_ui=nil
}

--initialization
-------------------------------
function _init()
	print "ko engine"
	print "-------------------"

	print "initializing..."
	if not engine.game then
		print "error: no game module loaded"
		return
	end
	
	if(engine.dev_mode) then
		ts_init_b=time:cpu_t()
		engine.dev_ui=dbg_ui:new(nil)
	end

	--initialize engine
	col:init()

	--initialize game
	engine.game:init()

	if(engine.dev_mode) then
		engine.sg:addchild(engine.dev_ui)
		ts_init_e=time:cpu_t()
	end
end

--main loop
-------------------------------
function _update60()
	if(not engine.game) return
	
	time:update()

	local dm = engine.dev_mode
	if(dm) then
		ts_update_s=time:cpu_t()
	end

	--update input
	controller:update()
	if(dm) then
		kb:update()
		mouse:update()
	end

	--update scenegraph
	engine.sg:update()

	if(dm) then
		ts_update_e=time:cpu_t()
	end
end

--render loop
-------------------------------
function _draw()
	if(not engine.game) return

	local dm = engine.dev_mode
	if(dm) then
		ts_draw_s=time:cpu_t()
	end

	engine.sg:draw()
	
	if(dm) then
		ts_draw_e=time:cpu_t()
	end
end

--game
--collection of game
--functionality
--effects
--collection of effects
--functionality

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
		d_line(fp,tp,c)
	end
	
	graphic.g_draw(self)
end


--projectiles
--collection of projectile
--objects
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
	circle:new(self)
	self.mc=proj_move:new(self,{
		a=self.sa,
		s=self.ss
	})
	self:trail()
end

function missile:update()
	--self.mc.a += 0.25 * time.dt

	self.d -= time.dt
	if(self.d <= 0) self:destroy()
	
	prim.update(self)

	local pos = self:getpos()
	local cm = self.cm
	if(pko_game.bg:contains(pos, cm)) then
		self:destroy()
	end
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

function laser:init()
	prim.init(self)
	dot:new(self)
	self:trail()
end

function laser:trail()
	return trail:new(self)
end


--pko
--player avatar
-------------------------------
pko=prim:subclass({
	name="pko",
	pos=vec2:new(64,64),
	geo=nil,
	mc=nil,	--move component
	sc=nil,	--sprite component
	tc=nil,	--trail component
	cc=nil		--camera component
})

function pko:init()
	prim.init(self)

	self.sc=sprite:new(self,{
		s=1
	})
	self.geo = geo:new(col.sprite_geo[1].vs)
	self.geo:calculate_circle()
	self.geo.vs = nil
	self.mc=octo_move:new(self,{
		geo=self.geo
	})

	self.tc=trail:new(self)
	self.cc=camera:new(self)
end

function pko:update()
	self.mc.wv=controller.dpad

	if(controller.ap) then
		self:burst(missile,16)
	end
 
	prim.update(self)
end

function pko:burst(t,num)
	for i=0,num-1 do
		t:new(pko_game.l_ms,{
			pos=self.pos,
			sa=i/num
		})
	end
end


pko_game={
	root=nil,
	
	bg=nil,
	
	l_pl=nil,
	l_tr=nil,
	l_ms=nil,
	
	pnt_g=nil,
	test=nil,
	col_vis=nil
}

--initialization
-------------------------------
function pko_game:init()
	--initial scene clear
	clear:new(engine.sg)

	--background
	self.bg=obj_map:new(engine.sg,{
		name="background"
	})
	
	--layers
	self.l_pl=obj:new(engine.sg,{
		name="layer: player"
	})
	
	self.l_ms=obj:new(engine.sg,{
		name="layer: missiles"
	})
	
	self.l_ui=obj:new(engine.sg,{
		name="layer: ui"
	})

	--spawn player
	local ps = self.bg:find_sprites(1)
	for foo in all(ps) do
		mset(foo, 0)
		pko:new(self.l_pl,{
			pos = (foo*8)+vec2:new(4,4)
		})
	end

	--debug ui
	if(engine.dev_mode) then
		self.pnt_g=dot:new(engine.dev_ui.pw)

		self.test=circle:new(self.l_pl,{
			pos=vec2:new(32,32),
			r=8,
			geo=geo:new(8)
		})
		--[[
		self.test=box:new(self.l_pl,{
			pos=vec2:new(32,32),
			sz=vec2:new(8,8),
			geo=geo:new(vec2:new(8,8))
		})
		self.test=poly:fromsprite(self.l_pl,1,{
			pos=vec2:new(32,32)
		})
		]]
	end
end


engine.game=pko_game
__gfx__
0000000007800e8000000000000b3000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000e8c79182000ee00000bb3300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070020d9450200788200033bb330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000c06d0100e87c22000b33300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000c00c10010e8c1220033bb330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000c6510000e8220000b44300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000006005000062250003094030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000c100c100060050000094000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
15151515151515151515151515151515000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0003020400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001010100000000000000000000000000010101000000000000000000000000000101010000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000002000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000000000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000000103000000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000000404141420000000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5200000040515151514142000000005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5203034051515151515151420300035000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5141415151515151515151514141415100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5151515151515151515151515151515100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

