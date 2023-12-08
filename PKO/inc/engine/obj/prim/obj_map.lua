require("graphic")
require("ds_camera")

--map
--map graphic
-------------------------------
obj_map=prim:extend({
	name="map",
	mtile=nil,
	sz=nil
})

function obj_map:init()
	prim.init(self)
	self.mtile = self.mtile or
														vec2:new()
	self.sz = self.sz or
											vec2:new(16,16)
end

function obj_map:update()
	local cp = ds_camera()
	local ts = cp % 8
	self.trs.t = cp - ts
	local mt = self.trs.t/8
	self.mtile.x = flr(mt.x)
	self.mtile.y = flr(mt.y)
	prim.update(self)
end

function obj_map:draw()
	local mt = self.mtile
	local pos = self:t().t
	local sz = self.sz
	
	map(
		mt.x-1,
		mt.y-1,
		pos.x-8,
		pos.y-8,
		sz.x+2,
		sz.y+2
	)
	
	prim.draw(self)
end
