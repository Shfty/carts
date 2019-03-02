--enable color literals
poke(0x5f34,1)

_old_line = line
line=nil
function d_line(a,b,c)
	return _old_line(
		a.x,
		a.y,
		b.x,
		b.y,
		c)
end

_old_circ = circ
circ=nil
function s_circ(p,r,c)
	return _old_circ(
		p.x,
		p.y,
		r,
		c)
end

_old_circfill = circfill
circfill=nil
function f_circ(p,r,c)
	return _old_circfill(
		p.x,
		p.y,
		r,
		c)
end

_old_rect = rect
rect=nil
function s_rect(a,b,c)
	return _old_rect(
		a.x,
		a.y,
		b.x,
		b.y,
		c)
end

_old_rectfill = rectfill
rectfill=nil
function f_rect(a,b,c)
	return _old_rectfill(
		a.x,
		a.y,
		b.x,
		b.y,
		c)
end

_old_clip = clip
clip=nil
function setclip(r)
	return _old_clip(
		r.min.x,
		r.min.y,
		r.max.x,
		r.max.y
	)
end

_old_camera = camera
camera=nil
function setcam(p)
	return _old_camera(p.x,p.y)
end

_old_pset = pset
pset=nil
function d_point(p,c)
	return _old_pset(
		p.x,
		p.y,
		c
	)
end
