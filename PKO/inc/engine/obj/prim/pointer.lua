require("prim")
require("drawstate")

--pointer
--mouse pointer
-------------------------------
pointer=prim:subclass({
	name="pointer"
})

function pointer:init()
	prim.init(self)
	self.trs.a = true
end

function pointer:update()
	prim.update(self)
	self.trs.t = drawstate:campos() + mouse.mp
end
