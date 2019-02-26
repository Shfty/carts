--graphic
--primitive with visual element
-------------------------------
graphic=prim:subclass({
	name="graphic",
	v=true,									--visible
	c=nil, 							  --clip
	_cc=nil  							--cached clip
})

function graphic:draw()
	if(not self.v) return
	
	self:g_predraw()
	self:g_draw()
	self:g_postdraw()
	
 prim.draw(self)
end

function graphic:g_predraw()
	if(self.d) then
		self.cd=getclip()
		clip(
			self.d[1],
			self.c[2],
			self.c[3],
			self.c[4]
		)
	end
	
	if(self.c) then
		self.cc=getclip()
		clip(
			self.c[1],
			self.c[2],
			self.c[3],
			self.c[4]
		)
	end
end

function graphic:g_draw()
end

function graphic:g_postdraw()
	if(self._cc) then
		clip(
			self._cc[1],
			self._cc[2],
			self._cc[3],
			self._cc[4]
		)
		self._cc=nil
	end
end

require("graphic/dot")
require("graphic/map")
require("graphic/shape")
require("graphic/sprite")
require("graphic/stripe")
require("graphic/text")
