--engine
--collection of engine
--functionality
-------------------------------
require("engine/utility")
require("engine/obj")
require("engine/debug")

engine={
	game=nil,
	sg=obj:new(nil,{
		name="root"
	}),
	dev_mode=true,
	dev_ui=nil
}

--initialization
-------------------------------
function _init()
	print "ko engine"
	print "-------------------"

	print "initializing..."
	if not engine.game then
		print "error: no game module loaded"
		return
	end
	
	if(engine.dev_mode) then
		ts_init_b=time:cpu_t()
		engine.dev_ui=dbg_ui:new(nil)
	end

	--initialize engine
	col:init()

	--initialize game
	engine.game:init()

	if(engine.dev_mode) then
		engine.sg:addchild(engine.dev_ui)
		ts_init_e=time:cpu_t()
	end
end

--main loop
-------------------------------
function _update60()
	if(not engine.game) return
	
	time:update()

	local dm = engine.dev_mode
	if(dm) then
		ts_update_s=time:cpu_t()
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
		ts_update_e=time:cpu_t()
	end
end

--render loop
-------------------------------
function _draw()
	if(not engine.game) return

	local dm = engine.dev_mode
	if(dm) then
		ts_draw_s=time:cpu_t()
	end

	engine.sg:draw()
	
	if(dm) then
		ts_draw_e=time:cpu_t()
	end
end
