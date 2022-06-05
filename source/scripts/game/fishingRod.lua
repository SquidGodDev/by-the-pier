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
    self.forwardArc = pd.geometry.arc.new(0, 0, self.rodLength, self.endAngle, 50, true)
    self.castBackTime = 400
    self.castForwardTime = 500
    self.castingBack = true

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
    if not self.castingBack then
        return
    end
    self.rodAnimator = gfx.animator.new(self.castForwardTime, self.forwardArc, pd.easingFunctions.inCubic)
    self.castingBack = false
end

function FishingRod:castBack()
    if self.fishingLine or self.rodAnimator then
        return
    end
    self.rodAnimator = gfx.animator.new(self.castBackTime, self.backArc, pd.easingFunctions.outCubic)
end

function FishingRod:reeledIn()
    if self.fishingLine then
        self.fishingLine:remove()
        self.fishingLine = nil
        self.castingBack = true
    end
end

function FishingRod:update()
    if pd.buttonJustPressed(pd.kButtonA) then
        self:castBack()
    elseif pd.buttonJustReleased(pd.kButtonA) then
        self:cast()
    end

    if self.rodAnimator then
        local rodEndPoint = self.rodAnimator:currentValue()
        self.rodEndX = rodEndPoint.x
        self.rodEndY = rodEndPoint.y
        if self.rodAnimator:ended() then
            if not self.castingBack then
                -- Todo: Scale cast forward time with cast strength
                local worldSpaceX = self.handX + self.rodEndX
                local worldSpaceY = self.handY + self.rodEndY
                local castStrength = math.random(2, 9)
                self.fishingLine = FishingLine(self, worldSpaceX, worldSpaceY, castStrength, 45)
                self.rodAnimator = nil
            end
        end
    end
    self:drawRod()
end