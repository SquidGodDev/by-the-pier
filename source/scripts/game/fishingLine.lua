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
    self.xVelocity = math.cos(math.rad(angle)) * strength
    self.yVelocity = -math.sin(math.rad(angle)) * strength
    self.casting = true

    self.reelSpeed = 3
    self.reelingUp = false

    self:setCenter(0, 0)
    self:moveTo(0, 0)
    self:add()
end

function FishingLine:drawLine()
    local lineImage = gfx.image.new(400, 240)
    gfx.pushContext(lineImage)
        gfx.drawLine(self.rodX, self.rodY, self.hookX, self.hookY)
    gfx.popContext()
    self:setImage(lineImage)
end

function FishingLine:reelUp()
    self.hookX = self.rodX
    self.reelingUp = true
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
        end
    else
        if self.reelingUp then
            self.hookY -= 3
            if self.hookY <= self.rodY then
                self.hookY = self.rodY
                self.fishingRod:reeledIn()
            end
        else
            -- Adjust crank ticks based on difficulty of fish?
            -- Increase hookX to simulate fish pulling
            local crankInput = pd.getCrankTicks(18)
            if crankInput ~= 0 then
                if self.hookX > self.rodX then
                    self.hookX -= self.reelSpeed
                else
                    self:reelUp()
                end
            end
        end
    end
    self:drawLine()
end