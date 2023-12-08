require("mpos2tile")

function map_sprite_at(p,max)
	max=max or vec2:new(255,127)

	if(p.x < 0 or
				p.y < 0) then
		return -1
	end

	local mp = mpos2tile(p)

	if(mp.x > max.x or
				mp.y > max.y) then
		return -1
	end

	--fetch sprite from map
	return mget(mp)
end
