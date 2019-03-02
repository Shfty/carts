--debug ui
dbg_ui=graphic:subclass({
	name="debug ui",
	pos=vec2:new(2,2),
	tabs=nil,
	at=nil,
	tw=nil,
	pw=nil,
	wrap=nil
})

function dbg_ui:init()
	graphic.init(self)
	
	local wrap=graphic:new(self,{
		name="wrap"
	})
	self.wrap = wrap

	self.pw=pointer:new(self)
	
	local bg=box:new(wrap,{
		sz=vec2:new(123,8),
		sc=0x1107.0000,
		fc=0x1100.5a5a
	})
	
	self.tw=text:new(bg,{
		pos=vec2:new(2,2)
	})
	
	local tabs = {}
	tabs["1"]=
		dbg_ovr:new(wrap)
	tabs["2"]=
		dbg_log:new(wrap)
	tabs["3"]=
		dbg_sg:new(wrap)
	self.tabs=tabs
end

function dbg_ui:update()
	graphic.update(self)
	self.pos=drawstate:campos()+2

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
