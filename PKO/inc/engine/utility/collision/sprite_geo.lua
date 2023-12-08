require("convex_hull")
require("geo")

sprite_geo={
	name="sprite geo",
	numspr = 128,
	geo = {}
}

function sprite_geo:pre_init()
	local numspr = self.numspr or 128

	for i=0,numspr-1 do
		if(fget(i)>0) then
		 local vs = convex_hull(i)
			self.geo[i] = geo:new(vs)
		end
	end
end

engine:add_module(sprite_geo)
