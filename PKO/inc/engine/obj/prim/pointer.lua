require("prim")
require("ds_camera")
require("mouse")

--pointer
--mouse pointer
-------------------------------
pointer=prim:extend({
	name="pointer"
})

function pointer:init()
	prim.init(self)
	self.trs.a = true
end

function pointer:update()
	prim.update(self)
	self.trs.t = ds_camera() + mouse.mp
end
