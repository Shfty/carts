require("engine")
require("clear")
require("obj_map")
require("spawner")
require("pko")
require("tut_sat")
require("tree")
require("dot")
require("circle")

--pko_game
--collection of game
--functionality
pko_game={
	bg=nil,

	layers={
		actors=nil,
		player=nil,
		missiles=nil
	},
	
	l_pl=nil,
	l_ms=nil,
	
	pnt_g=nil,
	test=nil,
	col_vis=nil
}
engine.game=pko_game

--initialization
-------------------------------
function pko_game:init()
	--initial scene clear
	clear:new(engine.sg)

	--background
	self.bg=obj_map:new(engine.sg,{
		name="background"
	})

	--layers
	local la=obj:new(
		engine.sg,{
			name="layer: actors"
		}
	)
	
	local lp=obj:new(
		engine.sg,
		{
			name="layer: player"
		}
	)
	
	local lm=obj:new(
		engine.sg,
		{
			name="layer: missiles"
		}
	)

	self.layers.actors = la
	self.layers.player = lp
	self.layers.missiles = lm

	--actors
	spawner:new(
		engine.sg,{
		objs={
			{
				s=1,
				o=pko,
				p=lp
			},
			{
				s=2,
				o=tut_sat,
				p=la
			},
			{
				s=3,
				o=tree,
				p=la
			}
		}
	})

	--debug ui
	if(debug != nil) then
		self.pnt_g=dot:new(engine.dev_ui.pw)

		self.test=circle:new(
			self.layers.player,{
			trs=trs:new(vec2:new(32,32)),
			r=8,
			geo=geo:new(8)
		})

		--dbg_map_col:new(engine.sg)
	end
end
