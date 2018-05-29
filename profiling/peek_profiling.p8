pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
p_udata = 0x4300
arr = {}
str = ""
use_peek = false

function _init()
 for i = 0,6912 do
 	add(arr,i)
 end
 
 for i = 0,#arr do
 	poke(p_udata+i,arr[1+i])
 end
end

function _update60()
	if(btnp(4)) then
		use_peek = not use_peek
	end

 str = ""
	for i = 0,#arr-1 do
		if use_peek then
			str=str..peek(p_udata+i)..","
		else
			str=str..tostr(arr[1+i])..","
		end
	end
end

function _draw()
	cls()
	color(7)
	if use_peek then
		print("using peek")
	else
		print("using table access")
	end
	print("string: "..str)
	print("cpu: "..stat(2))
end
