--debug scenegraph
-------------------------------
dbg_sg=dbg_panel:subclass({
	name="scenegraph",
	root=nil,
	key="3",
	tw=nil
})

function dbg_sg:init()
	dbg_panel.init(self)
	
	self.tw=text:new(self,{
		pos=vec2:new(2,2),
		clip={2,10,124,116}
	})
end

function dbg_sg:update()
	dbg_panel.update(self)
	
	if(not self.v) return
	
	self.tw.pos.y=2-self.sy
	self.tw.str=root:print()
end
