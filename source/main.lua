import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"

import "scripts/sceneManager"
import "scripts/game/gameScene"
import "scripts/title/titleScene"

local pd <const> = playdate
local gfx <const> = pd.graphics

math.randomseed(pd.getSecondsSinceEpoch())

SceneManager = SceneManager()
TitleScene()

function pd.update()
    SceneManager:update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    pd.drawFPS(10, 10)
end
