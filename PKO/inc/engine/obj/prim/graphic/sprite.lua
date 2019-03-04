require("graphic")
require("vec2")

--sprite
--sprite graphic
-------------------------------
sprite=graphic:subclass({
	name="sprite",
	sz=nil,			--size
	s=0																	--sprite
})

function sprite:init()
	self.sz = self.sz or
											vec2:new(1,1)
end

function sprite:g_draw()
	if(not self.v) return
	
	spr(
		self.s,
		self:t().t,
		self.sz
	)
	
	graphic.g_draw(self)
end
