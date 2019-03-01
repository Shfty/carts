--poly
--n-sided shape
-------------------------------
poly=shape:subclass({
	name="poly",
	vs={}   					--vertices
})

function poly:fromsprite(p,s,t)
	t = t or {}
	t.vs=col.sprite_geo[s]
	t.cm=fget(s)
	return poly:new(p, t)
end

function poly:draw_stroke()
	local pos = self:getpos()

	for i=1,#self.vs do
		local v1 = self.vs[i]
		v1 += pos

		local v2 =
			self.vs[i+1] or self.vs[1]
		v2 += pos

		line(v1,v2,self.sc)
	end

	for i=1,#self.vs do
		local v1 = self.vs[i] + pos
		pset(v1.x,v1.y,8)
	end

end

function poly:center()
	local pc = vec2:new()
	for v in all(self.vs) do
		pc += v
	end
	pc /= #self.vs
	pc += self:getpos()
	return pc
end
