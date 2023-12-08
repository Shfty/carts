require("shape")
require("sprite_geo")

--poly
--n-sided shape
-------------------------------
poly=shape:extend({
	name="poly",
	vs=nil							--vertices
})

function poly:init()
	shape.init(self)
	self.vs = self.vs or {}
end

function poly:fromsprite(p,s,t)
	t = t or {}
	t.geo=sprite_geo.geo[s]
	t.cm=fget(s)
	return poly:new(p,t)
end

function poly:g_cull(sp)
	return false
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
