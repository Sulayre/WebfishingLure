<p align="center">
  <img src="https://cdn.discordapp.com/attachments/1297612591656341504/1297617737081950278/image.png?ex=67169431&is=671542b1&hm=e3c6bfd6c059e17549c7185b80347e86665b3f27139c986d9f8493027fc4a8d6&" alt="Lure Shrimp"/>
</p>

## Features
### Lure allows you to...
- add Custom Fish, Tools (with limitations), Bobbers, Titles and Cosmetics of any kind! (you can even add cosmetic mesh variants for specific species!)
- add Custom Species with unique voices with modded and vanilla pattern compatibility!
- add Custom patterns for Vanilla AND modded species!

### ...it also makes modding easier and less annoying with the following tweaks :)
- Updates the character colors shader so now patterns can have additional static colors on their textures.
- Items/Cosmetics loaded with lure have a unique prefix related to the mod's folder they were loaded from, allowing multiple mods to have same the same item/cosmetic file names.
- Streamlines the process of finding your mod's assets by using Lure's unique prefixes when referencing assets inside the mod's folder.

## Roadmap (WIP) in order of priority
- Modded prop support (you can add them to your inventory but they dont work)
- assign any behavior function to modded tools (right now you can only reference ``player.gd`` functions)
- Proper implementation of the shop flags so you can add things to shops
- Custom body models
- Pattern support for tails
- Improvements to fallback appearance so only missing cosmetics are removed
- Map loader

## Requirements
- [GDWeave](https://github.com/NotNite/GDWeave/tree/main)

## How to Install
- drag the folder inside the release's zip into ```<game install folder>\GDWeave\mods```

## Development
if your mod depends on Lure in any way, make sure to add ``"Sulayre.Lure"`` to the ``"Dependencies"`` array of your mod's manifest.json like this:

``dependencies: ["Sulayre.Lure"]``

To access Lure's functions in your code, add the following line at the start of ``main.gd``:

``onready var Lure = get_node("/root/SulayreLure")``

*(this way you can access all of it's functions listed below in the Documentation)*

## Documentation  
### Loading assets with Lure
Lure allows you to load asset paths with 3 different prefixes:
- ``mod://``  searches for assets starting from the folder of the mod_id you gave to the function.
- ``res://`` searches for assets the classic way, in case you wanna search for base game assets.
- ``mods/<mod_id>://`` <u>searches for assets inside a specific mod</u>'s folder

 <u>if you use</u> ``mods/<mod_id>://`` <u>make sure you add the mod you're searching in as a dependency inside your mod's ``manifest.json`` to make sure its already loaded when searching inside it's files.</u>

**Examples**
*(we gave the function we're calling ``example_mod`` as the mod_id argument)*
- ``mod://asset.file``would search for ``asset.file`` inside ``example_mod``'s folder.
- ``res://Assets/asset.file`` would search for ``asset.file`` inside the base game's Assets folder.
- ``mods/other_mod://asset.file``would search for ``asset.file`` inside the folder of a mod called ``other_mod``.
### Initialization Functions <br><sub><sup>Make sure you call these functions on the ``_ready()`` function of your ``mod.gd``!</sup></sub>
**Lure.assign_pattern_texture(``your_mod_id``, ``pattern_id``, ``species_id``,  ``texture_path``)**<br>Allows you to assign a texture to a specific pattern for a specific species, this allows you to add base game pattern support to modded species, add vanilla species support for modded species or add other people's modded species support to your modded patterns.

**Lure.assign_species_voice(``your_mod_id``, ``species_id``,  ``bark_sound_path``, ``growl_sound_path``, ``whine_sound_path``)**<br>Allows you to assign bark, growl and whine sounds to a specific species, growl and whine are optional, if any of the two are missing they'll get assigned the bark sound.

**Lure.assign_face_animation(``your_mod_id``, ``species_id``, ``animation_path``)**<br>Allows you to assign a face offsets animation to a modded species, so you can adjust the eye, mouth and nose positions. You can make and edit offset animations by selecting the ![](https://cdn.discordapp.com/attachments/1297612591656341504/1298879143223492638/image.png?ex=671b2af7&is=6719d977&hm=699e55dfbba034a17cd1a99603bfa7ede9e09724e0020b5fb839ee36b70f04cd&) node inside the ``player_face.tscn`` scene that you can find in the ``res://Scenes/Entities/Player/Face`` folder when opening the decompiled game with the godot editor, then select either the ``cat_face`` or the ``dog_face`` animation in the animation timeline tab, click the ![](https://cdn.discordapp.com/attachments/1297612591656341504/1298877917744467968/image.png?ex=671b29d3&is=6719d853&hm=36fb587d5024508e25ee7379c4866228d78b3cee91932936c788e3aa6b98cd7b&) button and select 'Duplicate', name your new animation and save with "OK". After you're done editing the offsets, click ![](https://cdn.discordapp.com/attachments/1297612591656341504/1298877917744467968/image.png?ex=671b29d3&is=6719d853&hm=36fb587d5024508e25ee7379c4866228d78b3cee91932936c788e3aa6b98cd7b&) again and select "Save As", this is the file you'll need to load with the function.

**Lure.assign_cosmetic_mesh(``your_mod_id``, ``cosmetic_id``, ``species_id``, ``mesh_path``)**<br>Allows you to assign an alternative mesh to a specific cosmetic for a specific species, for example if you make a mask accessory, you'll need to make an alternative version for the dog, so its not clipping through the head, this is optional to make your cosmetics work but its heavily encouraged, this function works for both vanilla and modded species/cosmetics.

**Lure.add_content(``your_mod_id``,``resource_id``,``item_or_cosmetic_path``,``flags``)**<br>Loads a new cosmetic/item into the game, the final identifier of the cosmetic/item will be ``your_mod_id.the_resource_id``, this is to avoid mods cosmetics/items overriding other mods' so keep this in mind when using function that require a resource's identifier.  <u>Make sure you run this function last if you need to use any of the previously mentioned assign functions!</u>

*for example, if your mod's id is ``awesome`` and you're adding an item that's called ``sauce`` the final id of the item will be ``awesome.sauce``, you only have to do this for modded resources since base game resources use their file name without the ``.tres`` extension.*

``flags`` is an optional array argument that Lure uses to toggle certain functionality on your new content, here's a list of flags and their uses:
- ``FREE_UNLOCK`` if your new content is a cosmetic, it will add it to your inventory automatically, keep in mind that if you remove this flag in the future the item will remain unlocked for those that had the cosmetic beforehand, <u>this flag is added as default if you skipped the flags argument</u>.

*The following flags are not implemented yet, but you can add them if you want your content to be future proof:*
- ``SHOP_POSSUM`` adds the cosmetic or item to the possum's shop.
- ``SHOP_FROG`` adds the cosmetic or item to the frog's shop.
- ``SHOP_BEACH`` adds the cosmetic or item to the shop at the beach.

keep in mind that to access the flags you need to reference them inside Lure's ``LURE_FLAGS`` enum, so a real example would look like this:
``[Lure.LURE_FLAGS.SHOP_POSSUM, Lure.LURE_FLAGS.FREE_UNLOCK]``

### Utility Functions
**Lure.get_other_mod_asset_path(``path``)**<br>gives you the absolute ``res://`` path of another mod's asset, you're probably not gonna use this but i wanted to add it just in case, make sure the given path uses the ``mods/<mod_id>://`` prefix mentioned above.
