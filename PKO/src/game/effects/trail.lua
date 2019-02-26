trail=graphic:subclass({
	name="trail",
	cs={12,13,1}, --colors
	ld=4,									--line divisions
	ds=nil,							--divisions
	ln=32,								--length
	md=0,								--move delta
})

function trail:init()
	prim:init()
	self.ds={}
	local pos=self:getpos()
	for i=1,self.ld do
		add(self.ds,pos)
	end
end

function trail:update()
	local pos = self:getpos()
	local dp = pos-self.ds[#self.ds]
 self.md = dp:len()/(self.ln/self.ld)
 
	if(self.md>=1) then
 	add(self.ds,pos)
 	if(#self.ds>self.ld) then
 		del(self.ds,self.ds[1])
 	end
	end
	
	graphic.update(self)
end

function trail:g_draw()
	for i=1,#self.cs do
		local idx = #self.cs-i+1
		local dcs=(i-1)/#self.cs
		local dce=i/#self.cs
		local c=self.cs[idx]
		for o=1,#self.ds do
			local dds=(o-1)/#self.ds
			local dde=o/#self.ds
			local ds=self.ds[o]
			local de=self.ds[o+1] or self:getpos()
			
			--contain
			if(dcs < dds and dce > dde) then
				line(
					ds.x-0.5,
					ds.y-0.5,
					de.x-0.5,
					de.y-0.5,
					c
				)
			else
 			local li=dcs >= dds and dcs <=dde
 			local ri=dce >= dds and dce <=dde
			
 			if(ri and not li) then
					local l=vec2.lerp(ds,de,self.md)
 				line(
 					ds.x-0.5,
 					ds.y-0.5,
 					l.x-0.5,
 					l.y-0.5,
 					c
 				)
 			else
  			if(li and not ri) then
					local l=vec2.lerp(ds,de,self.md)
  				line(
  					l.x-0.5,
  					l.y-0.5,
  					de.x-0.5,
  					de.y-0.5,
  					c
  				)
  			end
 			end
			end
		end
	end
	
	graphic.g_draw(self)
end
