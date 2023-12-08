require("dbg_panel")
require("t_fps")
require("t_fpstarget")

--debug overlay
-------------------------------
dbg_ovr=dbg_panel:extend({
	name="system info",
	key="1",
	mw=nil,		--memory widget
	cw=nil,		--cpu widget
	ow=nil			--object widget
})

function dbg_ovr:init()
	dbg_panel.init(self)
	
	self.tw=text:new(self,{
		trs=trs:new(vec2:new(-58,-54))
	})
end

function dbg_ovr:update()
	dbg_panel.update(self)
	
	if(not self.v) return
	
	local str = ""
	
	--memory
	local mem=stat(0)
	
	--cpu
	local icpu = debug.ts_init_e-debug.ts_init_s
	
	local ucpu = debug.ts_update_e-debug.ts_update_s
	local dcpu = debug.ts_draw_e-debug.ts_draw_s
	local tcpu = ucpu+dcpu

	local fps = t_fps()
	local tfps = t_fpstarget()
	
	str=str..
		"    memory: "..mem.." kib\n"..
		"\n"..
		"   init cpu: "..(icpu*100).." %\n"..
		"\n"..
		" update cpu: "..(ucpu*100).." %\n"..
		"   draw cpu: "..(dcpu*100).." %\n"..
		"  total cpu: "..(tcpu*100).." %\n"..
		"\n"..
		"       fps: "..fps.."\n"..
		"target fps: "..tfps.."\n"..
		"\n"..
		" obj_count: "..obj_count
		
	self.tw.str=str
end
