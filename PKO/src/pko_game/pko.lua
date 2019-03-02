--pko
--player avatar
-------------------------------
pko=prim:subclass({
	name="pko",
	pos=vec2:new(64,64),
	geo=nil,
	mc=nil,	--move component
	sc=nil,	--sprite component
	tc=nil,	--trail component
	cc=nil		--camera component
})

function pko:init()
	prim.init(self)

	self.sc=sprite:new(self,{
		s=1
	})
	self.geo = geo:new(col.sprite_geo[1].vs)
	self.geo:calculate_circle()
	self.geo.vs = nil
	self.mc=octo_move:new(self,{
		geo=self.geo
	})

	self.tc=trail:new(self)
	self.cc=camera:new(self)
end

function pko:update()
	self.mc.wv=controller.dpad

	if(controller.ap) then
		self:burst(missile,16)
	end
 
	prim.update(self)
end

function pko:burst(t,num)
	for i=0,num-1 do
		t:new(pko_game.l_ms,{
			pos=self.pos,
			sa=i/num
		})
	end
end
