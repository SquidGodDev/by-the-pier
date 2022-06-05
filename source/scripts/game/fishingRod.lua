import "scripts/game/fishingLine"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('FishingRod').extends(gfx.sprite)

function FishingRod:init()
    self.handX = 67
    self.handY = 154
    self.rodLength = 12
    self.endAngle = 290
    self.backArc = pd.geometry.arc.new(0, 0, self.rodLength, 45, self.endAngle, false)
    self.forwardArc = pd.geometry.arc.new(0, 0, self.rodLength, self.endAngle, 70, true)
    self.castBackTime = 700
    self.castForwardTime = 300

    self.drawPadding = 2
    local rodEndX, rodEndY = self.backArc:pointOnArc(0):unpack()
    self.rodEndX = rodEndX
    self.rodEndY = rodEndY

    self:moveTo(self.handX, self.handY)
    self:add()
end

function FishingRod:drawRod()
    local rodImage = gfx.image.new(self.rodLength * 2 + self.drawPadding, self.rodLength * 2 + self.drawPadding)
    gfx.pushContext(rodImage)
        gfx.setLineWidth(2)
        gfx.setLineCapStyle(gfx.kLineCapStyleRound)
        local imageCenter = self.rodLength + self.drawPadding
        gfx.drawLine(imageCenter, imageCenter, self.rodEndX + imageCenter, self.rodEndY + imageCenter)
    gfx.popContext()
    self:setImage(rodImage)
end

function FishingRod:cast()
    if self.rodAnimator then
        return
    end
    self.rodAnimator = gfx.animator.new(self.castBackTime, self.backArc, pd.easingFunctions.outCubic)
    self.castingBack = true
    if self.fishingLine then
        self.fishingLine:remove()
    end
end

function FishingRod:getLineAtAngle(angle, length)
    local x2 = math.ceil(math.cos(math.rad(angle)) * length)
    local y2 = math.ceil(math.sin(math.rad(angle)) * length)
    return x2, y2
end

function FishingRod:update()
    if pd.buttonJustPressed(pd.kButtonA) then
        self:cast()
    end

    if self.rodAnimator then
        local rodEndPoint = self.rodAnimator:currentValue()
        self.rodEndX = rodEndPoint.x
        self.rodEndY = rodEndPoint.y
        if self.rodAnimator:ended() then
            if self.castingBack then
                -- Todo: Scale cast forward time with cast strength
                self.rodAnimator = gfx.animator.new(self.castForwardTime, self.forwardArc, pd.easingFunctions.inCubic)
                self.castingBack = false
            else
                local worldSpaceX = self.handX + self.rodEndX
                local worldSpaceY = self.handY + self.rodEndY
                local castStrength = math.random(2, 9)
                print(castStrength)
                self.fishingLine = FishingLine(worldSpaceX, worldSpaceY, castStrength, 45)
                self.rodAnimator = nil
            end
        end
    end
    self:drawRod()
end