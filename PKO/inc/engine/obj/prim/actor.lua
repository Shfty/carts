require("prim")
require("sprite")

--actor
--dynamic primitive
-------------------------------
actor=prim:subclass({
	name="actor",
	s=0,					--sprite
	h=5,					--health
	_sc=nil,	--sprite component
	_geo=nil,	--geometry
})

function actor:init()
	prim.init(self)

	self._sc=sprite:new(self,{
		trs=trs:new(vec2:new(-4,-4)),
		s=self.s
	})
	self._geo = col.sprite_geo[self.s]
end

function actor:damage(d)
	self.h -= d
	if self.h <= 0 then
		self.die()
	end
end

function actor:die()
	self.destroy()
end
