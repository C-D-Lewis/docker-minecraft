# dengie

Dengie Minecraft server.

| Server  | MC Version |
|---------|------------|
| PaperMC | `26.3`     |

## Datapacks

Datapacks need to be copied to `world/datapacks`.

* [Leash Villager](https://www.curseforge.com/minecraft/texture-packs/leash-villager)
* From [Vanilla Tweaks](https://vanillatweaks.net/picker/datapacks/):
  * Creepers explode confetti
  * Shulkers drop 2x shells
  * Ender chest always drops
  * Fast leaf decay
  * Glass always drops
  * Cut down entire trees
  * Bottle XP (right click enchant table to fill)

## Plugins

These Paper/Bukkit plugins add more features and must support the current server
Minecraft version. If in doubt, launch in Docker locally and check the logs for
any errors or exceptions which might indicate incompatibility or data errors.

**#1 rule**: keep the list small, and avoid mods adding new content (blocks etc)
in case they become unmaintained and need to be removed to allow a Minecraft
version upgrade.

| Name       | MC Ver.  | Link                                                                                                                                     |
|------------|----------|------------------------------------------------------------------------------------------------------------------------------------------|
| todolist   | ?*       | [link](https://github.com/C-D-Lewis/mc-dev/tree/main/todolist)                                                                           |
| ChestLock  | 1.21.11* | [link](https://www.spigotmc.org/resources/chest-lock-with-automatic-sorting.81204/)                                                      |
| WorldGuard | 26.3     | [link](https://dev.bukkit.org/projects/worldguard)                                                                                       |
| Dynmap     | 26.3  | [link](https://github.com/webbukkit/dynmap)                                                                             |
| ImageFrame | 26.3     | [link](https://www.spigotmc.org/resources/imageframe-load-images-on-maps-item-frames-support-gifs-map-markers-survival-friendly.106031/) |

> '*' = works without launch errors on this server version


### Supporting plugins

These plugins are required by the main feature plugins in the table above.

| Name      | MC Ver. | Link                                                     |
|-----------|---------|----------------------------------------------------------|
| WorldEdit | 26.3    | [link](https://dev.bukkit.org/projects/worldedit)        |
| LuckPerms | 26.3    | [link](https://luckperms.net/download)                   |
| TabTPS    | 26.3    | [link](https://modrinth.com/plugin/tabtps)               |
| CMILib    | 26.3    | [link](https://www.spigotmc.org/resources/cmilib.87610/) |


## Group permissions

LuckPerms has the following permissions groups set up:

* Role: `default`
  * `bottledexp.*`
  * `chestlock.*`
  * `treefeller.*`
  * `imageframe.clone`
  * `imageframe.create`
  * `imageframe.get`
  * `imageframe.info`
  * `imageframe.list`
  * `imageframe.marker`
  * `imageframe.refresh`
  * `imageframe.rename`
  * `imageframe.select`

* Role: `managers`
  * `minecraft.command.whitelist`

* Role: `hosts`
  * `minecraft.command.summon`
  * `minecraft.command.tp`
