require("t_fpstarget")

--time
--wrapper for keyboard input
-------------------------------
time = {
	name="time",
	dt=nil
}

function time:pre_update()
	if self.dt == nil then
		self.dt=1/t_fpstarget()
		engine:remove_module(self)
	end
end

engine:add_module(time)
