require("devkit_input")
require("vec2")

--mouse
--wrapper for mouse input
-------------------------------
mouse = {
	name="mouse",
	mp=vec2:new(),
	mb=0,
	mw=0
}

function mouse:pre_update()
	self.mp=vec2:new(stat(32),stat(33))
	self.mb=stat(34)
	self.mw=stat(36)
end

engine:add_module(mouse)
