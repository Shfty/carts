require("input")

--controller
--wrapper for keyboard input
-------------------------------
kb = {
	kp=nil,
	kc=nil
}

function kb:update()
	self.kp=stat(30)
	self.kc=stat(31)
end

function kb:keyp(char)
	return self.kp and self.kc == char
end
