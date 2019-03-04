require("p8_redefs")
require("logging")
require("obj")

require("time")
require("collision")

require("controller")
require("keyboard")
require("mouse")

--engine
--collection of engine
--functionality
-------------------------------
engine={
	game=nil,
	sg=obj:new(nil,{
		name="root"
	}),
	dev_ui=nil
}

--initialization
-------------------------------
function _init()
	cls()
	print "ko engine"
	print "-------------------"

	print "initializing..."
	if not engine.game then
		print "error: no game module loaded"
		return
	end

	
	if(debug != nil) then
		debug.ts_init_b=time:cpu_t()
		print "debug ui..."
		engine.dev_ui=dbg_ui:new(nil)
	end

	--enable color literals
	print "color literals..."
	poke(0x5f34,1)

	--initialize engine
	print "collision..."
	col:init()

	--initialize game
	print "game..."
	engine.game:init()

	if(debug != nil) then
		engine.sg:addchild(engine.dev_ui)
		debug.ts_init_e=time:cpu_t()
	end
end

--main loop
-------------------------------
function _update60()
	if(not engine.game) return
	
	time:update()

	local dm = debug != nil
	if(dm) then
		debug.ts_update_s=time:cpu_t()
	end

	--update input
	controller:update()
	if(dm) then
		kb:update()
		mouse:update()
	end

	--update scenegraph
	engine.sg:update()

	if(dm) then
		debug.ts_update_e=time:cpu_t()
	end
end

--render loop
-------------------------------
function _draw()
	if(not engine.game) return

	local dm = debug != nil
	if(dm) then
		debug.ts_draw_s=time:cpu_t()
	end

	engine.sg:draw()
	
	if(dm) then
		debug.ts_draw_e=time:cpu_t()
	end
end
