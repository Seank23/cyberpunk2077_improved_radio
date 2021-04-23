# Replacements Guide

As of version 1.1.0, Improved Radio supports custom track metadata, allowing the names of tracks provided in radio replacement mods to be displayed.
This guide details how to add the metadata for your replacement mod into Improved Radio.

**NOTE: To follow this guide, you must know either the track identifier string or the Wem filename of each track you have replaced. To obtain the track identifier from its Wem filename, use this [spreadsheet](https://docs.google.com/spreadsheets/d/1pNKW5u_1p33EKlWUDu5c3s9L1pFu1c0xDnH1kL8EZeY/edit#gid=1299531397) (WWISE IDs: lines 69 - 227).**

- The custom metadata for a replacement mod should be stored in a text file (.txt) and placed in the improved_radio\replacements folder. The text file can be given any name.
- The text file should contain three components:
  - A 'name' entry which specifies the name of the replacement mod, this will be displayed in the Improved Radio UI.
  - A list of replacement names for the radio stations (optional).
  - A list of replacement track metadata.

The format of file this is shown in the following image:

![ReplacementFile](https://github.com/Seank23/cyberpunk2077_improved_radio/blob/master/Images/ReplacementFile.png)

- Each entry in the file must be a key-value pair separated by an equals symbol ('=').
- The key for each radio station entry must be the in-game identifier string for that station. These can be obtained from the 'radioStationNames' table in the [radioData.lua](https://github.com/Seank23/cyberpunk2077_improved_radio/blob/master/modules/radioData.lua) file.
- The key for each track entry must be the hashcode value that corresponds to the track that is being replaced. These can be obtained from the 'songHashToInfo' table in the [radioData.lua](https://github.com/Seank23/cyberpunk2077_improved_radio/blob/master/modules/radioData.lua) file.
- The value of each track entry consists of its track identifier string, the artist name and the track name. Each of these should be listed in a single line and separated by a '|' character.
- Finally, the name of the text file storing your replacement metadata must be specified on a new line in the replacements.ini file (shown below). This tells Improved Radio where to look for the new metadata.

![ReplacementConfig](https://github.com/Seank23/cyberpunk2077_improved_radio/blob/master/Images/ReplacementConfig.png)
