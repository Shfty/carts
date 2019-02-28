--controller
--wrapper for pico8 gamepad
-------------------------------
controller = {
	p=0,							--player index
	dpad=vec2:new(),

	a=false,			--a button
	_la=false,	--last a button
	ap=false,		--a pressed
	
	b=false,			--b button
	_lb=false,	--last b button
	bp=false			--b pressed
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
