require("prim")

--cam
--primitive to control camera
-------------------------------
camera=prim:extend({
	name="camera",
	min=nil,
	max=nil
})

function camera:update()
	local p = self:t().t
	p -= 64
	if self.min then
		p.x = max(p.x,self.min.x)
		p.y = max(p.y,self.min.y)
	end
	if self.max then
		p.x = min(p.x,self.max.x)
		p.y = min(p.y,self.max.y)
	end
	setcam(p)
	prim.update(self)
end
