time={
	dt=0
}

function time:init()
	self.dt=1/self:getfpstarget()
end

function time:getfps()
	return stat(7)
end

function time:getfpstarget()
	return stat(8)
end
