require("obj")
require("vec2")
require("trs")
require("sprite_geo")

dbg_spr_col=obj:extend({
	name="debug sprite collision"
})

function dbg_spr_col:init()
	obj.init(self)
	
	for k,geo in pairs(sprite_geo.geo) do
		circle:new(self,{
			trs=trs:new(
				vec2:new(
					4+(k%16)*10,
					4+flr(k/16)*10
				)
			),
			r=geo.cr,
			sc=9,
			f=false
		})
		box:new(self,{
			trs=trs:new(
				vec2:new(
					4+(k%16)*10,
					4+flr(k/16)*10
				)
			),
			sz=geo.be,
			sc=11,
			f=false
		})
		poly:fromsprite(self,k,{
			trs=trs:new(
				vec2:new(
					4+(k%16)*10,
					4+flr(k/16)*10
				)
			),
		})
	end
end
