--graphic
--primitive with visual element
-------------------------------
graphic=prim:subclass({
	name="graphic",
	v=true,							--visible
	cm=nil,							--collision mask
	clip=nil,					--clip
	_cclip=nil				--cached clip
})

function graphic:draw()
	if(not self.v) return
	
	self:g_predraw()
	self:g_draw()
	self:g_postdraw()
	
 prim.draw(self)
end

function graphic:g_predraw()
	if(self.clip) then
		self._cclip=drawstate:getclip()
		clip(
			self.clip[1],
			self.clip[2],
			self.clip[3],
			self.clip[4]
		)
	end
end

function graphic:g_draw()
end

function graphic:g_postdraw()
	if(self._cclip) then
		clip(
			self._cclip[1],
			self._cclip[2],
			self._cclip[3],
			self._cclip[4]
		)
		self._cclip=nil
	end
end

function graphic:col_mask(m)
	m = m or 255
	return band(self.cm,m) > 0
end

require("graphic/dot")
require("graphic/map")
require("graphic/shape")
require("graphic/sprite")
require("graphic/stripe")
require("graphic/text")
