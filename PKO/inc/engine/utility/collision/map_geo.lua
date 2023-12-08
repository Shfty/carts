require("vec2")
require("trs")
require("geo")
require("sprite_geo")

--collision
--wrapper for collision
--functionality
-------------------------------
map_geo={
	name="map geo",
	min=nil,
	max=nil,
	geo={}
}

function map_geo:pre_init()
	local min = self.min or vec2:new(0,0)
	local max = self.max or vec2:new(63,31)

	-- create geo for each map tile
	for y = min.y,max.y do
		self.geo[y+1] = {}
		for x = min.x,max.x do
			self.geo[y+1][x+1] = {}
			local p = vec2:new(x,y)
			local s = mget(p)
			if s > 0 then
				self.geo[y+1][x+1] = {
					t=trs:new((p*8)+4),
					geo=sprite_geo.geo[s]
				}
			end
		end
	end

	local square_geo = geo:new({
		vec2:new(4,-4),
		vec2:new(4,4),
		vec2:new(-4,4),
		vec2:new(-4,-4),
	})
		
	-- merge vertical lines of square tiles
	for y = 1,#self.geo do
		for x = 1,#self.geo[y] do
			local sg = self.geo[y][x]
			if sg.geo != nil and
						sg.geo == square_geo and
						sg.t.s == vec2:new(1,1) then
				for e = y+1,#self.geo do
					local eg = self.geo[e][x]
					if(eg.geo == nil) break
					if(eg.geo != square_geo) break
					if(eg.t.s != vec2:new(1,1)) break
					self.geo[e][x] = {
						ptr=vec2:new(x,y)
					}
					local nx = x - 1
					local ny = y + ((e-y)-1)/2
					self.geo[y][x].t.t =	vec2:new(
						(nx*8)+4,
						(ny*8)
					)
					self.geo[y][x].t.s.y = (e-y)+1
				end
			end
		end
	end

	-- merge horizontal lines of square tiles
	for y = 1,#self.geo do
		for x = 1,#self.geo[y] do
			local sg = self.geo[y][x]
			if sg.geo != nil and sg.geo == square_geo and sg.t.s == vec2:new(1,1) then
				for e = x+1,#self.geo[y] do
					local eg = self.geo[y][e]
					if(eg.geo == nil) break
					if(eg.geo != square_geo) break
					self.geo[y][e] = {ptr=vec2:new(x,y)}
					local nx = x + ((e-x)-1)/2
					local ny = (y-1)
					self.geo[y][x].t.t =	vec2:new(
						(nx*8),
						(ny*8)+4
					)
					self.geo[y][x].t.s.x = (e-x)+1
				end
			end
		end
	end
end

engine:add_module(map_geo)
