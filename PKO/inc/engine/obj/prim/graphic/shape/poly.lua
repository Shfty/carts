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
