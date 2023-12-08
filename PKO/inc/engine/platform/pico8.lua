--pico8
--wrappers for pico-8 built-ins
--------------------------------

-- conversion
_old_tostr = tostr
function tostr(s)
	if(not s) return "nil"
	if(type(s) == "string") return s
	if(type(s) == "number") return _old_tostr(s)
	if(type(s) == "boolean") return _old_tostr(s)
	
	if(s.__tostr) then
		return s:__tostr()
	else
		return _old_tostr(s)
	end
end

-- drawstate
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

-- graphics
_old_pset = pset
pset=nil
function d_point(p,c)
	return _old_pset(
		p.x,
		p.y,
		c
	)
end

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

_old_spr = spr
function spr(s,p,sz)
	return _old_spr(
		s,
		p.x,
		p.y,
		sz.x,
		sz.y
	)
end

_old_print = print
function print(s,p,c)
	s = tostr(s)
	c = c or 7

	if(not p) return _old_print(s)

	return _old_print(
		s.."\n",
		p.x,
		p.y,
		c
	)
end

-- sprites
_old_sget = sget
function sget(pos)
	return _old_sget(pos.x,pos.y)
end

-- map
_old_mget = mget
function mget(p)
	return _old_mget(p.x, p.y)
end

_old_mset = mset
function mset(p,c)
	return _old_mset(p.x, p.y,c)
end

-- math
_old_atan2 = atan2
function atan2(v)
	return _old_atan2(v.y,v.x)
end
