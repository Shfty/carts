--circle intersect circle
function c_isect_c(at,ar,bt,br)
	return (bt.t-at.t):len() <=
								(max(at.s.x,at.s.y) * ar) +
								(max(bt.s.x,bt.s.y) * br)
end
