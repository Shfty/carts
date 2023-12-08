--engine
--collection of engine
--functionality
-------------------------------
engine={
	modules={},
	upd_root=nil,
	draw_root=nil
}

function engine:add_module(m)
	add(self.modules, m)
end

function engine:remove_module(m)
	del(self.modules, m)
end

--initialization
-------------------------------
function _init()
	cls()
	print ""
	print " ko engine"
	print " -------------------"
	print " initializing..."

	for m in all(engine.modules) do
		if(m.pre_init != nil) m:pre_init()
	end

	if engine.upd_root then
		engine.upd_root:init()
	end

	for i = #engine.modules,1,-1 do
		local m = engine.modules[i]
		if(m.post_init != nil) m:post_init()
	end
end

--main loop
-------------------------------
function _update60()
	for m in all(engine.modules) do
		if(m.pre_update != nil) m:pre_update()
	end

	if engine.upd_root then
		engine.upd_root:update()
	end

	for i = #engine.modules,1,-1 do
		local m = engine.modules[i]
		if(m.post_update != nil) m:post_update()
	end
end

--render loop
-------------------------------
function _draw()
	for m in all(engine.modules) do
		if(m.pre_draw != nil) m:pre_draw()
	end

	local d_r = engine.draw_root or
													engine.upd_root
	if d_r then
		d_r:draw()
	end

	for i = #engine.modules,1,-1 do
		local m = engine.modules[i]
		if(m.post_draw != nil) m:post_draw()
	end
end
