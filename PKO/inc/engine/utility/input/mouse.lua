require("input")
require("vec2")

--mouse
--wrapper for mouse input
-------------------------------
mouse = {
	mp=vec2:new(),
	mb=0
}

function mouse:update()
	self.mp=vec2:new(stat(32),stat(33))
	self.mb=stat(34)
end
