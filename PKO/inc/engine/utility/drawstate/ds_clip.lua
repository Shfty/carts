require("rect")

function ds_clip()
	local x1 = peek(0x5f20)
	local y1 = peek(0x5f21)
	return rect:new(
		x1,
		y1,
		peek(0x5f22)-x1,
		peek(0x5f23)-y1
	)
end
