--pointer
--mouse pointer
-------------------------------
pointer=prim:subclass({
	name="pointer",
	org=vec2:new()
})

function pointer:update()
	prim.update(self)
	self.pos = drawstate:campos() + mouse.mp
end
