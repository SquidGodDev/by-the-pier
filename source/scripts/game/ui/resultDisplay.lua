local pd <const> = playdate
local gfx <const> = pd.graphics

class('ResultDisplay').extends(gfx.sprite)

function ResultDisplay:init()
    local notebookImage = gfx.image.new("images/game/notebook")
    self:setImage(notebookImage)
    self.animateTime = 1000
    self.animateIn = gfx.animator.new(self.animateTime, -120, 120, pd.easingFunctions.inOutCubic)
    self.animateOut = nil

    self:moveTo(200, -120)
    self:add()
end

function ResultDisplay:update()
    if self.animateIn then
        self:moveTo(self.x, self.animateIn:currentValue())
        if self.animateIn:ended() then
            self.animateIn = nil
        end
    elseif self.animateOut then
        self:moveTo(self.x, self.animateOut:currentValue())
        if self.animateOut:ended() then
            self.animateOut = nil
            self:remove()
        end
    else

    end
end