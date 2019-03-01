--game
--collection of game
--functionality

require("game/effects")
require("game/projectiles")
require("game/pko")

--config
-------------------------------
debug_mode=true

--variables
-------------------------------
root=nil

bg=nil

l_pl=nil
l_tr=nil
l_ms=nil

d_ui=nil

pnt=nil
pnt_g=nil
test=nil
col_vis=nil

player=nil

--initialization
-------------------------------
function _init()
	--calculate dt
	time:init()

	--generate collision
	col:init()

	--setup scenegraph
	root=obj:new(nil,{
		name="root"
	})

	bg=obj_map:new(root,{
		name="background"
	})
	
	l_pl=obj:new(root,{
		name="layer: player"
	})
	
	l_ms=obj:new(root,{
		name="layer: missiles"
	})
	
	l_ui=obj:new(root,{
		name="layer: ui"
	})

	--debug ui
	if(debug_mode) do
		d_ui=dbg_ui:new(l_ui)
		pnt=pointer:new(l_ui)
		
		pnt_g=box:new(pnt,{
			sz=vec2:new(16,8)
		})
		
		test=poly:fromsprite(l_ui,1,{
			pos=vec2:new(32,32),
			sz=vec2:new(16,8)
		})
		
		col_vis=dbg_axis:new(l_ui)
	end

	--spawn player
	local ps = bg:find_sprites(1)
	for foo in all(ps) do
		mset(foo, 0)
		player=pko:new(l_pl,{
			pos = (foo*8)+vec2:new(4,4)
		})
	end
end

--main loop
-------------------------------
function _update60()
	controller:update()
	if(debug_mode) then
		kb:update()
		mouse:update()
	end

	ci = col:isect(pnt_g, test)
	if(ci) then
		pnt_g.pos -= ci.n * ci.pd
		col_vis.pos = ci.cp
		col_vis.a = atan2(ci.n)
	else
		col_vis.pos = vec2:new(-8,-8)
		col_vis.a = 0
	end
	
	root:update()
end

--render loop
-------------------------------
function _draw()
	cls()
	root:draw()
end
