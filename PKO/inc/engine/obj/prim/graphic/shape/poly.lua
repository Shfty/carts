require("shape")

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
	print(#col.sprite_geo)
	t = t or {}
	t.geo=col.sprite_geo[s]
	t.cm=fget(s)
	return poly:new(p,t)
end

function poly:draw_stroke()
	local p = self:t().t
	local s = self:t().s
	local vs = self.geo.vs

	for i=1,#vs do
		local v1 = p + (vs[i]*s)
		local v2 = vs[i+1] or vs[1]
		v2 *= s
		v2 += p

		d_line(v1,v2,self.sc)
	end

	for i=1,#vs do
		local v1 = p + (vs[i]*s)
		d_point(v1,8)
	end
end
