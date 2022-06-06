import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "scripts/game/fishingRod"
import "scripts/game/water"

local pd <const> = playdate
local gfx <const> = pd.graphics

local accelTextSprite = gfx.sprite.new()

local function initialize()
    math.randomseed(pd.getSecondsSinceEpoch())
    -- accelTextSprite:add()
    -- accelTextSprite:moveTo(150, 120)
    Water()
    FishingRod()
    local backgroundImage = gfx.image.new("images/game/background")
    gfx.sprite.setBackgroundDrawingCallback(
        function(x, y, width, height)
            gfx.setClipRect(x, y, width, height)
            backgroundImage:draw(0, 0)
            gfx.clearClipRect()
        end
    )
end

initialize()

function pd.update()
    -- Calculate cast distance by using rolling average speed at button release time
    -- Get rolling average speed by adding up last ~10 frames and dividing by 10. If
    -- button hasn't been held down for at least ~10 frames, either use some default low
    -- cast (probably not minimum), or use add and divide but apply some penalty. What to
    -- add is the delta between current Z accelerometer values and last value
    -- local x, y, z = pd.readAccelerometer()
    -- local accelTextImage = gfx.image.new(200, 200)
    -- gfx.pushContext(accelTextImage)
    --     gfx.drawText("X: ".. math.floor(x*100)/100, 0, 0)
    --     gfx.drawText("Y: ".. math.floor(y*100)/100, 0, 20)
    --     gfx.drawText("Z: ".. math.floor(z*100)/100, 0, 40)
    -- gfx.popContext()
    -- accelTextSprite:setImage(accelTextImage)

    gfx.sprite.update()
    pd.timer.updateTimers()
end
