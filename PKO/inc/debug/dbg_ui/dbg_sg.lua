require("dbg_panel")

--debug scenegraph
-------------------------------
dbg_sg=dbg_panel:extend({
	name="scenegraph",
	key="3",
	cw=nil,
	tw=nil,
	root_cb=nil
})

function dbg_sg:init()
	dbg_panel.init(self)

	self.cw=clip:new(self,{
		r=rect:new(2,12,122,112)
	})
	
	self.tw=text:new(self.cw,{
		trs=trs:new(vec2:new(-58,-54))
	})
end

function dbg_sg:update()
	dbg_panel.update(self)
	
	if(not self.v) return
	if(not self.root_cb) return

	local tw = self.tw
	tw.trs.t.y=-54-self.sy
	tw.str=self.root_cb():print()
end
