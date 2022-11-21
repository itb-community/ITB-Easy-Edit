# ITB-Easy-Edit
This is an Into the Breach mod loader extension by originally authored by Lemonymous @ https://github.com/Lemonymous. Since [ITB-Mod-Loader](https://github.com/itb-community/ITB-ModLoader) version 2.82 it has been integrated into the mod loader as an extension which can be either enabled stand-alone, or used as a dependency by a mod.
 
It intends to make it much easier for mod creators to do many things that were previously very difficult: The creation of new islands, tilesets, corporations, enemylists, etc. See the documentation for a full function list.

# Mod Dependency
Mods can add Easy Edit as a dependency, which will ensure that Easy Edit will be enabled whenever your mod is enabled.

Example mod's `init.lua`
```lua
return {
    id = "my_mod_id",
    name = "My Mod Name",
    version = "1.0.0",
    dependencies = {
        easyEdit = "2.0.0",
    }
}
```

# Documentation
 See the [wiki](../../wiki) for documentation.

# Licence
 The code uses GNU GENERAL PUBLIC LICENSE, which can be read in the file LICENCE provided.
