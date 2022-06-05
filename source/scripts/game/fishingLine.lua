local pd <const> = playdate
local gfx <const> = pd.graphics

class('FishingLine').extends(gfx.sprite)

function FishingLine:init(rodX, rodY, strength, angle)
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
        local crankInput = pd.getCrankTicks(12)
        if crankInput ~= 0 then
            if self.hookX >= self.rodX then
                self.hookX -= 1
            end
        end
    end
    self:drawLine()
end