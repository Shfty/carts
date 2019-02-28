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
dt=nil

root=nil

bg=nil

l_pl=nil
l_tr=nil
l_ms=nil

d_ui=nil

crs=nil
crs_g=nil
test=nil

player=nil

--initialization
-------------------------------
function _init()
	--generate collision
	collision:init()

	--setup scenegraph
	root=obj:new(nil,{
		name="root"
	})

	bg=obj_map:new(root,{
		name="background",
		w=16,
		h=16
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
		crs=cursor:new(l_ui)
		
		crs_g=circle:new(crs,{
			r=5
		})
		
		test=poly:fromsprite(l_pl,1,{
			pos=vec2:new(32,32)
		})
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
	if(dt==nil) then
		dt=1/getfpstarget()
	end
	
	controller:update()
	if(debug_mode) then
		kb:update()
		mouse:update()
	end

	log(collision:isect(crs_g, test))
	
	root:update()
end

--render loop
-------------------------------
function _draw()
	cls()
	root:draw()
end
