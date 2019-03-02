--primitive
--object with transform
-------------------------------
prim=obj:subclass({
	name="primitive",
	pos=vec2:new(),			--position
	apos=false,
	org=vec2:new(),			--origin
	a=0														--angle
})

function prim:getpos()
	local pos=vec2:new()
	local c=self
	while c!=nil do
		local cp = c.pos
		local cap = c.apos
		local co = c.org

		if(cp) pos+=cp
		if(co) pos+=co

		if(cap) then
			break
		else
			c=c.parent
		end
	end

	return pos
end

function prim:__tostr()
	return
		obj.__tostr(self).." - "..
		self.pos:__tostr()
end

require("prim/graphic")
require("prim/camera")
require("prim/pointer")
