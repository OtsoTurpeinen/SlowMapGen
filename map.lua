GameMap = class(function(self)
	self.grid = {}
	self.fillpercentage = 0.5
  self.phase = 0
  self.current = {x=1,y=1}
  self.size = {x=70,y=70}
  self.colors = {}
  self.colors[0] = {0,0,0,255}
  self.colors[1] = {255,127,0,255}
	self.change = 0
	self.speed = 30
	return self
end)

GameMap.FillNode = function (self,x,y)
	local _n = math.random()
	if self.grid == nil then
		self.grid = {}
	end
	if self.grid[x] == nil then
		self.grid[x] = {}
	end
	if _n < self.fillpercentage then
		self.grid[x][y] = 1
	else
		self.grid[x][y] = 0
	end
end

GameMap.GetNode = function (self,x,y,b)
  if self.grid[x] == nil then
			return 0
	end
  if self.grid[x][y] == nil then
		return 0
	end
  return self.grid[x][y]
end

GameMap.IsDone = function (self)
  return (self.phase == -1)
end

GameMap.Render = function (self)
  for x=1,self.size.x do
    for y=1,self.size.y do
      love.graphics.setColor(self.colors[self:GetNode(x,y)])
      love.graphics.rectangle("fill",x*10,y*10,10,10,2)
    end
  end
	love.graphics.setColor(255,0,0,255)
	love.graphics.print(self.change,10,10)
	love.graphics.setColor(0,0,0,255)
	love.graphics.print(self.change,11,11)
end

GameMap.Update = function (self,dt)
	if self.phase == -1 then return end
  for i=1,self.speed do self:DoPhase() end
end

GameMap.DoPhase = function (self)
  if self.phase == 0 then
    self:GenMap()
  end
end

GameMap.GenMap = function (self)
  if self.current.x > self.size.x then
    self.current.x = 1
    self.current.y = self.current.y + 1
  end
  if self.current.y > self.size.y then
    self.phase = -1
    return
  end
	self:FillNode(self.current.x,self.current.y)

  self.current.x = self.current.x + 1
end

GameMap.GhostCollide = function (self,_map)
	for x = 1,self.size.x do
		for y = 1,self.size.y do
			self.grid[x][y] = _map[x][y]
		end
	end
end

GameMap.Destroy = function (self)
	self = nil
end
