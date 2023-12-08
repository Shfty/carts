require("graphic")
require("trs")
require("vec2")
require("color_literals")

--debug panel
-------------------------------
dbg_panel=graphic:extend({
	name="debug panel",
	sz=nil,
	sy=0,
	key=nil,
	v=false
})

function dbg_panel:init()
	self.trs = self.trs or
												trs:new(
													vec2:new(61,66)
												)

	graphic.init(self)

	self.sz = self.sz or
												vec2:new(61,56)

	box:new(self,{
		sz=self.sz,
		sc=0x1107.0000,
		fc=0x1100.5a5a
	})
end

function dbg_panel:update()
	if(not self.v) return

	local sy = self.sy
	
	if(kb:keyp("-")) sy -= 114
	if(kb:keyp("=")) sy += 114
	if(kb:keyp("[")) sy -= 6
	if(kb:keyp("]")) sy += 6
	
	self.sy = max(sy,0)
	
	graphic.update(self)
end

function dbg_panel:__tostr()
	local w = self.w

	return
		prim.__tostr(self).." "..
		"w:"..flr(w)..","..
		"w:"..flr(w)
end
