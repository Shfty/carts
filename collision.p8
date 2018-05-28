pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- object
object = {}

function object:new(o)
	self.__index = self
	
 return setmetatable(
		o or {},
		self
	)
end

-- vector 2d
vec2 = object:new({
	x = 0,
	y = 0
})

vec2.new = function(self,x,y)
	local v = object.new(self)
	v.x = x or 0
	v.y = y or 0
	return v
end

-- bounding volume
b_vol = object:new()

b_vol.new = function(self)
	local bv = object.new(self)
	bv.pos = vec2:new()
	return bv
end

function b_vol:_update()
end

function b_vol:_draw()
end

-- bounding box
b_box = b_vol:new()

b_box.new = function(self)
	local b = b_vol.new(self)
	b.ext = vec2:new(4,4)
	return b
end

function b_box:_draw()
	rect(
		self.pos.x-self.ext.x,
		self.pos.y-self.ext.y,
		self.pos.x+self.ext.x,
		self.pos.y+self.ext.y,
		7
	)
end

function b_box:isect(b)
	local mt = getmetatable(b)
	if mt == b_box then
		return i_box_box(self,b)
	end
	if mt == b_crc then
		return i_box_crc(self,b)
	end	
end

-- bounding circle
b_crc = b_vol:new()

b_crc.new = function(self)
	local c = b_vol.new(self)
	c.rad = 4
	return c
end

function b_crc:_draw()
	circ(
		self.pos.x,
		self.pos.y,
		self.rad,
		7
	)
end

function b_crc:isect(b)
	local mt = getmetatable(b)
	if mt == b_crc then
		return i_crc_crc(self,b)
	end
	if mt == b_box then
		return i_box_crc(b,self)
	end	
end

function i_box_box(lhs,rhs)
end

function i_box_crc()
end

function i_crc_crc()
end
-->8
volumes = {}

box_a = b_box:new()
box_a.pos.x = 60
box_a.pos.y = 60
add(volumes,box_a)

box_b = b_box:new()
box_b.pos.x = 68
box_b.pos.y = 68
add(volumes,box_b)

crc_a = b_crc:new()
crc_a.pos.x = 96
crc_a.pos.y = 32
add(volumes, crc_a)

function _update60()
	if btnp(0) then
		box_a.pos.x -= 1
	end
	
	if btnp(1) then
		box_a.pos.x += 1
	end
	
	if btnp(2) then
		box_a.pos.y -= 1
	end
	
	if btnp(3) then
		box_a.pos.y += 1
	end
	
	for vol in all(volumes) do
		vol:_update()
	end
end

function _draw()
	cls()
	
	for vol in all(volumes) do
		vol:_draw()
	end
end
