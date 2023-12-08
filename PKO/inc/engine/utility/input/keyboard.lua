require("devkit_input")

--keyboard
--wrapper for keyboard input
-------------------------------
kb = {
	name="keyboard",
	kp=nil
}

function kb:pre_update()
	self.kp = {}
	while stat(30) do
		add(self.kp, stat(31))
	end
end

function kb:keyp(char)
	for k in all(self.kp) do
		if(k == char) return true
	end
	return false
end

engine:add_module(kb)
