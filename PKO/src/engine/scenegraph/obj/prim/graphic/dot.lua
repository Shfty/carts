--dot
--pixel graphic
-------------------------------
dot=graphic:subclass({
	name="dot",
	org=vec2:new(-0.5,-0.5),
	c=7 							 --color
})

function dot:g_draw()
	if(not self.v) return
	
	local pos = self:getpos()
	pset(
		pos.x,
		pos.y,
 	self.c
 )
	
	graphic.g_draw(self)
end
