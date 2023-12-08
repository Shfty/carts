require("graphic")

--text
--text graphic
-------------------------------
text=graphic:extend({
	name="text",
	str=""
})

function text:g_cull(sp)
	return false
end

function text:g_draw()
	if(not self.v) return
	
	print(
		self.str,
		self:t().t
	)
	
	graphic.g_draw(self)
end
