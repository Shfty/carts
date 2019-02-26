--debug log
-------------------------------
dbg_log=dbg_panel:subclass({
	name="log",
	key="2",
	buf={},
	bl=30,
	tw=nil
})

function dbg_log:init()
	dbg_panel.init(self)
	
	self.tw=text:new(self,{
		pos=vec2:new(2,2)
	})
end

function dbg_log:update()
	dbg_panel.update(self)
	
	if(not self.v) return
	
	local str=""
	for s in all(self.buf) do
		str = str..s.."\n"
	end
	
	self.tw.pos.y=2-self.sy
	self.tw.str=str
end

function dbg_log:log(str)
	add(self.buf, str)
	if(#self.buf > self.bl) then
		del(
			self.buf,
			self.buf[1]
		)
	end
end

function dbg_log:clear()
	self.buf={}
end
