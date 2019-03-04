require("obj")

--primitive
--object with transform
-------------------------------
clear=obj:subclass({
	name="clear",
	c=0	--color
})

function clear:draw()
	cls(self.c)
	obj.draw(self)
end

function clear:__tostr()
	return obj.__tostr(self).." - c:"..self.c
end
