function b_isect_b(at,ae,bt,be)
	local ap = at.t
	local bp = bt.t
	local sae = ae * at.s
	local sbe = be * bt.s

	local a1 = ap - sae
	local a2 = ap + sae
	local b1 = bp - sbe
	local b2 = bp + sbe

	return a1.x <= b2.x and
								a2.x >= b1.x and
								a1.y <= b2.y and
								a2.y >= b1.y
end
