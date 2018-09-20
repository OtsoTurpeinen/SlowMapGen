ProcessorSmooth = class(function(self,_map,_r)
	self.grid = {}
  self.map = _map
  self.range = 0
  self.current = {x=1,y=1}
	local g = _r*2+_r*_r*2
  self.limit = {i=g+1,o=g-1,min=0,max=(_r*2+1)^2}
  self.weights = 2
  self.filter = {}
  self.filter_update = true
  self.filter_table = {}
  self.started = false
  self.complete = false
	self.ui_set = {}
	self.colors = {}
	self.colors[-1] = {0,0,0,0}
	self.colors[0] = {0,0,255,50}
	self.colors[1] = {255,255,0,150}
  self:SetRange(_r)
	self:SetupUi()
	self.speed = 200
	return self
end)

ProcessorSmooth.SetMap = function (self,_map)
    self.map = _map
end

ProcessorSmooth.Update = function (self,dt)
	if self.started and not self.complete then
	  for i=1,self.speed do if not self.complete then self:ProcessStep() end end
	end
end

ProcessorSmooth.GetRangeTable = function (self)
  if self.filter_update == true then
		self.filter_table = {}
    local _r = self.range
  	for _x=(-_r),_r do
      if self.filter_table[_x+_r+1] == nil then
        self.filter_table[_x+_r+1] = {}
      end
  		for _y=(-_r),_r do
			--	print(_x .. " " .. _y)
        self.filter_table[_x+_r+1][_y+_r+1] = self.filter[_x][_y]
  		end
  	end
    self.filter_update = false
  end
  return self.filter_table
end

ProcessorSmooth.SetRange = function (self,_r)
  if _r < 1 then _r = 1 end
  if _r ~= self.range then
    self.range = _r
  	for _x=(-_r),_r do
      if self.filter[_x] == nil then
        self.filter[_x] = {}
      end
  		for _y=(-_r),_r do
			--	print(_x .. " " .. _y)
        if self.filter[_x][_y] == nil then
          if _x == 0 and _y == 0 then
            self.filter[_x][_y] = 0
          else
            self.filter[_x][_y] = 1
          end
        end
  		end
  	end
    self.filter_update = true
    self:SetMinMax(0,(_r*2+1)^2)
    self.filter_update = true
		self:SetupUi()
		self:CalcLimits()
  end
end

ProcessorSmooth.SetLimitI = function (self,_v)
  self.limit.i = _v
end
ProcessorSmooth.SetLimitO = function (self,_v)
  self.limit.o = _v
end
ProcessorSmooth.SetLimits = function (self,_i,_o)
  self.limit.i = _i
  self.limit.o = _o
end
ProcessorSmooth.SetMinMax = function (self,_i,_o)
  self.limit.min = _i
  self.limit.max = _o
end

ProcessorSmooth.SetFilter = function (self,x,y)
  local _r = self.range
  if _b then
    x = x - _r - 1
    y = y - _r - 1
  end
  self.filter[x][y] = (self.filter[x][y]+1) % self.weights
	self:CalcLimits()
	return self.filter[x][y]
end

ProcessorSmooth.CalcLimits = function (self)
  local _r = self.range
	local _c = 0
  	for _x=(-_r),_r do
  		for _y=(-_r),_r do
        _c = _c + self.filter[_x][_y]
  		end
  	end
    self:SetMinMax(0,_c)
    self:SetLimits(math.floor(_c/2),math.ceil(_c/2))
end

ProcessorSmooth.GetFilter = function (self,x,y)
	if self.filter[x] == nil then return 0 end
		if self.filter[x][y] == nil then return 0 end
	return self.filter[x][y]
end


ProcessorSmooth.FilterNeighbours = function (self,x,y)
	local c = 0
  local r = self.range
	for _x=(-r),r do
		for _y=(-r),r do
				local rx = x+_x
				local ry = y+_y
					while rx > self.map.size.x do rx = rx - self.map.size.x end
					while rx < 1 do rx = rx + self.map.size.x end
					while ry > self.map.size.y do ry = ry - self.map.size.y end
					while ry < 1 do ry = ry + self.map.size.y end
				c = c + self.map:GetNode(rx,ry)*self.filter[_x][_y]
		end
	end
  if c > self.limit.i then
		return 1
	elseif c < self.limit.o then
		return 0
	end
  return self.map:GetNode(x,y)
end

ProcessorSmooth.ProcessStep = function (self)
  if self.current.x > self.map.size.x then
    self.current.x = 1
    self.current.y = self.current.y + 1
  end
  if self.current.y > self.map.size.y then
    self:End()
  end
  if self.grid[self.current.x] == nil then self.grid[self.current.x] = {} end
  self.grid[self.current.x][self.current.y] = self:FilterNeighbours(self.current.x,self.current.y)
  self.current.x = self.current.x + 1
end

ProcessorSmooth.Start = function (self)
  self.started = true
	self.current = {x=1,y=1}
	self.grid = {}
  self.complete = false
	print("started")
--  Q_Queue:Next()
end
ProcessorSmooth.End = function (self,_b)
  if _b == nil then self.map:GhostCollide(self.grid) end
  self.complete = true
	self.current = {x=1,y=1}
	self.grid = {}
--  Q_Queue:Next()
	print("ended")
end

ProcessorSmooth.SetupUi = function (self)
	self:ResetUi()
	self.ui_set = {}
	local _t = self:GetRangeTable()
	for x=1,#_t do
		for y=1,#_t[x] do
			local _s = 15
			local _b = UiElement(x*_s,y*_s,_s,_s,self,x-1-self.range,y-1-self.range)
			table.insert(self.ui_set,_b)
		end
	end
end

ProcessorSmooth.Render = function (self,x,y)
	for k,v in pairs(self.ui_set) do
		v:Render(x,y)
	end
	love.graphics.setColor(255,255,255)
	love.graphics.print(self.limit.i .. " / " .. self.limit.o,x,y)
end

ProcessorSmooth.ResetUi = function (self,x,y)
	for k,v in pairs(self.ui_set) do
		v:Destroy()
	end
end

ProcessorSmooth.GetNode = function (self,x,y)
	while x > self.map.size.x do x = x - self.map.size.x end
	while x < 1 do x = x + self.map.size.x end
	while y > self.map.size.y do y = y - self.map.size.y end
	while y < 1 do y = y + self.map.size.y end
	  if self.grid[x] == nil then
			return -1
		end
	  if self.grid[x][y] == nil then
			return -1
		end
	  return self.grid[x][y]
end

ProcessorSmooth.RenderGhost = function (self)
  for x=1,self.map.size.x do
    for y=1,self.map.size.y do
      love.graphics.setColor(self.colors[self:GetNode(x,y)])
      love.graphics.rectangle("fill",x*10,y*10,10,10,2)
    end
  end
end
ProcessorSmooth.MouseCheck = function (self,x,y)
	for k,v in pairs(self.ui_set) do
		v:MouseCheck(x,y)
	end
end
ProcessorSmooth.Destroy = function (self)
  self = nil
end
