--check collision
--check collision for a given px
--@mpos vec2 map pixel coords
--@mask (unused) number sprite flag mask
function ccol(mpos, mask)
	--fetch sprite from map
	local mp = mpos2tile(mpos)
	local s = mget(mp)

	--if a sprite is present
	if(s>0) then
		--get spritesheet coords
		local sp = sidx2pos(s)

		--offset by tile-space pos
		sp += mpos%8

		--check if pixel is non-0
		return sget(sp) > 0
	end
end
