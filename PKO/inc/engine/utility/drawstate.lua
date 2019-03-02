--drawstate
--wrapper for pico8
--internal draw state
-------------------------------
drawstate={}

function drawstate:campos()
	return vec2:new(
		peek4(0x5f26),
		peek4(0x5f28)
	)
end

function drawstate:getclip()
	local x1 = peek(0x5f20)
	local y1 = peek(0x5f21)
	return rect:new(
		x1,
		y1,
		peek(0x5f22)-x1,
		peek(0x5f23)-y1
	)
end
