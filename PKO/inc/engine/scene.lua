require("engine")

scene={
	name="scene",
	sg=nil
}

function scene:new(t)
	self.__index=self
	local o = setmetatable(
		t or {},
		self
	)
	o.sg = obj:new(nil)
	add(engine._scenes, o)
	return o
end

function scene:init()
	self.sg.name = self.name
end
