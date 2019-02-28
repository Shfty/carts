--collision
--wrapper for collision
--functionality
-------------------------------
collision={
	sprite_geo={},
	debug=false
}

function collision:init(numspr)
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
function collision:isect(a,b,_r)
	r = r or false

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
	end

	--box > box
	if(a:is_a(box) and
				b:is_a(box)) then
	end

	--box > poly
	if(a:is_a(box) and
				b:is_a(poly)) then
	end

	--box > sprite
	if(a:is_a(box) and
				b:is_a(sprite)) then
	end

	--poly > poly
	if(a:is_a(poly) and
				b:is_a(poly)) then
	end

	--poly > sprite
	if(a:is_a(box) and
				b:is_a(sprite)) then
	end

	--sprite > sprite
	if(a:is_a(sprite) and
				b:is_a(sprite)) then
	end

	--try reversing arguments
	if not _r then
		return self:isect(b,a,true)
	else
		log("unsupported collision")
		return false
	end
end

--point in circle
function collision:p_in_c(p,c)
	local d = p-c:getpos()
	return d:len() <= c.r
end

--point in box
function collision:p_in_b(p,b)
	local pos = b:getpos()
	local sz = b.sz

	local x = true
	x = x and p.x >= pos.x
	x = x and p.x <= pos.x+sz.x

	local y = true
	y = y and p.y >= pos.y
	y = y and p.y <= pos.y+sz.y

	return x and y
end

--point in polygon
function collision:p_in_py(p,py)
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

	return c
end

--point in sprite
function collision:p_in_s(p,s)
	local pos = s:getpos()
	local lpos = p-pos

	if(lpos.x < 0 or
		lpos.y < 0) then
		return false
	end

	if(lpos.x > s.sz.x*8 or
		lpos.y > s.sz.y*8) then
		return false
	end

	--get spritesheet coords
	local sp = sidx2pos(s.s)

	return sget(sp+lpos)>0
end

--circle intersect circle
function collision:c_isect_c(a,b)
	local d = b:getpos()-a:getpos()
	return d:len() <= a.r + b.r
end

--circle intersect box
function collision:c_isect_b(c,b)
	local bx = box:new(nil, {
		pos=b:getpos() - vec2:new(c.r,0),
		sz=b.sz + vec2:new(c.r*2,0)
	})

	local by = box:new(nil, {
		pos=b:getpos() - vec2:new(0,c.r),
		sz=b.sz + vec2:new(0,c.r*2)
	})

	if(self:p_in_b(c:getpos(),bx)) return true
	if(self:p_in_b(c:getpos(),by)) return true

	local sx = vec2:new(b.sz.x,0)
	local sy = vec2:new(0,b.sz.y)

	if(self:p_in_c(b:getpos(),c)) return true
	if(self:p_in_c(b:getpos()+sx,c)) return true
	if(self:p_in_c(b:getpos()+sy,c)) return true
	if(self:p_in_c(b:getpos()+sx+sy,c)) return true

	return false
end

--circle intersect poly
function collision:c_isect_py(c,py)
	if(self:p_in_py(c:getpos(),py)) return true

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
		if(vec2.dot(ac,n) > c.r) return false
	end

	return true
end
