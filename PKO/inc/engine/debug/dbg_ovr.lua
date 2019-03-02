--debug overlay
-------------------------------
ts_init_s = 0
ts_init_e = 0
ts_update_s = 0
ts_update_e = 0
ts_draw_s = 0
ts_draw_e = 0

dbg_ovr=dbg_panel:subclass({
	name="system info",
	key="1",
	mw=nil,		--memory widget
	cw=nil,		--cpu widget
	ow=nil			--object widget
})

function dbg_ovr:init()
	dbg_panel.init(self)
	
	self.tw=text:new(self,{
		pos=vec2:new(2,2)
	})
end

function dbg_ovr:update()
	dbg_panel.update(self)
	
	if(not self.v) return
	
	local str = ""
	
	--memory
	local mem=stat(0)
	
	--cpu
	local icpu = ts_init_e-ts_init_s
	
	local ucpu = ts_update_e-ts_update_s
	local dcpu = ts_draw_e-ts_draw_s
	local tcpu = ucpu+dcpu

	local fps = time:fps()
	local tfps = time:fpstarget()
	
	str=str..
		"    memory: "..mem.." kib\n"..
		"\n"..
		"   init cpu: "..(icpu*100).." %\n"..
		"\n"..
		" update cpu: "..(ucpu*100).." %\n"..
		"   draw cpu: "..(dcpu*100).." %\n"..
		"  total cpu: "..(tcpu*100).." %\n"..
		"\n"..
		"target fps: "..tfps.."\n"..
		"       fps: "..fps.."\n"..
		"\n"..
		" obj_count: "..obj_count
		
	self.tw.str=str
end
