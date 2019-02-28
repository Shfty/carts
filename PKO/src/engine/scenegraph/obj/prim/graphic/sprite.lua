--sprite
--sprite graphic
-------------------------------
sprite=graphic:subclass({
	name="sprite",
	org=vec2:new(-4,-4),
	sz=vec2:new(1,1),			--size
	s=0																	--sprite
})

function sprite:g_draw()
	if(not self.v) return
	
	local pos = self:getpos()
	spr(
		self.s,
		pos.x,
		pos.y,
		self.sz.x,
		self.sz.y
	)
	
	graphic.g_draw(self)
end

function sprite:contains(p,m)
	m = m or 255

	--if a sprite is present
	if(self.s>0) then
		local cm =
			self.cm or fget(self.s)
			
		if(band(m,cm)==0) then
			return false
		end
		
		return col:p_in_s(p,self)
	end

	return false
end
