--text
--text graphic
-------------------------------
text=graphic:subclass({
	name="text",
	str=""
})

function text:g_draw()
	if(not self.v) return
	
	print(
		self.str,
		self:getpos()
	)
	
	graphic.g_draw(self)
end
