pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- perfhud

function draw_perfhud()
	clip()

	local comp_cpu = comp_cpu or 0
 rect(1,1,64,23,6)
 rectfill(2,2,63,22,0)
 
 color(7)
 
 local cpu = stat(1)*100
 local comp_cpu = cpu - 1.6998
 
 local fps = stat(7)
 
 print("cpu  "..cpu.."%",3,3)
 print("    ("..comp_cpu.."%)",3,10)
 print("fps "..fps,3,17)
end
-->8
method = 0

function _update60()
	if btnp(4) then
		method += 1
		method %= 3
	end
end

function _draw()
	cls()
	
	if method == 0 then
		sspr(8,0,8,8,64,64,8,8)
	end
	
	if method == 1 then
 	for i = 0,7 do
 		sspr(8,i,8,1,64,64+i,8,1)
 	end
	end
	
	if method == 2 then
 	for y=0,7 do
 		for x=0,7 do
 			sspr(8+x,y,1,1,64+x,64+y,1,1)
 		end
 	end
	end
	
	draw_perfhud()
	print(method,0,64)
end
__gfx__
00000000012345670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000123456780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700234567890000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770003456789a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000456789ab0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070056789abc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000006789abcd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000789abcde0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
