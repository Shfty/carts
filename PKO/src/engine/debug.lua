--debug
--collection of debugging
--functionality
-------------------------------

require("debug/dbg_ui")
require("debug/dbg_panel")
require("debug/dbg_ovr")
require("debug/dbg_log")
require("debug/dbg_sg")
require("debug/dbg_axis")

function log(o)
	local str = ""

	if(type(o) == "table") then
		str = o:tostring()
	else
		str = tostr(o)
	end

	d_ui.tabs["2"]:log(str)
end
