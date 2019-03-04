require("graphic")

--stripe
--line graphic
-------------------------------
line=graphic:subclass({
	name="stripe",
	tp=nil,								--target pos
	at=true,							--abs target
	c=7												--color
})

function line:init()
	graphic.init(self)
	self.tp = self.tp or
											vec2:new(8,0)
end

function line:g_draw()
	if(not self.v) return
	
	local pos = self:t().t
	local t = self.tp
	if(not self.at) t += pos
	d_line(pos,t,self.c)
	
	graphic.g_draw(self)
end
