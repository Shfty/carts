require("obj")
require("poly")

dbg_map_col=obj:extend({
	name="debug map collision"
})

function dbg_map_col:init()
	obj.init(self)
	
	for y in all(map_geo.geo) do
		for x in all(y) do
			if x.geo != nil then
				poly:new(self,{
					trs=x.t,
					geo=x.geo
				})
				
				circle:new(self,{
					trs=x.t,
					r=x.geo.cr,
					sc=9,
					f=false
				})

				box:new(self,{
					trs=x.t,
					sz=x.geo.be,
					sc=11,
					f=false
				})
			end
		end
	end
end
