--box
--rect shape
-------------------------------
box=shape:subclass({
	name="box",
	sz=vec2:new(4,4)  --size
})

function box:draw_fill()
	local pos=self:getpos()-self.org
	f_rect(
		pos-self.sz,
		pos+self.sz,
 	self.fc
 )
end

function box:draw_stroke()
	local pos=self:getpos()-self.org
	s_rect(
		pos-self.sz,
		pos+self.sz,
 	self.sc
 )
end
