--missile
--homing projectile
-------------------------------
missile=prim:subclass({
	name="missile",
	move=nil,
	sa=0,					--start angle
	ss=80,				--start speed
	d=2,						--duration
	cm=7						--collision mask
})

function missile:init()
	prim.init(self)
	circle:new(self)
	self.move=proj_move:new(self,{
		a=self.sa,
		s=self.ss
	})
	self:trail()
end

function missile:update()
	--self.move.a += 0.25 * dt

	self.d -= dt
	if(self.d <= 0) self:destroy()
	
	prim.update(self)

	local pos =
		self:getpos()
	if(bg:contains(pos, self.cm)) then
		self:destroy()
	end
end

function missile:trail()
	return trail:new(self,{
		cs={6,12,13,1}
	})
end
