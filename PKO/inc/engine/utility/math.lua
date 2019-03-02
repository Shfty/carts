--math
--utility math functions
-------------------------------
function lerp(a,b,d)
	return a+d*(b-a)
end

_old_atan2 = atan2
function atan2(v)
	return _old_atan2(v.y,v.x)
end

require("math/vec2")
require("math/rect")
require("math/geo")