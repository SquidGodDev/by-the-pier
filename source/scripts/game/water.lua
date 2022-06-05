local pd <const> = playdate
local gfx <const> = pd.graphics

class('Water').extends(gfx.sprite)

function Water:init()
    local waterImage = gfx.image.new("images/game/water")
    self:setImage(waterImage)
    self:setZIndex(100)
    self:setCenter(0, 0)
    self:moveTo(0, 0)
    self:add()
end