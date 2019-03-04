require("graphic")
require("drawstate")

--map
--map graphic
-------------------------------
obj_map=graphic:subclass({
	name="map",
	mtile=nil,
	sz=nil
})

function obj_map:init()
	graphic.init(self)
	self.mtile = self.mtile or
														vec2:new()
	self.sz = self.sz or
											vec2:new(16,16)
end

function obj_map:update()
	local cp = drawstate:campos()
	local ts = cp % 8
	self.trs.t = cp - ts
	local mt = self.trs.t/8
	self.mtile.x = flr(mt.x)
	self.mtile.y = flr(mt.y)
	graphic.update(self)
end

function obj_map:g_draw()
	if(not self.v) return
	
	local pos=self:t().t
	
	map(
		self.mtile.x-1,
		self.mtile.y-1,
		pos.x-8,
		pos.y-8,
		self.sz.x+2,
		self.sz.y+2
	)
	
	graphic.g_draw(self)
end
