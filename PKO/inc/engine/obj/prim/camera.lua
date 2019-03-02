--cam
--primitive to control camera
-------------------------------
camera=prim:subclass({
	name="camera",
	org=vec2:new(-64,-64)
})

function camera:update()
	local pos = self:getpos()
	setcam(pos)
	prim.update(self)
end
