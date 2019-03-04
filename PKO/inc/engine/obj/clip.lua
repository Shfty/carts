require("obj")

--primitive
--object with transform
-------------------------------
clip=obj:subclass({
	name="clip",
	r=nil								-- clipping rect
})

function clip:init()
	obj.init(self)
	self.r = self.r or rect:new()
end

function clip:draw()
	local cclip=drawstate:getclip()
	setclip(self.r)
	obj.draw(self)
	setclip(cclip)
end

function clip:__tostr()
	return obj.__tostr(self).." - r:"..self.r
end
