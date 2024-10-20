![LureLogo](https://cdn.discordapp.com/attachments/1297612591656341504/1297617737081950278/image.png?ex=67169431&is=671542b1&hm=e3c6bfd6c059e17549c7185b80347e86665b3f27139c986d9f8493027fc4a8d6&)
## Features

- Automatically scans for item and cosmetic resource files on all mods currently installed, making basic modded content require no code and only editor use.
- more features coming soon i promise

## Requirements
- [GDWeave](https://github.com/NotNite/GDWeave/tree/main)

## How to Install
- drag the folder inside the release's zip into ```<game install folder>\GDWeave\mods```

## Development
if your mod depends on Lure in any way, make sure to add ```"sulayre.lureapi"``` to the ```"Dependencies"``` array of your mod's manifest.json
To let Lure autoload your Items and Cosmetics, make a ```"Resources/Lure``` directory on your PCK

the full path should be ```res://mods/<your mod id>/Resources/Lure/<.tres files go here>```

### your pck should look like this before exporting:
![example](https://i.imgur.com/uXpuqNP.png)

*(Logo drawn by [ZeaTheMays](https://github.com/ZeaTheMays))*
