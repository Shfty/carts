--object
--basic scene graph unit
-------------------------------
obj_count=0

obj={
	name="object",
	parent=nil,
	children=nil,
	_wants_init=true
}

function obj:extend(t)
	self.__index=self
	return setmetatable(
		t or {},
		self
	)
end

function obj:new(p,t)
	local o = self:extend(t)

	p=p or nil	
	if(p != nil) p:addchild(o)
	o:init()
	
	return o
end

-- get the class default object
-- a.k.a. metatable
function obj:cdo()
	return getmetatable(self)
end

function obj:is_a(t)
	local c = self:cdo()
	while c do
		if(c == t) return true
		c = c:cdo()
	end

	return false
end

function obj:init()
	obj_count+=1
	self.children = {}
	self._wants_init = false
end

function obj:update()
	for c in all(self.children) do
		c:update()
	end
end

function obj:draw()
	for c in all(self.children) do
		c:draw()
	end
end

function obj:addchild(c)
	if(c.parent != nil) then
		c.parent:remchild(c)
	end
	
	add(self.children,c)
	c.parent=self
	
	return c
end

function obj:remchild(c)
	c.parent = nil
	del(self.children,c)
end

function obj:__tostr()
	return self.name
end

function obj.__concat(lhs, rhs)
	return tostr(lhs)..tostr(rhs)
end

function obj:print(pf)
	pf=pf or ""
	local str = pf
	str=str..self:__tostr()
	str=str.."\n"
	
	for c in all(self.children) do
		str = str..c:print(pf.." ")
	end
	
	return str
end

function obj:detach()
	if(self.parent) then
		self.parent:remchild(self)
		self.parent=nil
	end
end

function obj:destroy()
	self:detach()
	
	if(#self.children>0) then
 	while #self.children>0 do
 		self.children[1]:destroy()
 	end
	end
	
	obj_count-=1
end
