require("sidx2pos")
require("trace_edge")

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

	for i=#vs,1,-1 do
	if(vs[i].x > 0) vs[i].x += 1
	if(vs[i].y > 0) vs[i].y += 1
	end

	return vs
end
