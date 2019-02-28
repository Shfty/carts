--move
--object for moving a parent
-------------------------------
move=obj:subclass({
	name="move",
	dp=vec2:new()
})

function move:update()
	self.parent.pos += self.dp
	self.dp=vec2:new()
end

require("move/proj_move")
require("move/octo_move")
