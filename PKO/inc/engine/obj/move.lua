--move
--object for moving a parent
-------------------------------
move=obj:subclass({
	name="move",
	dp=vec2:new(),
	geo=nil
})

function move:update()
	self.parent.pos += self.dp
	self.dp=vec2:new()
	
	if(self.geo) then
		cr = col:isect(
			self.parent:getpos(),
			self.geo,
			pko_game.test:getpos(),
			pko_game.test.geo
		)

		if cr then
			self:collision(cr)
		end
	end
end

function move:collision(r)
	self.parent.pos += r.n * r.pd
end

require("move/proj_move")
require("move/octo_move")
