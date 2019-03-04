require("shape")

--circle
--circle shape
-------------------------------
circle=shape:subclass({
	name="circle",
	r=1,								   --radius
})

function circle:draw_fill()
	local t = self:t()
	f_circ(
		t.t,
		self.r * t.s.x,
 	self.fc
 )
end

function circle:draw_stroke()
	local t = self:t()
	s_circ(
		t.t,
		self.r * t.s.x,
 	self.sc
 )
end
