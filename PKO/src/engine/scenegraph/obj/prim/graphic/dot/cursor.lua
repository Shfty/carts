--cursor
--mouse cursor
-------------------------------
cursor=dot:subclass({
	name="cursor",
	org=vec2:new()
})

function cursor:update()
	dot.update(self)

	self.pos = drawstate:campos() + mouse.mp
end
