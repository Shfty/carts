require("missile")
require("dot")

--laser
--reflective projectile
-------------------------------
laser=missile:extend({
	name="laser"
})

function laser:graphic()
	return dot:new(self)
end

function laser:trail()
	return trail:new(self)
end
