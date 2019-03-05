--debug game
--debugging scene
require("scene")
require("clear")
require("poly")
require("dot")

debug_game=scene:new({
	name="debug game",
	cp_axis=nil,
	pd_axis=nil
})

--initialization
-------------------------------
function debug_game:init()
	scene.init(self)

	--initial scene clear
	clear:new(self.sg)
	camera:new(self.sg,{
		trs=trs:new(vec2:new(64,64))
	})

	--debug ui
	if(debug != nil) then
		sprite:new(self.sg,{
			trs=trs:new(
				vec2:new(32,64)-4,
				0,
				vec2:new(1,1)
			),
			s=1
		})

		poly:fromsprite(self.sg,1,{
			trs=trs:new(
				vec2:new(32,64),
				0,
				vec2:new(2,2)
			)
		})
	end
end
