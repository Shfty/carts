require("obj")
require("map")

--spawner
--replaces sprites in the map
--with their object
--counterpart
-------------------------------
spawner=obj:subclass({
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
			col.map_geo[p.y+1][p.x+1]={}

			obj.o:new(obj.p,{
				trs = trs:new((p*8)+4)
			})
		end
	end
end
