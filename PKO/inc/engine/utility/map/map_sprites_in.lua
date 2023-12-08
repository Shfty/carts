require("mpos2tile")

function map_sprites_in(p1,p2,max)
	max=max or vec2:new(255,127)

	local mp1 = mpos2tile(p1)
	local mp2 = mpos2tile(p2)

	ss={}

	for x=mp1.x,mp2.x do
		for y=mp1.y,mp2.y do
			local s = mget(vec2:new(x,y))
			if(s>0) then
				local st = {
					trs=trs:new(
						vec2:new(
							(x*8)+4,
							(y*8)+4
						)
					),
					s=s
				}
				add(ss,st)
			end
		end
	end

	return ss
end
