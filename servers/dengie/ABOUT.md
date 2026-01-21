# dengie

Dengie Minecraft Spigot modded server from
[BuildTools](https://hub.spigotmc.org/jenkins/job/BuildTools/).


## Datapacks

Datapacks need to be copied to `world/datapacks`.

* [Leash Villager](https://www.curseforge.com/minecraft/texture-packs/leash-villager)


## Plugins

Shown in ascending order of supported Minecraft version.

#1 rule: keep the list small, and avoid mods adding new content (blocks etc).

| Name       | MC V.   | Link                                                                                                                                     |
|------------|---------|------------------------------------------------------------------------------------------------------------------------------------------|
| todolist   | ?*      | [link](https://github.com/C-D-Lewis/mc-dev/tree/main/todolist)                                                                           |
| ChestLock  | 1.21.4* | [link](https://www.spigotmc.org/resources/chest-lock-with-automatic-sorting.81204/)                                                      |
| WorldGuard | 1.21.11 | [link](https://dev.bukkit.org/projects/worldguard)                                                                                       |
| Dynmap     | 1.21.11 | [link](https://www.spigotmc.org/resources/dynmap%C2%AE.274/)                                                                             |
| ImageFrame | 1.21.11 | [link](https://www.spigotmc.org/resources/imageframe-load-images-on-maps-item-frames-support-gifs-map-markers-survival-friendly.106031/) |
| TreeFeller | 1.21.11 | [link](https://modrinth.com/plugin/thizzyz-tree-feller)                                                                                  |

> '*' = works without launch errors on current server version


### Supporting plugins

| Name      | MC V.   | Link                                                     |
|-----------|---------|----------------------------------------------------------|
| WorldEdit | 1.21.11 | [link](https://dev.bukkit.org/projects/worldedit)        |
| LuckPerms | 1.21.11 | [link](https://luckperms.net/download)                   |
| TabTPS    | 1.21.11 | [link](https://modrinth.com/plugin/tabtps)               |
| CMILib    | 1.21.11 | [link](https://www.spigotmc.org/resources/cmilib.87610/) |


## Group permissions

* `default`
  * `bottledexp.*`
  * `chestlock.*`
  * `treefeller.*`
  * `imageframe.create`
  * `imageframe.clone`
  * `imageframe.select`
  * `imageframe.marker`
  * `imageframe.refresh`
  * `imageframe.rename`
  * `imageframe.info`
  * `imageframe.list`
  * `imageframe.get`
