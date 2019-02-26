--move
--object for moving a parent
-------------------------------
move=obj:subclass({
	name="move",
	dp=vec2:new()
})

function move:update()
	self.parent.pos += self.dp
	self.dp=0

	local pos =
		self.parent:getpos()
	if(ccol(pos)) then
		self.parent:destroy()
	end
end

--move_p
--projectile move
-------------------------------
move_p=obj:subclass({
	name="projectile move",
	a=0,
	s=80
})

function move_p:update()
	self.dp = vec2:new(
		cos(self.a),
		sin(self.a)
	) * self.s * dt
	
	move.update(self)
end
