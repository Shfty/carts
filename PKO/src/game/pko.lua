pko=prim:subclass({
	name="pko",
	pos=vec2:new(64,64),
	vx=0,
	vy=0,
	ac=600,
	dc=600,
	mv=60,
	sc=nil,	--sprite component
	tc=nil,	--trail component
	cc=nil		--camera component
})

function pko:init()
	prim.init(self)
	self.sc=sprite:new(self,{
		s=1
	})
	self.tc=trail:new(self)
	self.cc=cam:new(self)
end

function pko:update()
	local wv = controller.dpad
	
	if(wv.x==0 and self.vx!=0) then
		local dv=min(
			self.dc*dt,
			abs(self.vx)
		)*sgn(self.vx)
		
		self.vx-=dv
	end
	
	if(wv.y==0 and self.vy!=0) then
		local dv=min(
			self.dc*dt,
			abs(self.vy)
		)*sgn(self.vy)
		
		self.vy-=dv
	end
	
	self.vx += wv.x * self.ac * dt
	self.vy += wv.y * self.ac * dt

	if(abs(self.vx) > self.mv) then
		self.vx=self.mv*sgn(self.vx)
	end
	
	if(abs(self.vy) > self.mv) then
		self.vy=self.mv*sgn(self.vy)
	end

	self.pos.x += self.vx * dt
	self.pos.y += self.vy * dt

	if(controller.ap) then
		self:burst(missile,16)
	end
 
	prim.update(self)
end

function pko:burst(t,num)
	for i=0,num-1 do
		t:new(l_ms,{
			pos=self.pos,
			sa=i/num
		})
	end
end
