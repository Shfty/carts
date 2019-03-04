--logging
--log functionality and
--wrappers for built-in
--string and print handling
-------------------------------
log_buf = {}
log_count = 1
log_limit = 1000
function log(s)
	local str = log_count..">"
	str = str..tostr(s)
	add(log_buf,str)
	if(#log_buf>log_limit) then
		del(log_buf,log_buf[1])
	end
	log_count += 1
end

function getcursor()
	cr = vec2:new()
	cr.x = peek(0x5f26)
	cr.y = peek(0x5f27)
	return cr
end
