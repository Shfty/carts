require("vec2")

resp={
	n=vec2:new(), --normal#
	pd=0,         --penetrate dist
	cp=vec2:new() --contact point
}

function resp:new(n,pd,cp)
	self.__index=self
	return setmetatable({
		n=n or vec2:new(),
		pd=pd or 0,
		cp=cp or vec2:new()
	}, self)
end

function resp:flip()
	self.n = -self.n
	self.cp += self.n*self.pd
end
