controller = {
	p=0,
	dpad=vec2:new(),

	a=false,
	_la=false,
	ap=false,
	
	b=false,
	_lb=false,
	bp=false
}

function controller:new(p)
	self.__index=self
	return setmetatable({
		p=p or 0
	}, self)
end

function controller:update()
	local wx = 0
	if(btn(0,self.p)) wx -= 1
	if(btn(1,self.p)) wx += 1
	self.dpad.x = wx

	local wy = 0
	if(btn(2,self.p)) wy -= 1
	if(btn(3,self.p)) wy += 1
	self.dpad.y = wy

	self._la = self.a
	self.a=btn(4,self.p)
	self.ap=self.a and not self._la

	self._lb = self.b
	self.b=btn(5,self.p)
	self.bp=self.b and not self._lb
end
