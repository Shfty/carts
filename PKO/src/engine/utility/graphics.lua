--enable color literals
poke(0x5f34,1)

_old_line = line
function line(a,b,c)
	return _old_line(
		a.x,
		a.y,
		b.x,
		b.y,
		c)
end