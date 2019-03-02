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

	local cp = drawstate:campos()
	local pos = self:getpos()
	local d = pos - cp
	--if(d.x<0 or d.y<0 or d.x>127 or d.y>127) return
	
	self:g_draw()
	
 prim.draw(self)
end

function graphic:g_draw()
end

function graphic:col_mask(m)
	m = m or 255
	return band(self.cm,m) > 0
end

require("graphic/dot")
require("graphic/map")
require("graphic/shape")
require("graphic/sprite")
require("graphic/line")
require("graphic/text")
