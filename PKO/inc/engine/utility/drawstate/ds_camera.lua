require("vec2")

function ds_camera()
	return vec2:new(
		peek4(0x5f26),
		peek4(0x5f28)
	)
end
