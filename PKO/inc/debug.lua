require("dbg_ui")
require("t_cpu")

debug={
	name = "debug",
	ts_init_s = 0,
	ts_init_e = 0,
	ts_update_s = 0,
	ts_update_e = 0,
	ts_draw_s = 0,
	ts_draw_e = 0,
	ui=nil
}

function debug:pre_init()
	self.ts_init_s = t_cpu()
	self.ui = dbg_ui:new(nil)
end

function debug:post_init()
	self.ts_init_e = t_cpu()
end

function debug:pre_update()
	self.ts_update_s = t_cpu()
end

function debug:post_update()
	self.ui:update()
	self.ts_update_e = t_cpu()
end

function debug:pre_draw()
	self.ts_draw_s = t_cpu()
end

function debug:post_draw()
	self.ui:draw()
	self.ts_draw_e = t_cpu()
end

engine:add_module(debug)
