require("shape")
require("vec2")

--box
--rect shape
-------------------------------
box=shape:extend({
	name="box",
	sz=nil						--size
})

function box:init()
	shape.init(self)
	self.sz = self.sz or
											vec2:new(4,4)
end

function box:g_cull(sp)
	return sp.x <= -self.sz.x or
								sp.y <= -self.sz.y or
								sp.x > 127+self.sz.x or
								sp.y > 127+self.sz.y
end

function box:draw_fill()
	local t = self:t()
	local p = t.t
	local sz = self.sz * t.s
	f_rect(
		p-sz,
		p+sz,
 	self.fc
 )
end

function box:draw_stroke()
	local t = self:t()
	local p = t.t
	local sz = self.sz * t.s
	s_rect(
		p-sz,
		p+sz,
 	self.sc
 )
end
