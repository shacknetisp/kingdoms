# Kingdoms by Beha

The Kingdoms modpack is designed to allow kingdom vs kingdom PvP in Minetest.

Interesting features include:

* A fully formspec-based kingdom manager.
* Chat channels for the area, your kingdom, and everywhere.

# Modifications

This modpack contains some alternative versions of mods with modifications to work better alongside the main kingdoms/magic combination.

* bones: drop items upon explosion, respect kingdom heavy_chests level.
* doors: respect kingdom levels, add heavy doors.
* tnt: respect explosion blockers/absorbers, work better with objects and mobs, support magic.

Kingdoms also overrides a few default items.
* chests: respect kingdom levels, add heavy chests.
* furnace: respect kingdom levels.
* keys: remove keys entirely

# Compatibility

* Kingdoms is mostly compatible with other mods by default, but mods that register locked/owned items or query protection may need some tweaking.
* Protection should be tested with `kingdoms.player.canpos` rather than `minetest.is_protected` (unless testing for digging/building rights.) This is not critical, but it will result in less-flexible kingdom levels.
* All locked/owned items should be replaced with tests for kingdom levels or `is_protected`. At the very least, allow maxlevel members of the kingdom to remove the nodes by force.

# Recommended/Tested Mods

* [ancient_world](https://github.com/shacknetisp/ancient_world) has been hooked into for generating magic crystals and silver blocks as hidden rewards.
* [magic](https://github.com/shacknetisp/magic) is recommended.

* 3d_armor is fully compatible with kingdoms and provides a variety of protections against all forms of "fleshy" damage. Kingdoms will disable the healing feature automatically.
* unified_inventory is hooked into with a kingdoms button.
