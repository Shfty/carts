require("move")

--octo_move
--8-way move
-------------------------------
octo_move=move:subclass({
	name="8-way move",
	v=nil,									--velocity
	mv=80,									--max velocity
	ac=600,								--acceleration
	dc=400,								--deceleration
	wv=nil									--wish vector
})

function octo_move:init()
	move.init(self)
	self.v = self.v or vec2:new()
	self.wv = self.wv or vec2:new()
end

function octo_move:update()
	local v = self.v
	local mv = self.mv
	local dc = self.dc
	local wv = self.wv
	local dt = time.dt

	if(wv.x==0) then
		local dv=min(
			dc*dt,
			abs(v.x)
		)*sgn(v.x)
		
		v.x-=dv
	end
	
	if(wv.y==0) then
		local dv=min(
			dc*dt,
			abs(v.y)
		)*sgn(v.y)
		
		v.y-=dv
	end
	
	v += wv * self.ac * dt

	if(v:len() > mv) then
		v = v:normalize() * mv
	end

	self.v = v
	self.dp = v * dt
	
	move.update(self)
end

function octo_move:collision(r)
	move.collision(self,r)
	local pv = r.n:dot(self.v)
	self.v -= r.n * pv
end
