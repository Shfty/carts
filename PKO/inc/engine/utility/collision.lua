require("sprites")
require("vec2")
require("geo")

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
