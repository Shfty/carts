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
