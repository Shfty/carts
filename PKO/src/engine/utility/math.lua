--math
--utility math functions
-------------------------------
pi=3.14159
tau=2*pi

function lerp(a,b,d)
	return a+d*(b-a)
end

_old_atan2 = atan2
function atan2(v)
	return _old_atan2(v.y,v.x)
end