{Weapon} = require "../asc"
{Enum} = require "../common"

Character = class module.exports

  constructor: (name, gender, classification, kingdom) ->
    wwt.validateString "name", name
    @__name = name
    @__gender = gender
    @__classification = classification
    @__kingdom = kingdom

  getName: -> @__name
  getGender: -> @__gender
  getClassification: -> @__classification
  getHailingKingdom: -> @__kingdom

class CType extends Enum.GenericEntry

  constructor: (@__name, @__weaponTypes) ->

  getNormalWeaponTypes: -> @__weaponTypes.slice 0
  getNormalWeaponTypesString: ->
    return @__weaponTypes[0].getName() if @__weaponTypes.length is 0
    str = ""
    str += "#{@__weaponTypes[i].getName()} or " for i in [0...@__weaponTypes.length - 1]
    str += @__weaponTypes[@__weaponTypes.length - 1].getName()

Character.ClassificationType = ctypes = new Enum()
ctypes.__addValue("AURORA", new CType("Aurora", [Weapon.Type.SWORD]))
ctypes.__addValue("GOLEM", new CType("Golem", [Weapon.Type.MINIGUN, Weapon.Type.ROCKET_LAUNCHER, Weapon.Type.AUTOMATIC_RIFLE, Weapon.Type.MARKSMAN_RIFLE]))
ctypes.__addValue("SALAMANDER", new CType("Salamander", [Weapon.Type.SHOTGUN, Weapon.Type.AUTOMATIC_RIFLE]))
ctypes.__addValue("SHADOWBORNE", new CType("Shadowborne", [Weapon.Type.SNIPER_RIFLE]))
ctypes.__addValue("XARYA", new CType("Xarya", [Weapon.Type.AUTOMATIC_RIFLE, Weapon.Type.MARKSMAN_RIFLE]))
ctypes.__addValue("ZEPHYR", new CType("Zephyr", [Weapon.Type.MARKSMAN_RIFLE, Weapon.Type.AUTOMATIC_RIFLE]))

Character.Gender = g = new Enum()
g.__addValue("MALE", new Enum.GenericEntry("Male"))
g.__addValue("FEMALE", new Enum.GenericEntry("Female"))
g.__addValue("OTHER", new Enum.GenericEntry("Other"))

Character.Kingdom = k = new Enum()
k.__addValue("ARIA", new Enum.GenericIdEntry(1, "Aria"))
k.__addValue("DYRE", new Enum.GenericIdEntry(2, "Dyre"))
k.__addValue("ELODIA", new Enum.GenericIdEntry(3, "Elodia"))
k.__addValue("HELIX", new Enum.GenericIdEntry(4, "Helix"))
k.__addValue("VACANT", new Enum.GenericIdEntry(5, "Vacant"))
