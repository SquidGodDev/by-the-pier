import "scripts/game/fishingRod"
import "scripts/game/water"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GameScene').extends(gfx.sprite)

function GameScene:init()
    SHOW_CRANK_INDICATOR = false
    self.water = Water()
    self.fishingRod = FishingRod(self.water)
    local backgroundImage = gfx.image.new("images/game/background")
    gfx.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height)
            gfx.setClipRect(x, y, width, height)
            backgroundImage:draw(0, 0)
            gfx.clearClipRect()
        end
    )
    self:add()
end