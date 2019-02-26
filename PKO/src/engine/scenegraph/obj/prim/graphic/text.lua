--text
--text graphic
-------------------------------
text=graphic:subclass({
	name="text",
	str=""
})

function text:g_draw()
	if(not self.v) return
	
	local pos=self:getpos()
	
	print(
		self.str,
		pos.x,
		pos.y
	)
	
	graphic.g_draw(self)
end
