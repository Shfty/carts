--debug coordinate axis
-------------------------------
dbg_axis=prim:subclass({
	name="debug axis"
})

function dbg_axis:draw()
	local pos=self:getpos()

	line(
		pos.x,
		pos.y,
		pos.x+5,
		pos.y,
		12
	)
	
	line(
		pos.x,
		pos.y,
		pos.x,
		pos.y+5,
		11
	)
	
	prim.draw(self)
end
