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
	_sg=obj:new(nil,{
		name="root"
	}),
	_sg_wrap=nil,
	_dev_ui=nil,
	_scenes={},
	_active_scene=nil
}

engine._sg_wrap = obj:new(
	engine._sg,
	{
		name="scene wrapper"
	}
)

function engine:set_active_scene(am)
	for m in all(self._scenes) do
		if(m.name == am) then
			if self._active_scene != nil then
				self._active_scene.sg:detach()
			end
			self._active_scene = m
			if self._active_scene != nil then
				self._sg_wrap:addchild(m.sg)
			end
			break
		end
	end
end

function engine:get_active_scene()
	return self._active_scene
end

--initialization
-------------------------------
function _init()
	cls()
	print "ko engine"
	print "-------------------"

	print "initializing..."
	if not engine._active_scene then
		print "error: no scene loaded"
		return
	end

	
	if(debug != nil) then
		debug.ts_init_b=time:cpu_t()
		print "debug ui..."
		engine._dev_ui=dbg_ui:new(nil)
	end

	--enable color literals
	print "color literals..."
	poke(0x5f34,1)

	--initialize engine
	print "collision..."
	col:init()

	--initialize scenes
	print "scenes..."
	for m in all(engine._scenes) do
		m:init()
	end
	
	if(debug != nil) then
		engine._sg:addchild(engine._dev_ui)
		debug.ts_init_e=time:cpu_t()
	end
end

--main loop
-------------------------------
function _update60()
	if(not engine._active_scene) return
	
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
	engine._sg:update()

	if(dm) then
		debug.ts_update_e=time:cpu_t()
	end
end

--render loop
-------------------------------
function _draw()
	if(not engine._active_scene) return

	local dm = debug != nil
	if(dm) then
		debug.ts_draw_s=time:cpu_t()
	end

	-- draw scenegraph
	engine._sg:draw()
	
	if(dm) then
		debug.ts_draw_e=time:cpu_t()
	end
end
