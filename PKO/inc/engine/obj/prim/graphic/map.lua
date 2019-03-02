--map
--map graphic
-------------------------------
obj_map=graphic:subclass({
	name="map",
	mtile=vec2:new(),
	sz=vec2:new(16,16)
})

function obj_map:g_draw()
	if(not self.v) return
	
	local pos=self:getpos()
	
	map(
		self.mtile.x,
		self.mtile.y,
		pos.x,
		pos.y,
		self.sz.x,
		self.sz.y
	)
	
	graphic.g_draw(self)
end

function obj_map:find_sprites(s)
	local coords = {}

	local ss = self.mtile
	local se = ss + self.sz

	for y=ss.y,se.y-1 do
		for x=ss.x,se.x-1 do
			local pos = vec2:new(x,y)
			local ms = mget(pos)
			if(ms == s) then
				add(coords,pos)
			end
		end
	end

	return coords
end

--todo: refactor into unified collision
function obj_map:contains(p,m)
	m = m or 255

	local pos = self:getpos()
	local lpos = p-pos

	if(lpos.x < 0 or
				lpos.y < 0) then
		return false
	end

	local ts = self.sz * 8

	if(lpos.x > ts.x or
				lpos.y > ts.y) then
		return false
	end

	--fetch sprite from map
	local mp = mpos2tile(lpos)
	local s = mget(mp)

	--if a sprite is present
	if(s>0) then
		--get spritesheet coords
		local sp = sidx2pos(s)
		local cm = self.cm or fget(s)

		if(band(m,cm) == 0) then
			return false
		end

		return sget(sp+(lpos%8))>0
	end

	return false
end
