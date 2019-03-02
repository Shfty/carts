--logging
--log functionality and
--wrappers for built-in
--string and print handling
-------------------------------
function getcursor()
	cr = vec2:new()
	cr.x = peek(0x5f26)
	cr.y = peek(0x5f27)
	return cr
end

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

log_buf = {}
log_count = 1
log_limit = 16
function log(s)
	local str = log_count..">"
	str = str..tostr(s)
	add(log_buf,str)
	if(#log_buf>log_limit) then
		del(log_buf,log_buf[1])
	end
	log_count += 1
end
