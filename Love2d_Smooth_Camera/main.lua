io.stdout:setvbuf('no')
local screenWidth = love.graphics.getWidth()
local screenHeight = love.graphics.getHeight()

local scaleX = 1.0
local scaleY = 1.0
local screenWidthByScale = (screenWidth/ 2) / scaleX
local screenHeightByScale = (screenHeight / 2) / scaleY

local cameraTarget = {}
cameraTarget["x"] = screenWidth / 2
cameraTarget.y = screenHeight / 2
cameraTarget.color = {0,1,0}

local world = {}
world.x = 0
world.y = 0
world.width = 1000
world.height = 600
world.cell = 100

local player = {}
player.width = 20
player.height = 40
local playerIntiPosX = (screenWidth / 2) - (player.width / 2)
local playerIntiPosY = (screenHeight / 2) - (player.height / 2)
player.x = playerIntiPosX
player.y = playerIntiPosY
player.color = {0.7,0.2,0.2}
player.speed = 120
player.maxSpeed = player.speed * 1.5
player.vx = 0
player.vy = 0

local oldPlayerSpeedX = 0
local oldPlayerSpeedY = 0

local frictionMax = 1
--frictionPower must be less than frictionMax
local frictionPower = 0.8 -- higher = less friction

local frictionBrakeControls = player.speed / 20

function lerp(value1,value2,parameter) return (1-parameter) * value1 + parameter * value2 end

--define world to camera offset at load
world.offsetX = cameraTarget.x - world.x
world.offsetY = cameraTarget.y - world.y



local isDown = love.keyboard.isDown

function love.update(dt)
  
  --check intial player velocity
  oldPlayerSpeedX = player.vx
  oldPlayerSpeedY = player.vy
  
    --player controls and friction fix
  if isDown "w" then --up
    player.vy = player.vy - (player.speed * dt)
    --break when opposite speed is high
    if player.vy > frictionBrakeControls then
      player.vy = oldPlayerSpeedY * (frictionPower / frictionMax)
    end
  end
  if isDown "s" then --down
    player.vy = player.vy + (player.speed * dt)
    --break when opposite speed is high
    if player.vy < - frictionBrakeControls then
      player.vy = oldPlayerSpeedY * (frictionPower / frictionMax)
    end
  end
  if isDown "a" then --left
    player.vx = player.vx - (player.speed * dt)
    --break when opposite speed is high
    if player.vx > frictionBrakeControls then
      player.vx = oldPlayerSpeedX * (frictionPower / frictionMax)
    end
  end
  if isDown "d" then --right
    player.vx = player.vx + (player.speed * dt)
    --break when opposite speed is high
    if player.vx < - frictionBrakeControls then
      player.vx = oldPlayerSpeedX * (frictionPower / frictionMax)
    end
  end
  
  --friction break if not pressing keys
  if not isDown ("a" , "d") then
    player.vx = oldPlayerSpeedX * (frictionPower / frictionMax)
  end
  if not isDown ("w" , "s") then
    player.vy = oldPlayerSpeedY * (frictionPower / frictionMax)
  end
  
  --limit player speed to stop infinite acceleration also limit diagonal speed too
  if player.vx > player.maxSpeed then
    player.vx = player.maxSpeed
  end
  if player.vy > player.maxSpeed then
    player.vy = player.maxSpeed
  end
  --negative velocity break
  if player.vx < - player.maxSpeed then
    player.vx = - player.maxSpeed
  end
  if player.vy < - player.maxSpeed then
    player.vy = - player.maxSpeed
  end
  
  --update player velocity
  player.x = player.x + (player.vx * dt)
  player.y = player.y + (player.vy * dt)  
  
  -- interpolate between camera and player
local lerpPowerX = 0.2
local lerpPowerY = 0.3

cameraTarget.x = lerp(cameraTarget.x, player.x + (player.width / 2) , lerpPowerX)
cameraTarget.y = lerp(cameraTarget.y, player.y + (player.height / 2), lerpPowerY)

world.x = - cameraTarget.x + world.offsetX
world.y = - cameraTarget.y + world.offsetY
  
end

local cameraLineWidth = 100
local cameraLineHeight = 80

function love.draw()
  
  love.graphics.push() --zoom scale after push
    --zoom draw Update
    love.graphics.scale(scaleX, scaleY)
    screenWidthByScale = (screenWidth/ 2) / scaleX
    screenHeightByScale = (screenHeight / 2) / scaleY
    love.graphics.translate( - world.offsetX + screenWidthByScale, - world.offsetY + screenHeightByScale)
    
  --draw world
    for yLines = 0, world.height, world.cell do
      love.graphics.line(0 + world.x, yLines + world.y, world.width + world.x, yLines + world.y)
      for xLines = 0, world.width, world.cell do
        love.graphics.line(xLines + world.x, 0 + world.y, xLines + world.x, world.height + world.y)
      end
    end
    
    --draw player
    love.graphics.setColor(player.color)
    -- add player to world
    love.graphics.rectangle("fill", player.x + world.x, player.y + world.y , player.width, player.height)
    love.graphics.setColor(1,1,1)
    
    --draw camera target
    love.graphics.setColor(cameraTarget.color)
    --add camera to world
    
    love.graphics.line(cameraTarget.x - cameraLineWidth + world.x, cameraTarget.y + world.y, cameraTarget.x + cameraLineWidth + world.x, cameraTarget.y + world.y)
    love.graphics.line(cameraTarget.x + world.x, cameraTarget.y - cameraLineHeight + world.y, cameraTarget.x + world.x, cameraTarget.y + cameraLineHeight + world.y)
    love.graphics.setColor(1,1,1)
    
  love.graphics.pop()
    --draw debugPlayer velocity
  love.graphics.print("vx = " .. math.floor(player.vx), 5, 50)
  love.graphics.print("vy = " .. math.floor(player.vy), 5, 70)
  love.graphics.print("press a = move left \npress d = right \npress w = up \npress s = down", 5, 100)
end

function love.wheelmoved(x, y)
  if y > 0 then --wheelMouseUp
    scaleX = scaleX * 1.101  --odd float number to prevent by zero division (multiply scale, not add to)
    scaleY = scaleY * 1.101
  elseif y < 0 then --wheelMouseDown
    scaleX = scaleX * 0.901 --odd float number to prevent by zero division
    scaleY = scaleY * 0.901
  end
end
