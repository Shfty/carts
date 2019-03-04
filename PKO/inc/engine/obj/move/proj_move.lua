require("move")

--proj_move
--projectile move
-------------------------------
proj_move=obj:subclass({
	name="projectile move",
	a=0,
	s=80
})

function proj_move:update()
	local a = self.a

	self.dp = vec2:new(
		cos(a),
		sin(a)
	) * self.s * time.dt
	
	move.update(self)
end
