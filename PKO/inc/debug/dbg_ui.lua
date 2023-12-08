require("graphic")
require("vec2")
require("trs")
require("box")
require("text")
require("keyboard")
require("ds_camera")
require("color_literals")

require("dbg_ovr")
require("dbg_log")
require("dbg_sg")

--debug ui
dbg_ui=graphic:extend({
	name="debug ui",
	trs=trs:new(),
	tabs=nil,
	at=nil,
	tw=nil,
	wrap=nil
})

function dbg_ui:init()
	graphic.init(self)
	
	local wrap=graphic:new(self,{
		name="wrap"
	})
	self.wrap = wrap
	
	local bg=box:new(wrap,{
		trs=trs:new(vec2:new(61,5)),
		sz=vec2:new(61,4),
		sc=0x1107.0000,
		fc=0x1100.5a5a
	})
	
	self.tw=text:new(bg,{
		trs=trs:new(vec2:new(-58,-2))
	})
	
	local tabs = {}
	tabs["1"]=
		dbg_ovr:new(wrap)
	tabs["2"]=
		dbg_log:new(wrap)
	tabs["3"]=
		dbg_sg:new(wrap,{
			name="update graph",
			root_cb=function()
				return engine.upd_root
			end
		})
	tabs["4"]=
		dbg_sg:new(wrap,{
			name="draw graph",
			root_cb=function()
				return engine.draw_root or
											engine.upd_root
			end
		})
	self.tabs=tabs
end

function dbg_ui:update()
	graphic.update(self)
	self.trs.t=ds_camera()+2

	local tabs = self.tabs
	local at = self.at
	
	for k,tab in pairs(tabs) do
 	if(kb:keyp(k)) then
 		if(at!=k) then
				at=k
				self.tw.str=tab.name
			else
				at=nil
			end
 	end
	end
	
	for k,tab in pairs(tabs) do
		tab.v=k==at
	end
	
	self.at = at
	self.wrap.v = at != nil
end
