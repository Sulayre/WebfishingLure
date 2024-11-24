## <p align="center">LURE IS CURRENTLY GOING UNDER A FULL REWRITE, FOLLOW OUR PROGRESS ON [GITHUB](https://github.com/Sulayre/WebfishingLure)!</p>
<p align="center">
  <img src="https://raw.githubusercontent.com/Sulayre/WebfishingLure/refs/heads/main/icon.png" alt="Lure Shrimp"/>
</p>

## 4.2.2
- Modded map spawn positions now work properly (kitty-girl on GitHub)
- Void Portals no longer crash modded maps that don't contain a spawn position for them (kitty-girl on GitHub)
- Added a new C# patch that turns the const shops list in shop.gd into a var instead of a const, allowing adding custom shops to it externally without patches.
- Modded maps can now be hidden from the map list with a "hidden" value in the maps dictionary, can be set both when calling add_map or by editing it directly by accessing the Lure node.

## 4.2.1
- Lure has been updated for WEBFISHING 1.10
- Added a new popup window that lets you know if Lure is not updated for the current game version
- Joining friends who are playing cutom maps through Steam is still bugged. (yeah)

## 4.2.0
- added a new vanilla filterer to the base game's save data loader as a second layer of security for crash prevention and save corruption
- now the save splitter actually works, sorry.
- corrupted saves (vanilla saves with mod references) should fix themselves on load now, please lmk if it works!

## 4.1.0
- lure shouldn't crash anymore and all modded content should work as usual
- modded map lobbies may be buggy?
- max player tweak discontinued
- lure lobby filters discontinued **(no more dedicated lobbies filter sorry)**
- Emote wheel is fixed on widescreen
- steam joins are still not fixed so don't use modded maps with the steam-friends lobby setting please
- lure modded props/actors no longer rely on a C# patch
- C# patch changes

## 4.0.0
- Lure now has proper save data splitting for modded things! your vanilla save data will remain intact if you uninstall mods.
- Lure's vanilla items and cosmetics list is now a const to avoid human error
- Lure now prevents resource loading when a new version of the game comes out to avoid save corruption (experimental)
- Lure now supports custom emotes! check the GitHub documentation.
- Lobby settings improvements
- The game now loads lure assets like 90% faster because I got rid of all the prints that are not critical errors.

## Features
### Lure allows you to...
- Add your own fish, props, bobbers, colors, titles, eyes, mouths and noses!
- Add custom shirts/undershirts, hats and accessories with alternative meshes for any vanilla or modded species!
- Add new species with unique voices with modded and vanilla pattern compatibility!
- Add custom patterns for Vanilla AND anyone’s modded species!
- Add new items that can have any function from any node linked to it!
- Add custom emotes!
- Make whole new maps without having to replace things from the base game!
- Change the lobby's max players up to 250 (or reducing it down to 2)!
- Filter lobby search to easily find modded lobbies or dedicated servers!

### ...it also makes modding easier and less annoying with the following tweaks :)
- Updates the character colors shader so now patterns can have additional static colors on their textures.
- Items/Cosmetics loaded with lure have a unique prefix related to the mod's folder they were loaded from, allowing multiple mods to have same the same item/cosmetic file names.
- Streamlines the process of finding your mod's assets by using Lure's unique prefixes when referencing assets inside the mod's folder.
- Saves modded items and cosmetic data on a separate file so the vanilla content doesn't get corrupted when uninstalling!

## Known Issues
- Joining friends through Steam causes map desync.
