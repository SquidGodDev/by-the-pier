# By the Pier
Source code for my Playdate fishing game "By the Pier", with fish art made by Goodgis. Uses the accelerometer to calculate cast speed and crank to reel in your line. Watch for your tension so you don't snap the line, and try to catch all the fish! You can find the game on [Itch IO](https://squidgod.itch.io/by-the-pier).

<img src="https://github.com/user-attachments/assets/e1686966-bc26-45ba-81b4-ed13794cef57" width="400" height="240"/>
<img src="https://github.com/user-attachments/assets/267555c3-538e-4bc7-9599-7cc6f430af20" width="400" height="240"/>
<img src="https://github.com/user-attachments/assets/09fe92db-a4a4-41fd-aff4-19dc0751e63d" width="400" height="240"/>
<img src="https://github.com/user-attachments/assets/e1127262-5a72-4376-ad7f-4756d9e5f9b4" width="400" height="240"/>

## Project Structure
- `scripts/`
    - `directory/`
        - `directoryScene.lua` - This is the scene that handles the fishing log. It uses the gridview UI component (I made a video on it)
    - `game/`
        - `ui/`
            - `catchTimer.lua` - This is the bar that pops up that shows you how long you have to catch the fish
            - `resultDisplay.lua` - This is the notebook that comes down and shows you what fish you caught
            - `tensionBar.lua` - This is the bar that shows what tension the fishing line is at
        - `cloud.lua` - Handles a single cloud moving and removing itself after it goes off screen
        - `cloudSpawner.lua` - Handles spawning the clouds
        - `fishingLine.lua` - Handles drawing the fishing line and also a lot of the fishing game logic
        - `fishingRod.lua` - Handles drawing the fishing rod and the code that uses the accelerometer to determine how fast you swung the Playdate
        - `fishManager.lua` - Uses fish.json to get data on how difficult the fishing game should be based on what fish was caught
        - `gameScene.lua` - Handles initializing the fishing game scene
        - `water.lua` - Handles drawing the simulated water physics
    - `instructions/`
        - `instructionsScene.lua` - The scene that shows the instructions
    - `title/`
        - `titleScene.lua` - The scene that shows the title screen
    - `sceneManager.lua` - Handles scene transitions
`fish.json` - Holds data for the different fish types
`main.lua` - Game entry point

## License
All code is licensed under the terms of the MIT license.
