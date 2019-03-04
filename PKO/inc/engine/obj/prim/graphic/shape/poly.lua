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
		local v1 = vs[i]*s
		local vp1 = v1 + p
		local v2 = vs[i+1] or vs[1]
		v2 *= s
		local vp2 = v2 + p

		if(v1.x > 0) vp1.x -= 1
		if(v1.y > 0) vp1.y -= 1
		if(v2.x > 0) vp2.x -= 1
		if(v2.y > 0) vp2.y -= 1

		d_line(vp1,vp2,self.sc)
	end

	for i=1,#vs do
		local v1 = vs[i]*s
		local vp1 = v1 + p
		if(v1.x > 0) vp1.x -= 1
		if(v1.y > 0) vp1.y -= 1

		d_point(vp1,8)
	end
end
