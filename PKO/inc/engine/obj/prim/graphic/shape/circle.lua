require("shape")

--circle
--circle shape
-------------------------------
circle=shape:extend({
	name="circle",
	r=1,								   --radius
})

function circle:g_cull(sp)
	return sp.x <= -self.r or
								sp.y <= -self.r or
								sp.x > 127+self.r or
								sp.y > 127+self.r
end

function circle:draw_fill()
	local t = self:t()
	f_circ(
		t.t,
		self.r * max(t.s.x,t.s.y),
 	self.fc
 )
end

function circle:draw_stroke()
	local t = self:t()
	s_circ(
		t.t,
		self.r * max(t.s.x,t.s.y),
 	self.sc
 )
end
