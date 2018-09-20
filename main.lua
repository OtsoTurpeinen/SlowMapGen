require "class"
require "map"
require "ui_elements"
require "processors"


function love.load()
--local _, _, flags = love.window.getMode()
--local width, height = love.window.getDesktopDimensions( flags.display )
--local success = love.window.setMode( width, height, flags )
--love.window.setPosition( 0, 0, flags.display )
--G_WW = width
--G_WH = height
G_RANGE = 1
G_QUEUE = {}
G_UI_Mouse = -1
ResetMap ()
end

function love.update (dt)
	G_MAP:Update(dt)
	G_QUEUE[1]:Update(dt)
end

function love.draw()
	G_MAP:Render()
	G_QUEUE[1]:RenderGhost()
	RenderQue()
end

function love.keypressed (sKey, scanCode, bRepeat)
	if sKey == "escape" then
		love.event.quit()
	elseif sKey == "return" then
		G_QUEUE[1]:End(true)
		ResetMap()
	elseif sKey == "space" then
		G_QUEUE[1]:SetMap(G_MAP)
		G_QUEUE[1]:Start()
	elseif sKey == "up" then
		G_RANGE = G_RANGE + 1
		print("range set to " .. G_RANGE)
		G_QUEUE[1]:SetRange(G_RANGE)
	elseif sKey == "down" then
		if G_RANGE > 1 then
			G_RANGE = G_RANGE - 1
			G_QUEUE[1]:SetRange(G_RANGE)
			print("range set to " .. G_RANGE)
		end
	end
end

function ResetMap ()
	local s = os.time()
	math.randomseed( s )
	local _s = 0
	for i=1,8 do _s = _s .. math.random(0,99) end
	math.randomseed( tonumber(_s) )
	print("map reset with seed: " .. _s)
	for i=1,8 do math.random() end
	if G_MAP ~= nil then
		G_MAP:Destroy()
	end
	G_MAP = GameMap()
	if G_QUEUE[1] == nil then G_QUEUE[1] = ProcessorSmooth(G_MAP,G_RANGE) end
end

function love.mousepressed( x, y, button, istouch )
	for k,v in pairs(G_QUEUE) do
		v:MouseCheck(x,y)
	end
end

function RenderQue ()
	love.graphics.setColor(0,0,120,255)
	love.graphics.rectangle("fill",720,5,195,710)
	for k,v in pairs(G_QUEUE) do
		v:Render(720,5+(k-1)*100)
	end
end

function CheckXY (_x,_y,rx,ry,rw,rh)
	if _x > rx and _x < rx + rw and
	   _y > ry and _y < ry + rh then
	   return true
	end
	return false
end
