--octo_move
--8-way move
-------------------------------
octo_move=move:subclass({
	name="8-way move",
	v=vec2:new(),		--velocity
	mv=60,									--max velocity
	ac=600,								--acceleration
	dc=600,								--deceleration
	wv=vec2:new()		--wish vector
})

function octo_move:update()
	if(self.wv.x==0 and self.vx!=0) then
		local dv=min(
			self.dc*dt,
			abs(self.v.x)
		)*sgn(self.v.x)
		
		self.v.x-=dv
	end
	
	if(self.wv.y==0 and self.v.y!=0) then
		local dv=min(
			self.dc*dt,
			abs(self.v.y)
		)*sgn(self.v.y)
		
		self.v.y-=dv
	end
	
	self.v.x += self.wv.x * self.ac * dt
	self.v.y += self.wv.y * self.ac * dt

	if(abs(self.v.x) > self.mv) then
		self.v.x=self.mv*sgn(self.v.x)
	end
	
	if(abs(self.v.y) > self.mv) then
		self.v.y=self.mv*sgn(self.v.y)
	end

	self.parent.pos.x += self.v.x * dt
	self.parent.pos.y += self.v.y * dt
	
	move.update(self)
end
