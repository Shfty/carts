missile=prim:subclass({
	name="missile",
	a=0,
	s=80,
	c=7,
	d=2
})

function missile:init()
	prim.init(self)
	circle:new(self)
	self:trail()
end

function missile:update()
	local dp = vec2:new(
		cos(self.a),
		sin(self.a)
	)
	
	self.d -= dt
	if(self.d <= 0) self:destroy()

	self.a += 0.25 * dt

	local x = dp.x * self.s * dt
	local y = dp.y * self.s * dt
	self.pos += vec2:new(x,y)
	
	prim.update(self)
end

function missile:trail()
	return trail:new(self,{
		cs={6,12,13,1}
	})
end
