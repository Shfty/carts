pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- readsprite

function rspr(x,y)
	local pix = {}

	local start = (y*16*4)+(x*4)

	for i=start,start+15 do
	 local bc = peek(i)
		local b1 = flr(bc % 16)
		local b2 = flr(bc / 16)
		add(pix, b1)
		add(pix, b2)
	end
	
	return pix
end

-->8
-- scaling

rec = 1/128

function scale_linear(y)
	return 2*(y-64)*rec
end

function scale_sine(y)
 local ly = y*rec
 ly -= 0.5
 ly = sin(ly*0.5)
 ly *= ly
 ly = max(ly, 0.125)
	return ly
end
-->8
-- uvs

function uv_linear(y)
 return flr((scrolly+y)/2)%8
end

-->8
-- palettescroll

draw_pal = true

function scanline(y,f_sc,f_uv)
 local y = y or 0
 local f_sc = f_sc or scale_linear
 local f_uv = f_uv or uv_linear
 
 local scale = f_sc(y)
 if scale > 0 then
  local step = 8*scale
  
  local lb = 64*scale
  local la = -lb
  
  local la += 64+(scrollx*scale)
  local lb += 64+(scrollx*scale)
  
  local pix = rspr(1,f_uv(y))
  local i = 0
  
  for x=la,lb-1,step do
   i += 1
   local le = x+step
   
   if(x<128 and le>=0) then
   	local c = 0
   	if draw_pal then
   		c = i-1
   	else
   		c = pix[i]
   	end
   	
   	line(x+0.5,y,le-0.5,y,c)
   end
  end
	end
end

-->8
-- main

scrollx = 0
scrolly = 0

function _update60()
	if btn(0) then
	 scrollx += 1
	end
	
	if btn(1) then
		scrollx -= 1
	end
	
	if btnp(4) then
		draw_pal = not draw_pal
	end
	
	scrolly = scrolly - 0.5
end

function _draw()
 cls(5)
 
 for y=0,127 do
  scanline(y,scale_sine)
 end
end

__gfx__
00000000b7b7b7b74444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000003b3b3b3b4999999400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700b3b3b3b349a99a9400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700094949494499aa99400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700049494949499aa99400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007009494949449a99a9400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000292929294999999400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000424242424444444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
