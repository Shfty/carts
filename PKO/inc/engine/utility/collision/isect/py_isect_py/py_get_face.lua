require("resp")

function py_get_face(p,pt,pvs)
	local pp = pt.t
	local ps = pt.s

	local d = p - pp
	local dn = d:normalize()
	local da = atan2(dn)

	for i=1,#pvs do
		local v1 = pvs[i]*ps
		local v2 = pvs[i+1] or pvs[1]
		v2 *= ps

		local a1 = atan2(v1)
		local a2 = atan2(v2)

		local fi = false
		if a1 < a2 then
			if da >= a1 and da <= a2 then
				fi = true
			end
		else
			if da >= a1 or da <= a2 then
				fi = true
			end
		end

		if fi then
			return { v1=v1, v2=v2 }
		end
	end
end
