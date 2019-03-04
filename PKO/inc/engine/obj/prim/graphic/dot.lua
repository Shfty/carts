require("graphic")

--dot
--pixel graphic
-------------------------------
dot=graphic:subclass({
	name="dot",
	c=7,								--color
	cm=255						--collision mask
})

function dot:g_draw()
	if(not self.v) return
	
	d_point(
		self:t().t,
 	self.c
 )
	
	graphic.g_draw(self)
end
