require("dbg_panel")
require("clip")
require("rect")

--debug log
-------------------------------
dbg_log=dbg_panel:subclass({
	name="log",
	key="2",
	cw=nil,
	tw=nil
})

function dbg_log:init()
	dbg_panel.init(self)

	local cw=clip:new(self,{
		r=rect:new(2,10,124,116)
	})
	self.cw = cw
	
	self.tw=text:new(cw,{
		trs=trs:new(vec2:new(-58,-54))
	})
end

function dbg_log:update()
	dbg_panel.update(self)
	
	if(not self.v) return
	
	local str=""
	for s in all(log_buf) do
		str = str..s.."\n"
	end
	
	local tw = self.tw
	tw.trs.t.y=-54-self.sy
	tw.str=str
end
