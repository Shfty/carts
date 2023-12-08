require("vec2")

--sprite pos > sprite index
--@spos vec2 sprite pixel coords
--@return number sprite index
function spos2idx(spos)
	local dp = spos/8
	return stile2idx(
		vec2:new(
			flr(dp.x),
			flr(dp.y)
		)
	)
end
