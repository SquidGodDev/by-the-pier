local pd <const> = playdate
local gfx <const> = pd.graphics

class('Cloud').extends(gfx.sprite)

function Cloud:init(movingRight, x, y, cloudImage)
    self.movingRight = movingRight
    self.moveSpeed = 1

    self:setImage(cloudImage)
    self:moveTo(x, y)
    self:add()
end

function Cloud:update()
    if self.movingRight then
        self:moveBy(self.moveSpeed, 0)
        if self.x > 440 then
            self:remove()
        end
    else
        self:moveBy(-self.moveSpeed, 0)
        if self.x < -40 then
            self:remove()
        end
    end
end