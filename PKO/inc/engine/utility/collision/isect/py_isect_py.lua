require("py_get_face")

--poly intersect poly
function py_isect_py(at,avs,bt,bvs)
	local ap = at.t
	local as = at.s
	local bp = bt.t
	local bs = bt.s
	local d = ap - bp
	local dn = d:normalize()

	local f = py_get_face(ap,bt,bvs)
	local fv1 = f.v1
	local fv2 = f.v2
	local fd = fv2 - fv1
	local fdn = fd:normalize()
	local fn = fdn:perp_ccw()

	local lscd = d - fv1
	local lecd = d - fv2
	
	local clp = fdn:dot(lscd)
	local rn = fn
	
	if(clp < 0) then
		rn = (d-fv1):normalize()
	end

	if(clp > fd:len()) then
		rn = (d-fv2):normalize()
	end

	local amin = nil
	for v in all(avs) do
		local apr = rn:dot(v*as)
		if amin==nil or amin > apr then
			amin = apr
		end
	end

	local bmax = nil
	for v in all(bvs) do
		local bpr = rn:dot(bp+(v*bs)-ap)
		if bmax==nil or bmax < bpr then
			bmax = bpr
		end
	end

	if(amin <= bmax) then
		local fp = fdn:dot(d-fv1)

		local rcp = bp + fv1 + (fdn * fp)
		
		if(clp < 0) then
			rn = (d-fv1):normalize()
			rcp = bp + fv1
		end

		if(clp > fd:len()) then
			rn = (d-fv2):normalize()
			rcp = bp + fv2
		end

		return resp:new(
			rn,
			bmax - amin,
			rcp
		)
	end
end
