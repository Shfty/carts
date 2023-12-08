require("mpos2tile")
require("map_geo")
require("isect")

function map_isect(ot,og)
	local op = ot.t
	local ocr = og.cr
	local o1 = mpos2tile(op - ocr)
	local o2 = mpos2tile(op + ocr -1)

	local crs = {}
	for y = max(o1.y+1,1),o2.y+1 do
		for x = max(o1.x+1,1),o2.x+1 do
			local mg = map_geo.geo[y][x]
			if(mg.ptr) mg = map_geo.geo[mg.ptr.y][mg.ptr.x]
			if(mg.geo != nil) then
				local r = isect(
					ot,
					og,
					mg.t,
					mg.geo
				)
				if(r) add(crs,r)
			end
		end
	end

	return crs
end
