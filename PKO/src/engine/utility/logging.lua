--logging
--wrappers for built-in print
-------------------------------
function getcursor()
	cr = vec2:new()
	cr.x = peek(0x5f26)
	cr.y = peek(0x5f27)
	return cr
end

_old_tostr = tostr
function tostr(s)
	if(type(s) == "string") return s
	
	if(s.__tostr) then
		return s:__tostr()
	else
		return _old_tostr(s)
	end
end

_old_print = print
function print(s,x,y,c)
	s = tostr(s)
	c = c or 7

	if(x and not y) then
		local cr = getcursor()
		cursor(cr.x,cr.y+1)
		return
	end

	if(not x and not y) then
		return _old_print(s)
	end

	return _old_print(s.."\n",x,y,c)
end

log_buf = {}
log_count = 1
log_limit = 16
function log(s)
	local str = log_count..">"
	str = s..tostr(s)
	add(log_buf,str)
	if(#log_buf>log_limit) then
		del(log_buf,log_buf[1])
	end
	log_count = log_count + 1
end
