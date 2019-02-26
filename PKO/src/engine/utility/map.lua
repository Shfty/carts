--map pos > map tile
--@pos vec2 map pixel coords
--@return vec2 map tile coords
function mpos2tile(pos)
	return pos/8
end

--map tile > map pos
--@mtile vec2 map tile coords
--@return vec2 map pixel coords
function mtile2pos(mtile)
	return mtile*8
end

_old_mget = mget
function mget(pos)
	return _old_mget(pos.x, pos.y)
end
