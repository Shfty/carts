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

function box:contains(p,m)
	m = m or 255

	if(band(self.cm,m)==0) then
		return false
	end

	local pos = self:getpos()
	local sz = self.sz

	local x = true
	x = x and p.x >= pos.x
	x = x and p.x <= pos.x+sz.x

	local y = true
	y = y and p.y >= pos.y
	y = y and p.y <= pos.y+sz.y

	return x and y
end
