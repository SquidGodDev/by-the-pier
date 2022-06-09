import "scripts/game/fishManager"
import "scripts/game/ui/catchTimer"
import "scripts/game/ui/tensionBar"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('FishingLine').extends(gfx.sprite)

function FishingLine:init(fishingRod, rodX, rodY, strength, angle)
    self.fishingRod = fishingRod
    self.waterLevel = 198
    self.strength = strength
    self.rodX = rodX
    self.rodY = rodY
    self.hookX = rodX
    self.hookY = rodY
    self.lastX = -1
    self.lastY = -1
    self.xVelocity = math.cos(math.rad(angle)) * strength
    self.yVelocity = -math.sin(math.rad(angle)) * strength
    self.casting = true

    self.reelSpeed = 3
    self.reelingUp = false
    self.reelUpSpeed = 3

    self.fishCaught = false

    self.topYOffset = 50
    self.bottomYOffset = 30

    self:setCenter(0, 0)
    self:moveTo(self.rodX, self.topYOffset)
    self:add()
end

function FishingLine:drawLine()
    if self.lastX ~= self.hookX or self.lastY ~= self.hookY then
        self.lastX = self.hookX
        self.lastY = self.hookY
        local lineHeight = math.abs(self.rodY - self.hookY)
        local lineWidth = self.hookX - self.rodX
        local lineImage
        if lineHeight <= 1 or lineWidth <= 1 then
            self:moveTo(self.rodX, self.topYOffset)
            lineImage = gfx.image.new(400 - self.rodX, 240 - self.topYOffset - self.bottomYOffset)
            gfx.pushContext(lineImage)
                gfx.drawLine(self.rodX - self.rodX, self.rodY - self.topYOffset, self.hookX - self.rodX, self.hookY - self.topYOffset)
            gfx.popContext()
        elseif self.hookY > self.rodY then
            self:moveTo(self.rodX, self.rodY)
            lineImage = gfx.image.new(lineWidth, lineHeight)
            gfx.pushContext(lineImage)
                gfx.drawLine(0, 0, lineWidth, self.hookY - self.rodY)
            gfx.popContext()
        else
            self:moveTo(self.rodX, self.hookY)
            lineImage = gfx.image.new(lineWidth, lineHeight)
            gfx.pushContext(lineImage)
                gfx.drawLine(0, lineHeight, lineWidth, 0)
            gfx.popContext()
        end
        self:setImage(lineImage)
    end
end

function FishingLine:reelUp()
    self.hookX = self.rodX
    self.reelingUp = true
end

function FishingLine:reeledIn()
    self.fishingRod:reeledIn()
    if self.catchTimer then
        self.catchTimer:endTimer()
    end
    if self.tensionBar then
        self.tensionBar:stopTensionBar()
    end
end

function FishingLine:update()
    if self.casting then
        self.yVelocity += 9.8/30
        self.hookX += self.xVelocity
        self.hookY += self.yVelocity
        if self.hookY >= self.waterLevel then
            self.hookY = self.waterLevel
            self.xVelocity = 0
            self.yVelocity = 0
            self.casting = false
            self.fishingRod.water:impulse(self.hookX)
            self.fishManager = FishManager(self.rodX - self.hookX)
        end
    else
        if self.reelingUp then
            self.hookY -= self.reelUpSpeed
            if self.hookY <= self.rodY then
                self.hookY = self.rodY
                -- TODO: Pass in fish argument
                self:reeledIn()
            end
        else
            if self.fishHooked then
                self.hookX += self.fishManager:getPullStrength()
                if self.hookX >= 400 then
                    self.hookX = 400
                end
            else
                if self.fishManager:isHooked() then
                    self.fishHooked = true
                    self.fishingRod.water:impulse(self.hookX)
                    self.catchTimer = CatchTimer(350, self)
                    self.tensionBar = TensionBar(0, 1, self)
                end
            end
            -- Adjust crank ticks based on difficulty of fish?
            -- Increase hookX to simulate fish pulling
            local crankInput = pd.getCrankTicks(18)
            if crankInput ~= 0 then
                if not self.fishHooked then
                    self.fishManager:resetTime()
                end
                if self.hookX > self.rodX + 3 then
                    self.hookX -= self.reelSpeed
                    if self.tensionBar then
                        self.tensionBar:increaseTension()
                    end
                else
                    if self.catchTimer then
                        self.catchTimer:endTimer()
                    end
                    if self.tensionBar then
                        self.tensionBar:stopTensionBar()
                    end
                    self:reelUp()
                end
            end
        end
    end
    self:drawLine()
end