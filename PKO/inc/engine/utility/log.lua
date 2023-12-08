--log
--log functionality and
--wrappers for built-in
--string and print handling
-------------------------------
_log_buf = {}
_log_count = 1
_log_limit = 1000

function log(s)
	local str = _log_count..">"
	str = str..tostr(s)
	add(_log_buf,str)
	if(#_log_buf>_log_limit) then
		del(_log_buf,_log_buf[1])
	end
	_log_count += 1
end
