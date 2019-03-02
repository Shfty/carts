--game
--collection of game
--functionality
require("pko_game/effects")
require("pko_game/projectiles")
require("pko_game/pko")

pko_game={
	root=nil,
	
	bg=nil,
	
	l_pl=nil,
	l_tr=nil,
	l_ms=nil,
	
	pnt_g=nil,
	test=nil,
	col_vis=nil
}

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
	self.l_pl=obj:new(engine.sg,{
		name="layer: player"
	})
	
	self.l_ms=obj:new(engine.sg,{
		name="layer: missiles"
	})
	
	self.l_ui=obj:new(engine.sg,{
		name="layer: ui"
	})

	--spawn player
	local ps = self.bg:find_sprites(1)
	for foo in all(ps) do
		mset(foo, 0)
		pko:new(self.l_pl,{
			pos = (foo*8)+vec2:new(4,4)
		})
	end

	--debug ui
	if(engine.dev_mode) then
		self.pnt_g=dot:new(engine.dev_ui.pw)

		self.test=circle:new(self.l_pl,{
			pos=vec2:new(32,32),
			r=8,
			geo=geo:new(8)
		})
		--[[
		self.test=box:new(self.l_pl,{
			pos=vec2:new(32,32),
			sz=vec2:new(8,8),
			geo=geo:new(vec2:new(8,8))
		})
		self.test=poly:fromsprite(self.l_pl,1,{
			pos=vec2:new(32,32)
		})
		]]
	end
end
