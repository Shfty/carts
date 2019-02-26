--vec2
--two dimensional vector
-------------------------------
vec2={
	x=0,
	y=0
}

function vec2:new(ix,iy)
	self.__index=self
	return setmetatable({
		x=ix or 0,
		y=iy or 0
	}, self)
end

function vec2:__unm()
	return vec2:new(
		-self.x,
		-self.y
	)
end

function vec2:__add(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x+rhs.x,
 		self.y+rhs.y
 	)
	end
	
	return vec2:new(
		self.x+rhs,
		self.y+rhs
	)
end

function vec2:__sub(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x-rhs.x,
 		self.y-rhs.y
 	)
	end
	
	return vec2:new(
		self.x-rhs,
		self.y-rhs
	)
end

function vec2:__mul(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x*rhs.x,
 		self.y*rhs.y
 	)
	end
	
	return vec2:new(
		self.x*rhs,
		self.y*rhs
	)
end

function vec2:__div(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x/rhs.x,
 		self.y/rhs.y
 	)
 end
 
	return vec2:new(
		self.x/rhs,
		self.y/rhs
	)
end

function vec2:__mod(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x%rhs.x,
 		self.y%rhs.y
 	)
 end
 
	return vec2:new(
		self.x%rhs,
		self.y%rhs
	)
end

function vec2:__pow(rhs)
	if(type(rhs)=="table") then
 	return vec2:new(
 		self.x^rhs.x,
 		self.y^rhs.y
 	)
 end
 
	return vec2:new(
		self.x^rhs,
		self.y^rhs
	)
end

function vec2:__concat(rhs)
	if(type(self)=="table") then
		return self:tostring()..rhs
	end

	if(type(rhs)=="table") then
		return self..rhs:tostring()
	end
end

function vec2:sqlen()
	local sql = 0
	sql+=self.x^2
	sql+=self.y^2
	return sql
end

function vec2:len()
	return sqrt(self:sqlen())
end

function vec2:lerp(tgt,d)
	d = max(d,0)
	d = min(d,1)
	return vec2:new(
		lerp(self.x,tgt.x,d),
		lerp(self.y,tgt.y,d)
	)
end

function vec2:tostring()
	return "x:"..flr(self.x)..
	",y:"..flr(self.y)
end

--input
poke(0x5f2d,1)

--graphics
poke(0x5f34,1)

--keyboard
-------------------------------
kp=nil
kc=nil

function update_kb()
	kp=stat(30)
	kc=stat(31)
end

function keyp(char)
	return kp and kc == char
end

--mouse
-------------------------------
mp=vec2:new()
mb=0

function update_mouse()
	mp.x=stat(32)
	mp.y=stat(33)
	mb=stat(34)
end

function keyp(char)
	return kp and kc == char
end
