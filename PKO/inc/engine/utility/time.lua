time={
	dt=0
}

function time:init()
	self.dt=1/self:fpstarget()
end

function time:cpu_t()
	return stat(1)
end

function time:syscpu_t()
	return stat(2)
end

function time:fps()
	return stat(7)
end

function time:fpstarget()
	return stat(8)
end
