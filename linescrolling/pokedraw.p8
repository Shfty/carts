pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- globals

p_scr = 0x6000
p_udata = 0x4300
c = {1,2,3,1,2,3,4,5,6,4,5,6}
draw_poke = true

sx = 0
ex = 127

rec16=1/16

-->8
-- pokeline
function pokeline(xa,xb,y)
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
			lc = c[1+flr(norm*#c)]
		end
		
		if ri <= xb then
			local ld = ri-xa
			local td = xb-xa+1
			local norm = ld/td
			rc = c[1+flr(norm*#c)]
		end
		
		local cc = lc+rc*16
		poke(p_pix, cc)
	end
end
-->8
-- drawline
function drawline(xa,xb,y,cols)
	local cols = cols or {0}
	
	local step = (xb-xa)/#cols
	i=1
	for x = xa,xb,step do
		local le = x+step
		rect(x,y,le,y,cols[i])
		i += 1
	end
end
-->8
-- main

function _update60()
	if(btnp(4)) then sx -= 1 end
	if(btnp(5)) then sx += 1 end
	if(btnp(0)) then ex -= 1 end
	if(btnp(1)) then ex += 1 end
	if(btnp(2)) then
		draw_poke = not draw_poke
	end
end

function _draw()
	cls()
 for y = 64,127 do
 	if(draw_poke) then
 		pokeline(sx,ex,y,c)
 	else
 		drawline(sx,ex,y,c)
 	end
	end
	
 -- draw ui
 rect(1,1,48,16,6)
 rectfill(2,2,47,15,0)
 
 fillp()
 color(7)
 print("cpu "..stat(1)*0.5,3,3)
 print("fps "..stat(8),3,10)
end
