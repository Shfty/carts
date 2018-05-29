pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- globals

use_poke = false

-->8
-- pokeline

p_screen = 0x6000
rec16 = 1/16

--[[
	draws a horizontal line
	by poking values into
	screen memory
	
	doesn't supprt draw state
	calls such as pal and clip,
	but is roughly 7.5x as fast
]]

function pokeline(xa,xb,y,c)
	--[[
		calculate memory-space
		line coordinates
	]]
	local lxa = flr(xa*0.5)
	local lxb = flr(xb*0.5)
	local ly = (y*64)
	
	--[[
	 step along each memory cell
	 of our line
	]]
	for i=lxa,lxb do
		--[[
			calculate this cell's
			memory address
		]]
		local p_pix = p_screen+i+ly
		
		-- 
		local lb = i==lxa and xa%2==1
		local rb = i==lxb and xb%2==0
		
		local lc = 0
		
		if lb and not rb then
			lp = peek(p_pix)
			lp %= 16
			lc = lp+(c*16)
		end
		
		if not lb and not rb then	
			lc = c%16+c*16
		end
		
		if not lb and rb then
			rp = peek(p_pix)
			rp *= rec16
			lc = (c%16)+rp
		end

		poke(p_pix,lc)
	end
end

-->8
-- main

use_poke = false

sx = 0

function _update60()
	if(btnp(0)) then sx -= 1 end
	if(btnp(1)) then sx += 1 end

	if(btnp(4)) then
		use_poke = not use_poke
	end
end

function _draw()
	cls()
	
	--[[
	for y=0,127 do
		for x=0,15 do
			xa = x*8
			xa += sx
			xb = xa+7
 		c=x+y
 		if use_poke then
				pokeline(xa,xb,y,c)
 		else
 			rect(xa,y,xb,y,c)
 		end
		end
	end
	]]
	
	for x=0,127 do
		for y=0,127 do
			if use_poke then
   	local lx = flr(x*0.5)
   	local ly = (y*64)
   	
   	local col = x+y
   	local c = shl(col)+col
 			
 			poke(p_screen+lx+ly,c)
			else
				rect(x,y,x,y,x+y)
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
	print("cpu: "..stat(1))
	print("fps: "..stat(7))
end

