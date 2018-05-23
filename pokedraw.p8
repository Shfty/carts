pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
p_scr = 0x6000
c = {1,2,3,1,2,3,4,5,6,4,5,6}

sx = 0
ex = 127

function _update60()
	if(btnp(4)) then sx -= 1 end
	if(btnp(5)) then sx += 1 end
	if(btnp(0)) then ex -= 1 end
	if(btnp(1)) then ex += 1 end
end

function _draw()
	cls()
 for y = 64,127 do
 	pokeline(sx,ex,y,c)
	end
end

rec16=1/16
function pokeline(xa,xb,y,cols)
	cols = cols or {0}
	
	local fa = xa * 0.5
	local fb = xb * 0.5
	local ia = flr(fa)
	local ib = flr(fb)
	
	for x = ia,ib do
		local p_pix = p_scr+x+y*64

		local lc = 0
		local rc = 0
		
		local li = x*2
		local ri = li+1
		
		if li >= xa then
			local ld = li-xa
			local td = xb-xa+1
			local norm = ld/td
			lc = cols[1+flr(norm*#cols)]
		end
		
		if ri <= xb then
			local ld = ri-xa
			local td = xb-xa+1
			local norm = ld/td
			rc = cols[1+flr(norm*#cols)]
		end
		
		local cc = lc+rc*16
		poke(p_pix, cc)
	end
end
