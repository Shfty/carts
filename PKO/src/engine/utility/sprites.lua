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

--walks along a sprite
--line by line in the specified
--direction and returns the
--first non-0 pixel's coords
function trace_edge(s,xs,ys,f)
	f = f or false

	local xb=0
	local xe=7
	local yb=0
	local ye=7

	if(xs<0) then
		xb=7
		xe=0
	end

	if(ys<0) then
		yb=7
		ye=0
	end
	
	if(not f) then
		local sp = sidx2pos(s)
		for x=xb,xe,xs do
			for y=yb,ye,ys do
				if(sget(vec2:new(sp.x+x,sp.y+y)) > 0) then
					return vec2:new(x,y)
				end
			end
		end
	else
		local sp = sidx2pos(s)
		for y=yb,ye,ys do
			for x=xb,xe,xs do
				if(sget(vec2:new(sp.x+x,sp.y+y)) > 0) then
					return vec2:new(x,y)
				end
			end
		end
	end

	return nil
end

--traces the edges of the
--given sprite in clockwise
--order to generate a
--simplified collision mesh
function convex_hull(s)
	local vs = {}

	local sp = sidx2pos(s)

	add(vs,trace_edge(s,1,1,true))
	add(vs,trace_edge(s,-1,1,true))
	add(vs,trace_edge(s,-1,1))
	add(vs,trace_edge(s,-1,-1))
	add(vs,trace_edge(s,-1,-1,true))
	add(vs,trace_edge(s,1,-1,true))
	add(vs,trace_edge(s,1,-1))
	add(vs,trace_edge(s,1,1))

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

	return vs
end
