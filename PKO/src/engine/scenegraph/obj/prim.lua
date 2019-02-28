--primitive
--object with transform
-------------------------------
prim=obj:subclass({
	name="primitive",
	pos=vec2:new(),
	org=vec2:new()
})

function prim:getpos()
	local pos=vec2:new()
	local c=self
	while(c!=nil) do
		if(c.pos) pos+=c.pos
		if(c.org) pos+=c.org
		c=c.parent
	end

	return pos
end

function prim:__tostr()
	return
		obj.__tostr(self).." - "..
		self.pos:__tostr()
end

require("prim/graphic")
require("prim/cam")
require("prim/pointer")
