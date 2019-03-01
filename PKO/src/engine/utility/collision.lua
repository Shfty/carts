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

	--poly > poly
	if(a:is_a(poly) and
				b:is_a(poly)) then
		return self:py_isect_py(a,b)
	end

	--try reversing arguments
	if not _r then
		local rev = self:isect(b,a,true)
		if(rev) then
			rev.n = -rev.n
			rev.pd = -rev.pd
			log(rev.n)
			rev.cp += rev.n * rev.pd
		end
		return rev
	else
		log("unsupported collision")
	end
end

--point in circle
function col:p_in_c(p,c)
	local cp = c:getpos()
	local cr = c.r

	local d = cp - p
	local dn = d:normalize()
	local dl = d:len()

	if dl <= cr then
		local pd = cr - dl
		log(pd)
		return resp:new(
			dn,
			pd,
			cp + (-dn * cr)
		)
	end
end

--point in box
function col:p_in_b(p,b)
	local bp = b:getpos()
	local bs = b.sz
	local bc = bp + (bs/2)

	local x = true
	x = x and p.x >= bp.x
	x = x and p.x <= bp.x+bs.x

	local y = true
	y = y and p.y >= bp.y
	y = y and p.y <= bp.y+bs.y

	if x and y then
		local d = p-bc

		local n = vec2:new()
		local pd = 0
		local cp = 0

		if(abs(d.x * (bs.y/bs.x)) > abs(d.y)) then
			n.x = sgn(d.x)
			pd=(bs.x*0.5) - abs(d.x)
			cp = bc + vec2:new(sgn(d.x) * bs.x * 0.5,d.y)
		else
			n.y = sgn(d.y)
			pd=(bs.y*0.5) - abs(d.y)
			cp = bc + vec2:new(d.x,sgn(d.y) * bs.y * 0.5)
		end

		return resp:new(
			n,
			pd,
			cp
		)
	end
end

function col:py_resp(p,py)
	local pp = py:getpos()
	local pc = py:center()
	local li = 0

	for i=1,#py.vs do
		local v1 = py.vs[i]
		v1 += pp

		local v2 =
			py.vs[i+1] or py.vs[1]
		v2 += pp

		local rp = p-pc
		local rv1 = v1-pc
		local rv2 = v2-pc

		local pa = atan2(rp)
		local v1a = atan2(rv1)
		local v2a = atan2(rv2)

		if v1a < v2a then
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
	
	local v1 = py.vs[li]
	v1 += pp

	local v2 =
		py.vs[li+1] or py.vs[1]
	v2 += pp

	local d = v2-v1
	local dn = d:normalize()
	local rp = p-v1
	local pp = dn:dot(rp)

	local n = dn:perp_ccw()
	local pd = n:dot(rp)

	return resp:new(
		n,
		pd,
		v1 + dn*pp
	)
end

--point in polygon
function col:p_in_py(p,py)
	local pp = py:getpos()
	local c=true

	for i=1,#py.vs do
		local v1 = py.vs[i]
		v1 += pp

		local v2 =
			py.vs[i+1] or py.vs[1]
		v2 += pp

		local d = v2-v1
		d=d:normalize()
		local n=d:perp_ccw()

		if(n:dot(p-v1)>0) then
			c=false
		end
	end

	if(c) return self:py_resp(p,py)
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
	local ap = a:getpos()
	local bp = b:getpos()
	local d = ap-bp
	local dl = d:len()
	local dn = d:normalize();
	local tr = a.r + b.r
	if dl <= tr then
		return resp:new(
			dn,
			tr-dl,
			bp + dn * b.r
		)
	end
end

--circle intersect box
function col:c_isect_b(c,b)
	local cp = c:getpos()
	local bp = b:getpos()

	local p_resp = self:p_in_b(cp,b)
	if(p_resp) return p_resp

	local bx = box:new(nil, {
		pos=bp - vec2:new(c.r,0),
		sz=b.sz + vec2:new(c.r*2,0)
	})

	local bx_resp = self:p_in_b(cp,bx)
	if(bx_resp) then
		bx_resp.cp.x += c.r * sgn((bp-cp).x)
		return bx_resp
	end

	local by = box:new(nil, {
		pos=bp - vec2:new(0,c.r),
		sz=b.sz + vec2:new(0,c.r*2)
	})

	local by_resp = self:p_in_b(cp,by)
	if(by_resp) then
		by_resp.cp.y += c.r * sgn((bp-cp).y)
		return by_resp
	end

	local sx = vec2:new(b.sz.x,0)
	local sy = vec2:new(0,b.sz.y)

	local tl_resp = self:p_in_c(bp,c)
	if(tl_resp) then
		tl_resp.cp=bp
		return tl_resp
	end

	local tr_resp = self:p_in_c(bp+sx,c)
	if(tr_resp) then
		tr_resp.cp=bp+sx
		return tr_resp
	end

	local bl_resp = self:p_in_c(bp+sy,c)
	if(bl_resp) then
		bl_resp.cp=bp+sy
		return bl_resp
	end

	local br_resp = self:p_in_c(bp+sx+sy,c)
	if(br_resp) then
		br_resp.cp=bp+sx+sy
		return br_resp
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

		local ab = ap - bp
		local ac = ap - cp
		local n = ab:perp_ccw():normalize()
		if(vec2.dot(ac,n) > c.r) return nil
	end

	local pp = py:getpos()
	local pc = py:center()
	local li = 0

	for i=1,#py.vs do
		local v1 = py.vs[i]
		v1 += pp

		local v2 =
			py.vs[i+1] or py.vs[1]
		v2 += pp

		local rp = cp-pc
		local rv1 = v1-pc
		local rv2 = v2-pc

		local pa = atan2(rp)
		local v1a = atan2(rv1)
		local v2a = atan2(rv2)

		if v1a < v2a then
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
	
	local v1 = py.vs[li]
	v1 += pp

	local v2 =
		py.vs[li+1] or py.vs[1]
	v2 += pp

	local d = v2-v1
	local dn = d:normalize()
	local rp = cp-v1
	local pp = dn:dot(rp)

	local n = dn:perp_ccw()
	local pd = -n:dot(cp-v1)

	local con = v1 +
		dn*min(max(pp,0),d:len())

		local pd = c.r-(cp-con):len()
		log(pd)

	return resp:new(
		(cp-con):normalize(),
		-pd,
		con
	)
end

--box intersect box
function col:b_isect_b(a,b)
	local a1 = a:getpos()
	local b1 = b:getpos()
	local a2 = a1 + a.sz
	local b2 = b1 + b.sz

	local isect = a1.x <= b2.x and
															a2.x >= b1.x and
															a1.y <= b2.y and
															a2.y >= b1.y

	if isect then
		local mib = vec2:new(min(a1.x,b1.x),min(a1.y,b1.y))
		local mab = vec2:new(max(a2.x,b2.x),max(a2.y,b2.y))
		local ic = (mib+mab)/2
		local bs = b.sz
		local bc = b1 + (bs/2)

		local d = ic-bc

		local n = vec2:new()
		local pd = 0
		local cp = 0

		if(abs(d.x * (bs.y/bs.x)) >= abs(d.y)) then
			n.x = bs.x*0.5*sgn(d.x)
			pd=abs(d.x) - (bs.x*0.5)
			cp = bc + vec2:new(sgn(d.x) * bs.x * 0.5,d.y)
		else
			n.y = bs.y*0.5*sgn(d.y)
			pd=abs(d.y) - (bs.y*0.5)
			cp = bc + vec2:new(d.x,sgn(d.y) * bs.y * 0.5)
		end

		return resp:new(
			n,
			pd,
			cp
		)
	end
end

--box intersect poly
function col:b_isect_py(b,py)
	local bp = b:getpos()
	local bs = b.sz
	local bc = bp + (bs/2)
	
	local pp = py:getpos()
	local pc = py:center()

	local d = pc - bc
	local dn = d:normalize()

	local bmax = nil
	local p = dn:dot(bp-bc)
	if bmax==nil or bmax < p then
		bmax=p
	end
	p = dn:dot(bp + vec2:new(bs.x,0)-bc)
	if bmax==nil or bmax < p then
		bmax=p
	end
	p = dn:dot(bp + bs-bc)
	if bmax==nil or bmax < p then
		bmax=p
	end
	p = dn:dot(bp + vec2:new(0,bs.y)-bc)
	if bmax==nil or bmax < p then
		bmax=p
	end

	pmin = nil
	for v in all(py.vs) do
		local c = dn:dot(v + pp - bc)
		if pmin==nil or pmin > c then
			pmin=c
		end
	end

	if(bmax > pmin) then
		ic = bc+(dn * ((bmax+pmin)/2))
		return self:py_resp(ic,py)
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

	local amax = nil
	for v in all(a.vs) do
		local apr = dn:dot(v+ap-ac)
		if amax==nil or amax < apr then
			amax = apr
		end
	end

	local bmin = nil
	for v in all(b.vs) do
		local bpr = dn:dot(v+bp-ac)
		if bmin==nil or bmin > bpr then
			bmin = bpr
		end
	end

	if(amax > bmin) then
		local ic = ac + (dn*amax)
		return self:py_resp(ic,b)
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
