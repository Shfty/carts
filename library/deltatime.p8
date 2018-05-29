pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- delta time example

--[[
 uses time instead of frames
 to calculate movement speed
	
 try renaming the _update60
 function to _update,
 the drawn line should move at
 the same speed despite
 updating at half rate
 
 this lets you write game logic
 without worrying about
 the target framerate,
 allowing you to freely swap
 between using update and
 update60 without issue
]]

-- global delta time
dt = null

-- line position
x = 0
y = 0

-- line velocity in pixels/sec
vx = 20
vy = 10

function _init()
-- clear screen on start
	cls()
end

function _update60()
	--[[
		calculate and cache dt
		
		can't be done in _init
	 as stat(8) returns 30
	 until the first invocation
	 of _update60
	]]
	if(dt == null) do
		local target_fps = stat(8)
		dt = 1 / target_fps
	end
	
	-- move using cached dt
	x += vx * dt
	y += vy * dt
end

function _draw()
	-- add a pixel to the screen
	pset(x, y, 8)
end
