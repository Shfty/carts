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
function mget(p)
	return _old_mget(p.x, p.y)
end

_old_mset = mset
function mset(p,c)
	return _old_mset(p.x, p.y,c)
end
