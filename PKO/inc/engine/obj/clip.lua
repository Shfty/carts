--primitive
--object with transform
-------------------------------
clip=obj:subclass({
	name="clip",
	r=rect:new()
})

function clip:draw()
	local cclip=drawstate:getclip()
	setclip(self.r)
	obj.draw(self)
	setclip(cclip)
end

function clip:__tostr()
	return obj.__tostr(self).." - r:"..self.r
end
