--debug coordinate axis
-------------------------------
dbg_axis=prim:subclass({
	name="debug axis",
	axis=vec2:new(0,1),
	sz=5,
	a=0
})

function dbg_axis:draw()
	local pos=self:getpos()

	local o = (self.axis*self.sz):rotate(self.a)

	d_line(
		pos,
		pos + o,
		12
	)

	d_line(
		pos,
		pos + o:perp_ccw(),
		8
	)
	
	prim.draw(self)
end
