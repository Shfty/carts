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
		local p1 = poly:fromsprite(self.sg,1,{
			trs=trs:new(
				vec2:new(32,64),
				0,
				vec2:new(3,3)
			)
		})

		local p2 = poly:fromsprite(self.sg,3,{
			trs=trs:new(
				vec2:new(96,64),
				0,
				vec2:new(4,4)
			)
		})

		local cp_axis = dbg_axis:new(self.sg)
		local pd_axis = dbg_axis:new(self.sg)
		p1.update = function(self)
			dot.update(self)
			
			local r = col:isect(p1:t(),p1.geo,p2:t(),p2.geo)
			if r != nil then
				cp_axis.trs.t = r.cp
				cp_axis.trs.r = atan2(r.n)
				pd_axis.trs.t = r.cp+(-r.n*r.pd)
				pd_axis.trs.r = atan2(r.n)
			end
		end
	end
end
