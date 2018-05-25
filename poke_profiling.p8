pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- globals 
p_screen = 0x6000
use_poke = false

-->8
-- pokeline

--[[
	draws a horizontal line
	by poking values into
	screen memory
	
	very fast
]]

function pokeline(xa,xb,y,c)
	local lxa = flr(xa*0.5)
	local lxb = flr(xb*0.5)
	local ly = (y*64)
	
	for i=lxa,lxb do
		local p_pix = p_screen+i+ly
		
		local lc = c%16+c*16
		if i==lxa and xa%2==1 then
			lp = peek(p_screen+i+ly)
			lp %= 16
			lc = lp+(c*16)
		end
		
		if i==lxb and xb%2==0 then
			rp = peek(p_screen+i+ly)
			rp /= 16
			lc = (c%16)+rp
		end

		poke(p_pix,lc)
	end
end

-->8
-- main

p_screen = 0x6000
use_poke = false

function _update60()
	if(btnp(4)) then
		use_poke = not use_poke
	end
end

function _draw()
	cls()
	
	for y=0,127 do
		for x=0,15 do
			xa = x*8
			xb = xa+7
 		c=x+y
 		if use_poke then
				pokeline(xa,xb,y,c)
 		else
 			rect(xa,y,xb,y,c)
 		end
		end
	end
	
	rectfill(0,0,48,12,0)
	color(7)
	if use_poke then
		print("using poke")
	else
		print("using rect")
	end
	print("cpu: "..stat(2))
end

