import "scripts/game/fishingRod"
import "scripts/game/water"
import "scripts/game/cloudSpawner"

local pd <const> = playdate
local gfx <const> = pd.graphics

class('GameScene').extends(gfx.sprite)

function GameScene:init()
    SHOW_CRANK_INDICATOR = false
    self.water = Water()
    self.fishingRod = FishingRod(self.water)
    self.cloudSpawner = CloudSpawner()
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