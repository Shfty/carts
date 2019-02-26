--sprite
--sprite graphic
-------------------------------
sprite=graphic:subclass({
	name="sprite",
	org=vec2:new(-0.5,-0.5),
	sz=vec2:new(1,1),			--size
	og=vec2:new(-4,-4),	--origin
	s=0																	--sprite
})

function sprite:g_draw()
	if(not self.v) return
	
	local pos = self:getpos()
	spr(
		self.s,
		pos.x+self.og.x,
		pos.y+self.og.y,
		self.sz.x,
		self.sz.y
	)
	
	graphic.g_draw(self)
end
