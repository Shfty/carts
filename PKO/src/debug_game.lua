--debug game
--debugging scene
require("obj")
require("clear")
require("poly")
require("camera")
require("sprite")

debug_game=obj:extend({
	name="debug game",
	cp_axis=nil,
	pd_axis=nil
})

--initialization
-------------------------------
function debug_game:init()
	obj.init(self)

	--initial scene clear
	clear:new(self)
	camera:new(self,{
		trs=trs:new(vec2:new(64,64))
	})

	--debug ui
	if(debug != nil) then
		sprite:new(self,{
			trs=trs:new(
				vec2:new(32,64)-4,
				0,
				vec2:new(1,1)
			),
			s=1
		})

		poly:fromsprite(self,1,{
			trs=trs:new(
				vec2:new(32,64),
				0,
				vec2:new(2,2)
			)
		})
	end
end
