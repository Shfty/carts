--pko_game
--game scene
require("scene")
require("clear")
require("obj_map")
require("spawner")
require("pko")
require("tut_sat")
require("tree")
require("dot")
require("circle")

pko_game=scene:new({
	name="pko game",
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
})

--initialization
-------------------------------
function pko_game:init()
	scene.init(self)

	--initial scene clear
	clear:new(self.sg)

	--background
	self.bg=obj_map:new(self.sg,{
		name="background"
	})

	--layers
	local la=obj:new(
		self.sg,{
			name="layer: actors"
		}
	)
	
	local lp=obj:new(
		self.sg,
		{
			name="layer: player"
		}
	)
	
	local lm=obj:new(
		self.sg,
		{
			name="layer: missiles"
		}
	)

	self.layers.actors = la
	self.layers.player = lp
	self.layers.missiles = lm

	--actors
	spawner:new(
		self.sg,{
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
		self.pnt_g=dot:new(engine._dev_ui.pw)

		self.test=circle:new(
			self.layers.player,{
			trs=trs:new(vec2:new(32,32)),
			r=8,
			geo=geo:new(8)
		})

		--dbg_map_col:new(self.sg)
	end
end
