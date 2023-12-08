function map_find_sprites(s,tm)
	tm = tm or vec2:new(255,127)

	local coords = {}
	for y=0,tm.y-1 do
		for x=0,tm.x-1 do
			local p = vec2:new(x,y)
			local ms = mget(p)
			if(ms == s) then
				add(coords,p)
			end
		end
	end

	return coords
end
