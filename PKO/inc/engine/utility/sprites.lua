--sprites
--wrapper for pico8 sprite
--functionality
-------------------------------
--sprite pos > sprite index
--@spos vec2 sprite pixel coords
--@return number sprite index
function spos2idx(spos)
	local dp = spos/8
	return stile2idx(
		vec2:new(
			flr(dp.x),
			flr(dp.y)
		)
	)
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

--walks along a sprite
--line by line in the specified
--direction and returns the
--first non-0 pixel's coords
function trace_edge(s,xs,ys,f)
	f = f or false

	local xb,xe,yb,ye=0,7,0,7

	if(xs<0) xb,xe=7,0
	if(ys<0) yb,ye=7,0
	
	local sp = sidx2pos(s)

	if(not f) then
		for x=xb,xe,xs do
			for y=yb,ye,ys do
				if(sget(vec2:new(sp.x+x,sp.y+y)) > 0) then
					return vec2:new(x,y)
				end
			end
		end
	else
		for y=yb,ye,ys do
			for x=xb,xe,xs do
				if(sget(vec2:new(sp.x+x,sp.y+y)) > 0) then
					return vec2:new(x,y)
				end
			end
		end
	end
end

--traces the edges of the
--given sprite in clockwise
--order to generate a
--simplified collision mesh
function convex_hull(s)
	local vs = {}

	local sp = sidx2pos(s)

	add(vs,trace_edge(s,1,1,true)-4)
	add(vs,trace_edge(s,-1,1,true)-4)

	add(vs,trace_edge(s,-1,1)-4)
	add(vs,trace_edge(s,-1,-1)-4)

	add(vs,trace_edge(s,-1,-1,true)-4)
	add(vs,trace_edge(s,1,-1,true)-4)

	add(vs,trace_edge(s,1,-1)-4)
	add(vs,trace_edge(s,1,1)-4)

	for i=#vs,1,-1 do
		if(not vs[i]) del(vs,vs[i])
	end

	for i=#vs,1,-1 do
		local v1 = vs[i]
		local v2 = vs[i-1] or vs[#vs]
		if(v1 == v2) then
			del(vs,v1)
		end
	end

	for v in all(vs) do
		if(v.x > 0) v.x += 1
		if(v.y > 0) v.y += 1
	end

	return vs
end
