--laser
--reflective projectile
-------------------------------
laser=missile:subclass({
	name="laser"
})

function laser:init()
	prim.init(self)
	dot:new(self)
	self:trail()
end

function laser:trail()
	return trail:new(self)
end
