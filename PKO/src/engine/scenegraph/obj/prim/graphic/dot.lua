--dot
--pixel graphic
-------------------------------
dot=graphic:subclass({
	name="dot",
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

function dot:contains(point)
	local pos = self:getpos()
	return point == pos
end

require("dot/cursor.lua")
