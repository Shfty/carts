--box
--rect shape
-------------------------------
box=shape:subclass({
	name="box",
	sz=vec2:new(8,8)  --size
})

function box:draw_fill()
	local pos=self:getpos()
	pos -= self.org
	rectfill(
		pos.x,
		pos.y,
		pos.x+self.sz.x,
		pos.y+self.sz.y,
 	self.fc
 )
end

function box:draw_stroke()
	local pos=self:getpos()
	pos -= self.org
	rect(
		pos.x,
		pos.y,
		pos.x+self.sz.x,
		pos.y+self.sz.y,
 	self.sc
 )
end

function box:contains(point)
	local pos = self:getpos()
	local sz = self.sz

	local x = false
	x = x and point.x >= pos.x
	x = x and point.x <= pos.x+sz.x

	local y = false
	y = y and point.y >= pos.y
	y = y and point.y <= pos.y+sz.y

	return x and y
end
