--sprite
--sprite graphic
-------------------------------
sprite=graphic:subclass({
	name="sprite",
	org=vec2:new(-4,-4),
	sz=vec2:new(1,1),			--size
	s=0																	--sprite
})

function sprite:g_draw()
	if(not self.v) return
	
	local pos = self:getpos()
	spr(
		self.s,
		pos.x,
		pos.y,
		self.sz.x,
		self.sz.y
	)
	
	graphic.g_draw(self)
end
