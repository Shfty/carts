--keyboard
-------------------------------
kp=nil
kc=nil

function update_kb()
	kp=stat(30)
	kc=stat(31)
end

function keyp(char)
	return kp and kc == char
end
