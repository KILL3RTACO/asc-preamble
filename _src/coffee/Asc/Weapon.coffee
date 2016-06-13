{Enum, Util} = require "../common"

Weapon = class module.exports

  @Type:         new Enum()
  @Manufacturer: new Enum()

  constructor: (type, manufacturer, baseDamage) ->
    Util.validateInstance "type", type, Weapon.Type
    Util.validateInstance "manufacturer", manufacturer, Weapon.Manufacturer
    wwt.util.validateInteger "baseDamage", baseDamage
    @__type = type
    @__baseDamage = baseDamage
    @__calculatedDamage = @__baseDamage


Weapon.Type.__addValue("AUTOMATIC_RIFLE", new Enum.GenericIdEntry(1, "Automatic Rifle"))
Weapon.Type.__addValue("MARKSMAN_RIFLE", new Enum.GenericIdEntry(2, "Marksman Rifle"))
Weapon.Type.__addValue("MINIGUN", new Enum.GenericIdEntry(3, "Minigun"))
Weapon.Type.__addValue("ROCKET_LAUNCHER", new Enum.GenericIdEntry(4, "Rocket Launcher"))
Weapon.Type.__addValue("SHOTGUN", new Enum.GenericIdEntry(5, "Shotgun"))
Weapon.Type.__addValue("SNIPER_RIFLE", new Enum.GenericIdEntry(6, "Sniper Rifle"))
Weapon.Type.__addValue("SWORD", new Enum.GenericIdEntry(76, "Sword"))

Weapon.Manufacturer.__addValue("NAUTILUS", new Enum.GenericEntry("Nautilus"))
Weapon.Manufacturer.__addValue("NONE", new Enum.GenericEntry("Unknown")) # There is no manufacturer
Weapon.Manufacturer.__addValue("OMICRON", new Enum.GenericEntry("Omicron"))
Weapon.Manufacturer.__addValue("SOMA", new Enum.GenericEntry("Soma"))
