require("graphic")

--dot
--pixel graphic
-------------------------------
dot=graphic:extend({
	name="dot",
	c=7,								--color
	cm=255						--collision mask
})

function dot:g_cull(sp)
	return sp.x < 0 or
								sp.y < 0 or
								sp.x > 127 or
								sp.y > 127
end

function dot:g_draw()
	if(not self.v) return
	
	d_point(
		self:t().t,
 	self.c
 )
	
	graphic.g_draw(self)
end
