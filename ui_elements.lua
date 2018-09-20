UiElement = class(function(self,_x,_y,_w,_h,_target,_posx,_posy)
  self.p = {x=_x,y=_y,w=_w,h=_h}
  self.c = {
    {100,100,170,255},
    {100,170,100,255},
    {50,50,50,255}
  }
  self.t = _target
  self.m = _target:GetFilter(_posx,_posy) + 1
  self.d = {x=_posx,y=_posy}
  self.realpos = {x=0,y=0,w=10,h=10}
  self.realposSet = false
	return self
end)

UiElement.Activate = function (self)
  self.m = self.t:SetFilter(self.d.x,self.d.y) + 1
end

UiElement.Render = function (self,x,y)
  if not self.realposSet then
    self.realpos = {x=self.p.x+x,y=self.p.y+y,w=self.p.w,h=self.p.h}
    self.realposSet = true
  end
  love.graphics.setColor(25,25,25,255)
  love.graphics.rectangle("line",self.p.x+x,self.p.y+y,self.p.w,self.p.h)
  love.graphics.setColor(self.c[self.m])
  love.graphics.rectangle("fill",self.p.x+1+x,self.p.y+1+y,self.p.w-2,self.p.h-2)
end

UiElement.MouseCheck = function (self,x,y)
  if CheckXY (x,y,self.realpos.x,self.realpos.y,self.realpos.w,self.realpos.h) then self:Activate() end
end

UiElement.Destroy = function (self)
  self = nil
end
