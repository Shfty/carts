require("vec2")

--trs
--transform
-------------------------------
trs={
	t=nil,		--translate
	r=0,				--rotate
	s=nil,			--scale
	a=false		--absolute
}

function trs:new(t,r,s,a)
	local t = t or vec2:new()
	local r = r or 0
	local s = s or vec2:new(1,1)
	local a = a or false
	
	self.__index=self
	return setmetatable({
		t = t,
		r = r or 0,
		s = s,
		a = a
	}, self)
end

function trs:is_a(t)
	return t == trs
end

function trs:__mul(rhs)
	return trs:new(
		self.t+rhs.t,
		self.r+rhs.r,
		self.s*rhs.s
	)
end

function trs:__tostr()
	return "trs t:"..self.t..
								",r:"..self.r..
								",s:"..self.s
end

function trs.__concat(lhs,rhs)
	return tostr(lhs)..tostr(rhs)
end
