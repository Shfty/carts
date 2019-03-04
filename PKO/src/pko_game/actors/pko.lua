require("actor")
require("octo_move")
require("trail")
require("camera")
require("missile")
require("laser")

--pko
--player avatar
-------------------------------
pko=actor:subclass({
	name="pko",
	s=1,
	mc=nil,	--move component
	tc=nil,	--trail component
	cc=nil		--camera component
})

function pko:init()
	actor.init(self)

	self.mc=octo_move:new(self,{
		geo=self._geo
	})
	self.tc=trail:new(self)
	self.cc=camera:new(self,{
		min=vec2:new(0,0),
		max=vec2:new(386,128)
	})
end

function pko:update()
	self.mc.wv=controller.dpad

	if(controller.ap) then
		self:burst(missile,16)
	end

	if(controller.bp) then
		self:burst(laser,16)
	end
 
	prim.update(self)
end

function pko:burst(t,num)
	for i=0,num-1 do
		t:new(
			pko_game.layers.missiles,
			{
				trs=trs:new(self.trs.t),
				sa=i/num
			}
		)
	end
end
