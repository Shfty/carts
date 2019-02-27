--cam
--primitive to control camera
-------------------------------
cam=prim:subclass({
	name="camera",
	org=vec2:new(-64,-64)
})

function cam:update()
	local pos = self:getpos()

	camera(
		pos.x,
		pos.y
	)
	prim.update(self)
end
