pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- perfhud

enable_profiling = true

t_prof = {}

function draw_perfhud()
	clip()

	local h = 0
 for k,v in pairs(t_prof) do
 	h += 6
 end
	
 rect(1,1,96,h+15,6)
 rectfill(2,2,95,h+14,0)
 
 color(7)
 cursor(3,3)
 
	if enable_profiling then
  for k,v in pairs(t_prof) do
  	local cpu = v.cpu*100
 	 print(k..": "..cpu.."%")
  end
  
  t_prof = {}
 end
 
 local cpu = stat(1)*100
 print("cpu "..cpu)
 print("fps "..stat(7))
end

function pr_start(name)
	if enable_profiling then
 	if t_prof[name] == nil then
 		t_prof[name] = {
 			start = 0,
 			cpu = 0
 		}
 	end
 	t_prof[name].start = stat(1)
	end
end

function pr_end(name)
	if enable_profiling then
		t_prof[name].cpu += stat(1) - t_prof[name].start
	end
end
