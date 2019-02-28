--collision
--wrapper for collision
--functionality
-------------------------------
collision={
	sprite_geo={},
	debug=false
}

function collision:init(numspr)
	numspr = numspr or 128

	for i=0,numspr-1 do
		if(fget(i)>0) then
			local k = tostr(i)
		 local vs = convex_hull(i)
			self.sprite_geo[k] = vs

			if(self.debug) then
				poly:fromsprite(l_pl,i,{
					pos=vec2:new(
						(i%16)*10,
						flr(i/16)*10
					)
				})
			end
		end
	end
end
