--shape
--graphic with
--stroke/fill colors
-------------------------------
shape=graphic:subclass({
	name="shape",
	s=true,
	sc=6,
	f=true,
	fc=7,
	cm=255
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

require("shape/box")
require("shape/circle")
require("shape/poly")
