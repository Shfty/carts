require("obj")
require("trs")
require("map_find_sprites")

--spawner
--replaces sprites in the map
--with their object
--counterpart
-------------------------------
spawner=obj:extend({
	name="spawner",
	objs=nil
})

function spawner:init()
	prim.init(self)

	self.objs = self.objs or {}

	for obj in all(self.objs) do
		local ps = map_find_sprites(obj.s)
		for p in all(ps) do
			mset(p, 0)
			map_geo.geo[p.y+1][p.x+1]={}

			obj.o:new(obj.p,{
				trs = trs:new((p*8)+4)
			})
		end
	end
end
