require("obj")
require("dbg_axis")

--move
--object for moving a parent
-------------------------------
move=obj:subclass({
	name="move",
	dp=nil,
	geo=nil,
	da=nil         --debug axis
})

function move:init()
	obj.init(self)
	self.dp = self.dp or vec2:new()
	self.da = dbg_axis:new(self)
end

function move:update()
	self.parent.trs.t += self.dp
	self.dp=vec2:new()
	
	if(self.geo) then
		local crs = map_isect(
			self.parent:t(),
			self.geo
		)

		local i = 5
		while i > 0 do
			local ccp = nil
			local ccr = nil
			for cr in all(crs) do
				local d = self.parent:t().t - cr.cp
				local dl = d:len()
				if ccp == nil or ccp < dl then
					ccp = dl
					ccr = cr
				end
			end

			if(ccr != nil) self:collision(ccr)

			crs = map_isect(
				self.parent:t(),
				self.geo
			)

			if(#crs == 0) break
			i -= 1
		end
	end
end

function move:collision(r)
	self.parent.trs.t += r.n * (r.pd+0.0001)
	self.da.trs.t = r.cp
	self.da.trs.r = atan2(r.n)
end
