import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/crank"
import "CoreLibs/ui"
import "CoreLibs/nineslice"

import "scripts/sceneManager"
import "scripts/game/gameScene"
import "scripts/title/titleScene"
import "scripts/instructions/instructionsScene"
import "scripts/directory/directoryScene"

local pd <const> = playdate
local gfx <const> = pd.graphics

math.randomseed(pd.getSecondsSinceEpoch())

CAUGHT_FISH = {}

SceneManager = SceneManager()
TitleScene()

SHOW_CRANK_INDICATOR = false
pd.ui.crankIndicator:start()

local menu = pd.getSystemMenu()
menu:addMenuItem("How to Play", function()
    SceneManager:switchScene(InstructionsScene)
end)

menu:addMenuItem("Fishing Log", function()
    SceneManager:switchScene(DirectoryScene)
end)

function pd.update()
    SceneManager:update()
    gfx.sprite.update()
    pd.timer.updateTimers()
    pd.drawFPS(10, 10)

    if pd.isCrankDocked() and SHOW_CRANK_INDICATOR then
        pd.ui.crankIndicator:update()
    end
end
