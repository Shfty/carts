require("pico8")

require("engine")
require("debug")

require("pko_game")

engine.upd_root = pko_game

require("worker_sys")

worker_sys:run(function(self)
	self.num = 100

	for i=1,100 do
		self.idx = i
		yield()
	end

	log("done 1")
end)

worker_sys:run(function(self)
	self.num = 300

	for i=1000,1300 do
		self.idx = i - 1000
		yield()
	end

	log("done 2")
end)
