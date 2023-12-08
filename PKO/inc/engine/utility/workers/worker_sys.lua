require("obj")
require("worker")
require("t_cpu")

worker_sys = {
	name = "worker_sys",
	ts = 1,				--timeslice
	_sws = {},	--sequential workers
	_pws = {}		--parallel workers
}

function worker_sys:post_update()
	local cs = #self._sws
	local cp = #self._pws
	if(cs == 0 and cp == 0) return
	
	while(t_cpu() < self.ts) do
		self:update_s()
		self:update_p()
	end
end

function worker_sys:update_p()
	for w in all(self._pws) do
		if not self:update_w(w) then
			del(self._pws, w)
		end
	end
end

function worker_sys:update_s()
	local w = self._sws[1]
	if w then
		if not self:update_w(w) then
			del(self._sws, w)
		end
	end
end

function worker_sys:update_w(w)
	local cs = costatus(w.cor)
	if cs != "dead" then
		coresume(w.cor, w)
		return true
	end
	return false
end

function worker_sys:run(cor,para)
	para = para or true

	local w = worker:new(cor)

	local ws = self._sws
	if(para) ws = self._pws
	add(ws, w)
	
	return w
end

engine:add_module(worker_sys)
