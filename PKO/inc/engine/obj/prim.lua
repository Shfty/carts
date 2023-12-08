require("obj")
require("trs")

--primitive
--object with transform
-------------------------------
prim=obj:extend({
	name="primitive",
	trs=nil											--transform
})

function prim:init()
	obj.init(self)
	self.trs = self.trs or trs:new()
end

function prim:t()
	local t = trs:new()

	local c = self
	while c != nil do
		local ct = c.trs
		if(ct) then
			t = t * ct
			if(ct.a) return t
		end
		c = c.parent
	end

	return t
end

function prim:__tostr()
	return
		obj.__tostr(self).." - "..
		self.trs:__tostr()
end
