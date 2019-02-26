--debug ui
dbg_ui=graphic:subclass({
	name="debug ui",
	pos=vec2:new(2,2),
	tabs=nil,
	at=nil,
	tw=nil
})

function dbg_ui:init()
	graphic.init(self)
	
	local bg=box:new(self,{
		sz=vec2:new(123,8),
		sc=0x1107.0000,
		fc=0x1100.5a5a
	})
	
	self.tw=text:new(bg,{
		pos=vec2:new(2,2),
		str="foo"
	})
	
	self.tabs={}
	self.tabs["1"]=
		dbg_ovr:new(self)
	self.tabs["2"]=
		dbg_log:new(self)
	self.tabs["3"]=
		dbg_sg:new(self,{
			root=root
		})
end

function dbg_ui:update()
	graphic.update(self)
	self.pos=camerapos()+2
	
	for k,tab in pairs(self.tabs) do
 	if(keyp(k)) then
 		if(self.at!=k) then
				self.at=k
				self.tw.str=tab.name
			else
				self.at=nil
			end
 	end
	end
	
	for k,tab in pairs(self.tabs) do
		tab.v=k==self.at
	end
	
	self.v = self.at != nil
end
