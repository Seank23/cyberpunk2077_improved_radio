# Improved Radio

Allows full control over the in-game radio. Features include disabling individual songs on each radio station, skipping the current song and creating custom playlists of songs from any station that can be shuffled and saved.

## Features
- Skip Track - Plays a randomly selected song (that is not disabled) on the current radio station. If a playlist is active, it skips to the next song on the playlist (or to a random playlist song if shuffled).
- Track Remover - Allows the playlist of each radio station to be customised by enabling/disabling individual songs on the station.
- Custom Radio Playlists - Allows users to create their own playlists of in-game radio songs, these can be from any radio station in the game. The playlists can be played in the order they were made or in a random order if shuffle is enabled. A playlist can be saved to one of five slots allowing it to be loaded again at a later time.

## How To Install
- This mod requires Cyber Engine Tweaks﻿
- Extract the 'improved_radio' folder into the CET mods folder: <your installation path>\Cyberpunk 2077\bin\x64\plugins\cyber_engine_tweaks\mods\

## How To Use:
- The Improved Radio UI window can be viewed when the CyberEngineTweaks overlay is opened.
- The currently playing track information is displayed at the top of the UI window (1 in image).

### Track Remover:
- To customise the tracks on a radio station, open the 'Track Remover' menu a select a radio station from the 'Station' drop-down (3 in image). A list of all tracks on that station is displayed (4 in image), each will initially be enabled. To disable a track, simply click on its entry in the list. Click again to re-enable it.
- The track states are automatically saved to the 'songsEnabled.ini' file.

### Custom Radio Playlist:
- To create a custom playlist, open the 'Custom Radio Playlist' menu and click the 'Add Track' button (6 in image). This will create a new track entry in the playlist tracklist (10 in image), first select the radio station the track belongs to in the 'Select Station' drop-down, then select the track name from the 'Select Track' drop-down.
- Multiple tracks can be added to the playlist by clicking the 'Add Track' button again for each additional track. Tracks can be removed from the playlist by clicking the 'X' button next to a track entry. The 'Clear' button (7 in image) clears the entire playlist in the selected slot.
- Playlists are automatically saved to slots. By default, slot 1 is used. To select a different slot, click the button for the slot you want to select (e.g. 'Slot 2') (9 in image). Now a new playlist can be created which will be saved to this slot. To load a different slot, click a slot button and the playlist saved to that slot will be loaded. The contents of a slot is saved each time a new slot is selected so each playlist can be easily updated.
- To play a playlist, click the 'Play' button (5 in image), this plays through the playlist in the order it was entered. Once a playlist is completed it will loop back to the first track. If the 'Shuffle' checkbox is checked (8 in image), the playlist will be played in a random order. 
- The playlist can be stopped by clicking the 'Play button (now 'Stop' button) again, this will return control of the radio to the game.

- Hotkeys can be assigned to perform many of the mod's key functions, these are assigned in the 'Bindings' menu of the Cyber Engine Tweaks overlay under 'imporved_radio'.

## Limitations and Issues
- Only works with vehicle radios, the mod does not control radio speakers in the game world.
- Some songs may not be named correctly. If no name is given for a song its event ID is displayed instead.
- Custom playlists can be buggy, they may sometimes repeat a track or skip the next one altogether. If this happens, the 'Skip Track' button can be used to play another track in the playlist.
- Only supports songs already in the game at this time.
