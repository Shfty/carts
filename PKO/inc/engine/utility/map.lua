--map
--wrapper for pico8 map
--functionality
-------------------------------
--map pos > map tile
--@pos vec2 map pixel coords
--@return vec2 map tile coords
function mpos2tile(pos)
	return vec2:new(
		flr(pos.x/8),
		flr(pos.y/8)
	)
end

--map tile > map pos
--@mtile vec2 map tile coords
--@return vec2 map pixel coords
function mtile2pos(mtile)
	return mtile*8
end

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

function map_sprites_in(p1,p2,max)
	max=max or vec2:new(255,127)

	local mp1 = mpos2tile(p1)
	local mp2 = mpos2tile(p2)

	ss={}

	for x=mp1.x,mp2.x do
		for y=mp1.y,mp2.y do
			local s = mget(vec2:new(x,y))
			if(s>0) then
				local st = {
					trs=trs:new(
						vec2:new(
							(x*8)+4,
							(y*8)+4
						)
					),
					s=s
				}
				add(ss,st)
			end
		end
	end

	return ss
end

function map_isect(ot,og)
	local op = ot.t
	local ocr = og.cr
	local o1 = mpos2tile(op - ocr)
	local o2 = mpos2tile(op + ocr)

	local crs = {}
	for y = max(o1.y+1,1),o2.y+1 do
		for x = max(o1.x+1,1),o2.x+1 do
			local mg = col.map_geo[y][x]
			if(mg.ptr) mg = col.map_geo[mg.ptr.y][mg.ptr.x]
			if(mg.geo != nil) then
				local r = col:isect(
					ot,
					og,
					mg.t,
					mg.geo
				)
				if(r) add(crs,r)
			end
		end
	end

	return crs
end

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
