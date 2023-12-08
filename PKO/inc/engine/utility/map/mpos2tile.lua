--map pos > map tile
--@pos vec2 map pixel coords
--@return vec2 map tile coords
function mpos2tile(pos)
	return vec2:new(
		flr(pos.x/8),
		flr(pos.y/8)
	)
end
