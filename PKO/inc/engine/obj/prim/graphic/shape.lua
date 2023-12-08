require("graphic")

--shape
--graphic with
--stroke/fill colors
-------------------------------
shape=graphic:extend({
	name="shape",
	s=true,							--stroke
	sc=6,									--stroke color
	f=true,							--fill
	fc=7,									--fill color
	cm=255								--collision mask
})

function shape:g_draw()
	if(not self.v) return
	
	if(self.f) self:draw_fill()
	if(self.s) self:draw_stroke()
	
	graphic.g_draw(self)
end

function shape:draw_stroke()
end

function shape:draw_fill()
end
