require("vec2")

--rect
--rectangle
-------------------------------
rect={
	min=vec2:new(),
	max=vec2:new()
}

function rect:new(x1,y1,x2,y2)
	x1 = x1 or 0
	y1 = y1 or 0
	x2 = x2 or 1
	y2 = y2 or 1
	
	self.__index=self
	return setmetatable({
		min=vec2:new(x1,y1),
		max=vec2:new(x2,y2)
	}, self)
end

function rect:is_a(t)
	return t == rect
end

function rect:__tostr()
	return "min:"..self.min..
	",max:"..self.max
end

function rect.__concat(lhs,rhs)
	if(type(lhs)=="table") then
		return lhs:__tostr()..rhs
	end

	if(type(rhs)=="table") then
		return lhs..rhs:__tostr()
	end
end
