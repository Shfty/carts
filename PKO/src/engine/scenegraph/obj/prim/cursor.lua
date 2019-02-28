--cursor
--mouse cursor
-------------------------------
cursor=prim:subclass({
	name="cursor",
	org=vec2:new()
})

function cursor:update()
	prim.update(self)
	self.pos = drawstate:campos() + mouse.mp
end
