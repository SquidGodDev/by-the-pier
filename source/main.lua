--[[
Hey Giant Squid patrons! As promised, I've went ahead and added comments to my code. I went pretty in
depth explaining my game architecture in my last game's source code, Escape from Complex 32, so I'm going
to just point out the key things I think are sufficiently different and interesting in this codebase. Here
is the file structure of my code, and I've highlighted the files I've left meaningful comments in.

I want to note that the timeline for this game/video was a little rushed because of my collab with Goodgis,
so the codebase is kind of messy, especially surrounding the fishingLine.lua/fishingRod.lua code. Not my best
work, but it works, and I'm not touching this code again 😎

scripts/
    directory/
        directoryScene.lua - This is the scene that handles the fishing log. It uses the gridview UI component (I made a video on it)
    game/
        ui/
            catchTimer.lua - This is the bar that pops up that shows you how long you have to catch the fish
            resultDisplay.lua - This is the notebook that comes down and shows you what fish you caught
            tensionBar.lua - This is the bar that shows what tension the fishing line is at
        cloud.lua - Handles a single cloud moving and removing itself after it goes off screen
        cloudSpawner.lua - Handles spawning the clouds
        fishingLine.lua (COMMENTED) - Handles drawing the fishing line and also a lot of the fishing game logic
        fishingRod.lua (COMMENTED) - Handles drawing the fishing rod and the code that uses the accelerometer to determine how fast you swung the Playdate
        fishManager.lua (COMMENTED) - Uses fish.json to get data on how difficult the fishing game should be based on what fish was caught
        gameScene.lua - Handles initializing the fishing game scene
        water.lua (COMMENTED) - Handles drawing the simulated water physics
    instructions/
        instructionsScene.lua - The scene that shows the instructions
    title/
        titleScene.lua - The scene that shows the title screen
    sceneManager.lua (COMMENTED) - Handles scene transitions
fish.json - Holds data for the different fish types
main.lua (COMMENTED) - This file. Scroll down!
]]--

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

-- Explain more about this in fishManager.lua
CAUGHT_FISH = {}
local caught_fish = pd.datastore.read()
if caught_fish then
    CAUGHT_FISH = caught_fish
end

SceneManager = SceneManager()
TitleScene()

-- This seems like something that should be fixed, but the crankIndicator gets
-- drawn over by sprites, so you need to draw it in the main file after the sprite
-- update function. Hence the existence of this weird global indicator boolean
SHOW_CRANK_INDICATOR = false
pd.ui.crankIndicator:start()

-- Adding the fishing log and instruction options for the menu here
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
    -- pd.drawFPS(10, 10)

    if pd.isCrankDocked() and SHOW_CRANK_INDICATOR then
        pd.ui.crankIndicator:update()
    end
end

function pd.gameWillTerminate()
    pd.datastore.write(CAUGHT_FISH)
end

function pd.gameWillSleep()
    pd.datastore.write(CAUGHT_FISH)
end
