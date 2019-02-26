--debug overlay
-------------------------------
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
	local tcpu = stat(1)*100
	local scpu = stat(2)*100
	local ucpu = tcpu-scpu
	local fps = getfps()
	local tfps = getfpstarget()
	
	str=str..
		"    memory: "..mem.." kib\n"..
		"\n"..
		"system cpu: "..scpu.." %\n"..
		"  user cpu: "..ucpu.." %\n"..
		" total cpu: "..tcpu.." %\n"..
		"\n"..
		"target fps: "..tfps.."\n"..
		"       fps: "..fps.."\n"..
		"\n"..
		" obj_count: "..obj_count
		
	self.tw.str=str
end
