--[[  Global scope variables  ]]--
local WinWidth, WinHeight = love.graphics.getDimensions()

--  Global scope objects
local Ball
local Enemy
local Player

--  This basic object will hold the score info
local Score = {}

function Score.increase()
    Score.score = Score.score + 1
end

function Score.draw()
    love.graphics.setColor({1, 1, 1})
    love.graphics.print( 'Score: ' .. Score.score, WinWidth/2-20, 50)
end

--[[ love.load ]]--
function love.load()
    --  Reset the global score
    Score.score = 0

    --  To create Player and Enemy at same class
    -- we can use the metatable of lua (https://www.lua.org/pil/13.html).
    --  First create a simple table
    local Rect = {}

    --  __index will access the methods shared between
    -- objects, working like inherit (https://www.lua.org/pil/13.4.1.html).
    Rect.__index = Rect

    --  Properties and methods shared between all rects
    Rect.width = 10
    Rect.height = 100

    Rect.move = function(self, y)
        --  Here we will first move the rect
        self.y = self.y + y

        -- then check if still inside the screen
        if
            self.y + self.height >= WinHeight or
            self.y <= 0
        then
            -- and if is off screen the rect go back.
            self.y = self.y - y
        end
    end

    --  Just a monotone draw function
    Rect.draw = function(self, color)
        love.graphics.setColor(color)
        love.graphics.rectangle(
            'fill',
            self.x, self.y,
            self.width, self.height
        )
    end

    --  Here we will pay some extra attention
    Rect.coll = function(self, x, y, callback)
        -- this is a way to put an default value on var
        -- and dont catch an error
        callback = callback or function() end

        --  Then an intersection check that
        -- test if x and y are inside the rect
        if
            x <= self.x + self.width and
            x >= self.x and
            y >= self.y and
            y <= self.y + self.height
        then
            --  This callback function will score
            -- on ball-player collision
            callback()
            
            --  after the collision has been
            -- confirmed then return true
            return true
        end
    end



    --  Initialized the Enemy object
    Enemy = {}

    --  Here we simulate inherit of enemy object as a rect
    setmetatable(Enemy, Rect)

    --  These properties arent shared with anyone
    -- x and y will be the position of enemy on screen
    Enemy.x = WinWidth - 20
    Enemy.y = math.floor(WinHeight/2) - 25



    --  Initialized the Player object
    Player = {}

    --  Here we simulate inherit of player object as a rect too
    setmetatable(Player, Rect)

    --  These properties are the same from enemy but
    -- are inside the player
    Player.x = 10
    Player.y = math.floor(WinHeight/2) - 25

    -- vecY will be the player "velocity"
    Player.vecY = 0

    -- at the update method, the position of player will
    -- be calculated with dt and vecY
    Player.update = function(self, dt)
        self:move(self.vecY * dt)
    end



    --  Ball object initialized
    Ball = {}

    -- same as in player but moves in two dimensions
    Ball.x = math.floor(WinWidth/2)
    Ball.y = math.floor(WinHeight/2)
    Ball.vecX = 250
    Ball.vecY = 50

    --  Here the code gets a little confused
    Ball.update = function(self, dt)
        --  First of all, we need to update
        -- the balls position
        self.x = self.x + self.vecX*dt
        self.y = self.y + self.vecY*dt

        --  Then we check if has collision with
        -- someone and if has collided with
        -- player, the score increase
        if
            Player:coll(self.x, self.y, Score.increase) or
            Enemy:coll(self.x, self.y)
        then
            --  When the ball collides, we need get back
            -- the ball and invert his "velocity" to get
            -- a bounce effect
            self.x = self.x - self.vecX*dt
            self.vecX = self.vecX * -1

            -- and increase the speed of the ball to get harder
            self.vecX = self.vecX*(1+dt)
            self.vecY = self.vecY*(1+dt)
        end

        --  So if the ball didnt collided with anyone
        -- we check if is beyond the limits of screen
        -- first bouncing against the walls
        if
            self.y >= WinHeight - 10 or
            self.y <= 10
        then
            self.y = self.y - self.vecY*dt
            self.vecY = self.vecY * -1 
        end
        
        -- and then verifying if has a game over
        -- here we just quit the game to simplify 
        if
            self.x >= WinWidth - 10 or
            self.x <= 10
        then
            love.load()
        end

        --  This is a way to the enemy 
        -- follow the ball and (probaly) dont lose 
        Enemy:move(self.vecY*dt)

        --  You can activate the samething
        -- to the player, but this will be a cheat
        -- or an I.A. battle...
        --Player:move(self.vecY*dt)

    end
    --  Simple draw function
    Ball.draw = function(self)
        love.graphics.setColor({0.9, 0.4, 0.4})
        love.graphics.circle("line", self.x, self.y, 10)
    end
end

--[[  love.update  ]]--
function love.update(dt)
    Player:update(dt)
    Ball:update(dt)
end

--[[  love.draw  ]]--
function love.draw()
    Score.draw()
    
    Ball:draw()

    Player:draw({0.5, 0.5, 0.6})

    Enemy:draw({0.6, 0.5, 0.5})

    --  Here we render big buttons to separate the
    -- two touch buttons on the screen
    love.graphics.setColor({1,1,1,0.05})

    -- this has x and y at 0, 0 and goes at the
    -- middle of screen width ocuppying full height
    love.graphics.rectangle('fill', 0, 0, WinWidth/2-1, WinHeight)

    -- and this has x at the middle of screen but
    -- goes until the end, symmetric with the other button
    love.graphics.rectangle('fill', WinWidth/2+2, 0, WinWidth/2-1, WinHeight)

    -- these "+2" and "=1" are calculated to get a little gap
    -- between the buttons
end

--[[  Functions that handles the touch  ]]--
function touchpressHandle(id, x, y)
    --  Exactly as in ball collision test
    -- here we check the intersection of touch
    -- on the buttons and then set the player "velocity"
    -- where the negative indicates up and positive down

    --  Left button
    if
        x >= 0 and
        x <= WinWidth/2-1 and
        y >= 0 and
        y <= WinHeight
    then
        --  To Infinity and Beyond
        Player.vecY = -500
    end

    --  Right button
    if
        x >= WinWidth/2+2 and
        x <= WinWidth and
        y >= 0 and
        y <= WinHeight
    then
        --  On the highway to hell
        Player.vecY = 500
    end
end

function touchreleaseHandle()
    --  When the button is released
    -- we need to reset the player "velocity"
    Player.vecY = 0
end

--[[  Mouse will simule the touch on computer  ]]--
love.mousepressed = function(x, y) touchpressHandle(nil, x, y) end

love.mousereleased = touchreleaseHandle

--[[  Love touch events ]]--
love.touchpressed = touchpressHandle

love.mousereleased = touchreleaseHandle

--[[  end :)  ]]--