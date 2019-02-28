--proj_move
--projectile move
-------------------------------
proj_move=obj:subclass({
	name="projectile move",
	a=0,
	s=80
})

function proj_move:update()
	self.dp = vec2:new(
		cos(self.a),
		sin(self.a)
	) * self.s * dt
	
	move.update(self)
end
