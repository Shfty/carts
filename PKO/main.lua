require("src/engine")
require("src/game")

--main

--config
-------------------------------
debug_mode=true

--variables
-------------------------------
dt=nil

root=nil

l_pl=nil
l_tr=nil
l_ms=nil

d_ui=nil
function log(str)
	d_ui.tabs["2"]:log(str)
end

crs=nil

player=nil

--initialization
-------------------------------
function _init()
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
	
	player=pko:new(l_pl)
	
	--debug ui
	if(debug_mode) do
		d_ui=dbg_ui:new(l_ui)
		crs=cursor:new(l_ui)
	end
end

--main loop
-------------------------------
function _update60()
	if(dt==nil) then
		dt=1/getfpstarget()
	end
	
	if(debug_mode) then
		update_kb()
		update_mouse()
	end
	
	root:update()
end

--render loop
-------------------------------
function _draw()
	cls()
	root:draw()
end
