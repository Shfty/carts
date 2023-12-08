require("prim")
require("ds_camera")

--graphic
--primitive with visual element
-------------------------------
graphic=prim:extend({
	name="graphic",
	v=true,						--visible
	cm=nil							--collision mask
})

function graphic:draw()
	if(not self.v) return

	local cp = ds_camera()
	local sp = self:t().t - cp
	if(self:g_cull(sp)) return

	self:g_draw()
 prim.draw(self)
end

function graphic:g_cull(sp)
	return false
end

function graphic:g_draw()
end

function graphic:col_mask(m)
	m = m or 255
	return band(self.cm,m) > 0
end
