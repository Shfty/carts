--stripe
--line graphic
-------------------------------
line=graphic:subclass({
	name="stripe",
	tp=vec2:new(8,0),	--target pos
	at=true,										--abs target
	c=7								       --color
})

function line:g_draw()
	if(not self.v) return
	
	local pos = self:getpos()
	local t = self.tp
	if(not self.at) t += pos
	d_line(pos,t,self.c)
	
	graphic.g_draw(self)
end
