--pko_game
--game scene
require("obj")

require("dot")
require("circle")

require("clear")
require("obj_map")
require("spawner")

require("pko")
require("tut_sat")
require("tree")

require("controller")

require("log")

pko_game=obj:extend({
	name="pko game",
	bg=nil,

	layers={
		actors=nil,
		player=nil,
		missiles=nil
	},

	c_p1=nil
})

--initialization
-------------------------------
function pko_game:init()
	obj.init(self)

	--initial scene clear
	clear:new(self)

	--background
	self.bg=obj_map:new(self,{
		name="background"
	})

	--layers
	local la=obj:new(
		self,{
			name="layer: actors"
		}
	)
	
	local lp=obj:new(
		self,
		{
			name="layer: player"
		}
	)
	
	local lm=obj:new(
		self,
		{
			name="layer: missiles"
		}
	)

	self.layers.actors = la
	self.layers.player = lp
	self.layers.missiles = lm

	--actors
	spawner:new(
		self,{
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
end
