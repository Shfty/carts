require("map_sprite_at")
require("sidx2pos")

function map_contains(p,m)
	m = m or 255
	
	local s = map_sprite_at(p)

	if(s>0) then
		local sp = sidx2pos(s)
		local cm = fget(s)

		if(band(m,cm) == 0) then
			return false
		end

		return sget(sp+(p%8))>0
	end

	return false
end
