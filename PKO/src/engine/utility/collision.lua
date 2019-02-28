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
	debug=false
}

function col:init(numspr)
	numspr = numspr or 128

	for i=0,numspr-1 do
		if(fget(i)>0) then
		 local vs = convex_hull(i)
			self.sprite_geo[i] = vs

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

--unified collision test
function col:isect(a,b,_r)
	r = r or false

	--dot and vec2 are
	--interchangeable
	if(a:is_a(dot)) then
		a=a:getpos()
	end

	--point > point
	if(a:is_a(vec2) and
				b:is_a(vec2)) then
		if (a == b) return resp:new()
		return nil
	end

	--point > circle
	if(a:is_a(vec2) and
				b:is_a(circle)) then
		return self:p_in_c(a,b)
	end

	--point > box
	if(a:is_a(vec2) and
				b:is_a(box)) then
		return self:p_in_b(a,b)
	end

	--point > polygon
	if(a:is_a(vec2) and
				b:is_a(poly)) then
		return self:p_in_py(a,b)
	end

	--point > sprite
	if(a:is_a(vec2) and
				b:is_a(sprite)) then
		return self:p_in_s(a,b)
	end

	--circle > circle
	if(a:is_a(circle) and
				b:is_a(circle)) then
		return self:c_isect_c(a,b)
	end

	--circle > box
	if(a:is_a(circle) and
				b:is_a(box)) then
		return self:c_isect_b(a,b)
	end

	--circle > poly
	if(a:is_a(circle) and
				b:is_a(poly)) then
		return self:c_isect_py(a,b)
	end

	--circle > sprite
	if(a:is_a(circle) and
				b:is_a(sprite)) then
		return self:c_isect_s(a,b)
	end

	--box > box
	if(a:is_a(box) and
				b:is_a(box)) then
		return self:b_isect_b(a,b)
	end

	--box > poly
	if(a:is_a(box) and
				b:is_a(poly)) then
		return self:b_isect_py(a,b)
	end

	--box > sprite
	if(a:is_a(box) and
				b:is_a(sprite)) then
		return self:b_isect_s(a,b)
	end

	--poly > poly
	if(a:is_a(poly) and
				b:is_a(poly)) then
		return self:py_isect_py(a,b)
	end

	--poly > sprite
	if(a:is_a(poly) and
				b:is_a(sprite)) then
		return self:py_isect_s(a,b)
	end

	--sprite > sprite
	if(a:is_a(sprite) and
				b:is_a(sprite)) then
		return self:s_isect_s(a,b)
	end

	--try reversing arguments
	if not _r then
		return self:isect(b,a,true)
	else
		log("unsupported collision")
	end
end

--point in circle
function col:p_in_c(p,c)
	local cp = c:getpos()
	local cr = c.r

	local d = p - cp
	local dn = d:normalize()
	local dl = d:len()

	if dl <= cr then
		local pd = cr - d:len()
		return resp:new(
			dn,
			pd,
			cp + (dn * cr)
		)
	end
end

--point in box
function col:p_in_b(p,b)
	local pos = b:getpos()
	local sz = b.sz

	local x = true
	x = x and p.x >= pos.x
	x = x and p.x <= pos.x+sz.x

	local y = true
	y = y and p.y >= pos.y
	y = y and p.y <= pos.y+sz.y

	if x and y then
		return resp:new()
	end
end

--point in polygon
function col:p_in_py(p,py)
	local pos = py:getpos()
	local c=true

	for i=1,#py.vs do
		local v1 = py.vs[i]
		v1 += pos

		local v2 =
			py.vs[i+1] or py.vs[1]
		v2 += pos

		local d = (v2-v1)
		d=d:normalize()
		d=d:perp_ccw()

		if(d:dot(p-v1)<0) then
			c=false
		end
	end

	if c then
		return resp:new()
	end
end

--point in sprite
function col:p_in_s(p,s)
	local pos = s:getpos()
	local lpos = p-pos

	if(lpos.x < 0 or
		lpos.y < 0) then
		return nil
	end

	if(lpos.x > s.sz.x*8 or
		lpos.y > s.sz.y*8) then
		return nil
	end

	--get spritesheet coords
	local sp = sidx2pos(s.s)

	if sget(sp+lpos) > 0 then
		return resp:new()
	end
end

--circle intersect circle
function col:c_isect_c(a,b)
	local d = b:getpos()-a:getpos()
	if d:len() <= a.r + b.r then
		return resp:new()
	end
end

--circle intersect box
function col:c_isect_b(c,b)
	local bx = box:new(nil, {
		pos=b:getpos() - vec2:new(c.r,0),
		sz=b.sz + vec2:new(c.r*2,0)
	})

	local by = box:new(nil, {
		pos=b:getpos() - vec2:new(0,c.r),
		sz=b.sz + vec2:new(0,c.r*2)
	})

	if(self:p_in_b(c:getpos(),bx)) then
		return resp:new()
	end
	if(self:p_in_b(c:getpos(),by)) then
		return resp:new()
	end

	local sx = vec2:new(b.sz.x,0)
	local sy = vec2:new(0,b.sz.y)

	if(self:p_in_c(b:getpos(),c)) then
		return resp:new()
	end
	if(self:p_in_c(b:getpos()+sx,c)) then
		return resp:new()
	end
	if(self:p_in_c(b:getpos()+sy,c)) then
		return resp:new()
	end
	if(self:p_in_c(b:getpos()+sx+sy,c)) then
		return resp:new()
	end
end

--circle intersect poly
function col:c_isect_py(c,py)
	ppy_resp = self:p_in_py(c:getpos(),py)
	if(ppy_resp) return ppy_resp

	local cp = c:getpos()
	local vs = py.vs
	for i=1,#vs do
		local ap = vs[i]
		ap += py:getpos()
		local bp = vs[i+1] or vs[1]
		bp += py:getpos()

		local ab = bp - ap
		local ac = ap - cp
		local n = ab:perp_ccw():normalize()
		if(vec2.dot(ac,n) > c.r) return nil
	end

	return resp:new()
end

--circle intersect sprite
function col:c_isect_s(c,s)
	local sz = s.sz * 8
	for x=0,sz.x do
		for y=0,sz.y do
			local pos = vec2:new(x,y)
			pos += s:getpos()
			if(self:p_in_c(pos, c)) then
				return resp:new()
			end
		end
	end
end

--box intersect box
function col:b_isect_b(a,b)
	local a1 = a:getpos()
	local b1 = b:getpos()
	local a2 = a1 + a.sz
	local b2 = b1 + b.sz

	return a1.x <= b2.x and
								a2.x >= b1.x and
								a1.y <= b2.y and
								a2.y >= b1.y
end

--box intersect poly
function col:b_isect_py(b,py)
	local bp = b:getpos()
	local bs = b.sz
	local bc = bp + (bs/2)
	
	local pp = py:getpos()
	local pc = vec2:new()
	for v in all(py.vs) do
		pc += v
	end
	pc /= #py.vs
	pc += pp

	local d = pc - bc
	local dn = d:normalize()

	local bpr = {}
	local p = vec2.dot(bp, dn)
	add(bpr,p)
	p = vec2.dot(bp + vec2:new(bs.x,0),dn)
	add(bpr,p)
	p = vec2.dot(bp + bs,dn)
	add(bpr,p)
	p = vec2.dot(bp + vec2:new(0,bs.y),dn)
	add(bpr,p)

	local ppr = {}
	for v in all(py.vs) do
		local os = pp-pc
		add(ppr,vec2.dot(v + os + pc,dn))
	end

	for bp in all(bpr) do
		for pp in all(ppr) do
			if(bp > pp) return resp:new()
		end
	end
end

--box intersect sprite
function col:b_isect_s(b,s)
	local sz = s.sz * 8
	for x=0,sz.x do
		for y=0,sz.y do
			local pos = vec2:new(x,y)
			pos += s:getpos()
			if(self:p_in_b(pos, b)) then
				return resp:new()
			end
		end
	end
end

--poly intersect poly
function col:py_isect_py(a,b)
	local ap = a:getpos()
	local ac = vec2:new()
	for v in all(a.vs) do
		ac += v
	end
	ac /= #a.vs
	ac += ap

	local bp = b:getpos()
	local bc = vec2:new()
	for v in all(b.vs) do
		bc += v
	end
	bc /= #b.vs
	bc += bp

	local d = bc - ac
	local dn = d:normalize()

	local apr = {}
	for v in all(a.vs) do
		local os = ap-ac
		add(apr,vec2.dot(v + os + ac,dn))
	end

	local bpr = {}
	for v in all(b.vs) do
		local os = bp-bc
		add(bpr,vec2.dot(v + os + bc,dn))
	end

	for ap in all(apr) do
		for bp in all(bpr) do
			if(ap > bp) return resp:new()
		end
	end
end

--poly intersect sprite
function col:py_isect_s(py,s)
	local sz = s.sz * 8
	for x=0,sz.x do
		for y=0,sz.y do
			local pos = vec2:new(x,y)
			pos += s:getpos()
			if(self:p_in_py(pos, py)) then
				return resp:new()
			end
		end
	end
end

--sprite intersect sprite
function col:s_isect_s(a,b)
	local sz = a.sz * 8
	
	for x=0,sz.x do
		for y=0,sz.y do
			local pos = vec2:new(x,y)
			pos += a:getpos()

			if(self:p_in_s(pos, b)) return resp:new()
		end
	end
end
