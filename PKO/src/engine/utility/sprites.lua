_old_sget = sget
function sget(pos)
	return _old_sget(pos.x,pos.y)
end

--sprite pos > sprite index
--@spos vec2 sprite pixel coords
--@return number sprite index
function spos2idx(spos)
	local x=flr(spos.x/8)
	local y=flr(spos.y/8)
	return stile2idx(vec2:new(x,y))
end

--sprite tile > sprite index
--@spos vec2 sprite tile coords
--@return number sprite index
function stile2idx(stile)
	return (stile.y*16)+stile.x
end

--sprite index > sprite tile
--@sidx vec2 map tile coords
--@return number sprite tile coords
function sidx2tile(sidx)
	return vec2:new(
		sidx%16, 
		flr(sidx/16)
	)
end

--sprite index > sprite pos
--@sidx number sprite index
--@return number sprite pixel coords
function sidx2pos(sidx)
	return sidx2tile(sidx)*8
end
