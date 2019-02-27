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
	local wx = 0
	if(btn(0)) wx -= 1
	if(btn(1)) wx += 1
	
	local wy = 0
	if(btn(2)) wy -= 1
	if(btn(3)) wy += 1
	
	if(wx==0 and self.vx!=0) then
		local dv=min(
			self.dc*dt,
			abs(self.vx)
		)*sgn(self.vx)
		
		self.vx-=dv
	end
	
	if(wy==0 and self.vy!=0) then
		local dv=min(
			self.dc*dt,
			abs(self.vy)
		)*sgn(self.vy)
		
		self.vy-=dv
	end
	
	self.vx += wx * self.ac * dt
	self.vy += wy * self.ac * dt

	if(abs(self.vx) > self.mv) then
		self.vx=self.mv*sgn(self.vx)
	end
	
	if(abs(self.vy) > self.mv) then
		self.vy=self.mv*sgn(self.vy)
	end

	self.pos.x += self.vx * dt
	self.pos.y += self.vy * dt

	if(btnp(4)) then
		self:burst(missile,40)
	end
 
	prim.update(self)
end

function pko:burst(t,num)
	if(debug_mode) then
		log("burst")
	end
	
	for i=0,num-1 do
		t:new(l_ms,{
			pos=self.pos,
			sa=i/num
		})
	end
end
