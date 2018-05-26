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
