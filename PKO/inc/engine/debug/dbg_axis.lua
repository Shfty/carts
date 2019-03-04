--debug coordinate axis
-------------------------------
dbg_axis=graphic:subclass({
	name="debug axis",
	axis=nil,
	sz=5,
	a=0
})

function dbg_axis:init()
	graphic.init(self)
	self.axis = self.axis or
													vec2:new(0,1)
end

function dbg_axis:g_draw()
	local trs = self:t()
	local t = trs.t

	local o = (self.axis*self.sz):rotate(trs.r)

	d_line(
		t,
		t + o,
		12
	)

	d_line(
		t,
		t + o:perp_ccw(),
		8
	)
end
