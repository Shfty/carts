worker = {
	name="worker",
	idx=0,
	num=0,
	cor=nil
}

function worker:new(cor)
	self.__index = self
	return setmetatable({
		cor = cocreate(cor)
	}, self)
end

function worker:__tostr()
	return self.name.." "..
								self.idx.." / "..
								self.num
end
