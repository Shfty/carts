dbg_col=obj:subclass()

function dbg_col:init()
	obj.init(self)
	
	for k,geo in pairs(col.sprite_geo) do
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
		box:new(engself,{
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