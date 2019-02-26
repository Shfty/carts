pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
parent={
	p_str="parent"
}

function parent:new(o)
	self.__index = self
	return
		setmetatable(o or {}, self)
end

function parent:pr()
	print(self.p_str)
end
-->8
child=parent:new({
	p_str="bottom",
	c_str="child"
})

function child:pr()
	parent.pr(self)
	print(self.c_str)
end

-->8
cls()

foo = parent:new()
bar = child:new()

foo:pr()
bar:pr()
