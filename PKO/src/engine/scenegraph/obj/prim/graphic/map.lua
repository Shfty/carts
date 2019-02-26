--map
--map graphic
-------------------------------
obj_map=graphic:subclass({
	name="map",
	org=vec2:new(-0.5,-0.5),
	cx=0,
	cy=0
})

function obj_map:g_draw()
	if(not self.v) return
	
	local pos=self:getpos()
	
	map(
		self.cx,
		self.cy,
		pos.x,
		pos.y,
		self.w,
	 self.h
	)
	
	graphic.g_draw(self)
end
