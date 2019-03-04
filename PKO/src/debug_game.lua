require("engine")
require("clear")
require("poly")
require("dot")

--debug game
--collection of game
--functionality

debug_game={}
engine.game=debug_game

--initialization
-------------------------------
function debug_game:init()
	--initial scene clear
	clear:new(engine.sg)

	--debug ui
	if(debug != nil) then
		local p1 = poly:fromsprite(engine.dev_ui.pw,1,{
			trs=trs:new(
				vec2:new(),
				0,
				vec2:new(3,3)
			)
		})

		local p2 = poly:fromsprite(engine.sg,81,{
			trs=trs:new(
				vec2:new(64,64),
				0,
				vec2:new(4,4)
			)
		})

		cp_axis = dbg_axis:new(engine.sg)
		pd_axis = dbg_axis:new(engine.sg)

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
