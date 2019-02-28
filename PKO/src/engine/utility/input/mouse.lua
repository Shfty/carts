--mouse
--wrapper for mouse input
-------------------------------
mouse = {
	mp=vec2:new(),
	mb=0
}

function mouse:update()
	self.mp.x=stat(32)
	self.mp.y=stat(33)
	self.mb=stat(34)
end
