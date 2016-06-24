{Enum} = require "../common"

{Weapon, World} = require "../asc"

module.exports = class PseudoPlayer

  @fromJson: (json, arena) ->
    gender = @Gender.valueOf json.gender
    classification = @ClassificationType.valueOf json.classification
    kingdom = World.Kingdom.valueOf json.kingdom

    return new PseudoPlayer(json.name, gender, classification, kingdom)

  constructor: (@__name, @__gender, @__classification, @__kingdom) ->

  getName: -> @__name
  getGender: -> @__gender
  getClassification: -> @__classification
  getKingdom: -> @__kingdom

  getDesignation: ->
    "#{@__name.replace(/\-/g, "_")}/#{@__gender.name().charAt(0)}/#{@__classification.getCode()}/#{@__kingdom.getCode()}"

  toJson: ->
    name: @__name
    gender: @__gender.name()
    classification: @__classification.name()
    kingdom: @__kingdom.name()

class CType extends Enum.GenericEntry

  constructor: (@__name, @__code, @__weaponTypes) ->

  getCode: -> @__code

  getNormalWeaponTypes: -> @__weaponTypes.slice 0
  getNormalWeaponTypesString: ->
    return @__weaponTypes[0].getName() if @__weaponTypes.length is 0
    str = ""
    str += "#{@__weaponTypes[i].getName()} or " for i in [0...@__weaponTypes.length - 1]
    str += @__weaponTypes[@__weaponTypes.length - 1].getName()

PseudoPlayer.ClassificationType = ctypes = new Enum()
ctypes.__addValue("AURORA", new CType("Aurora", "AUR", [Weapon.Type.SWORD]))
ctypes.__addValue("GOLEM", new CType("Golem", "GLM", [Weapon.Type.MINIGUN, Weapon.Type.ROCKET_LAUNCHER, Weapon.Type.AUTOMATIC_RIFLE, Weapon.Type.MARKSMAN_RIFLE]))
ctypes.__addValue("SALAMANDER", new CType("Salamander", "SLM", [Weapon.Type.SHOTGUN, Weapon.Type.AUTOMATIC_RIFLE]))
ctypes.__addValue("SHADOWBORNE", new CType("Shadowborne", "SBN", [Weapon.Type.SNIPER_RIFLE]))
ctypes.__addValue("XARYA", new CType("Xarya", "XRA", [Weapon.Type.AUTOMATIC_RIFLE, Weapon.Type.MARKSMAN_RIFLE]))
ctypes.__addValue("ZEPHYR", new CType("Zephyr", "ZPR", [Weapon.Type.MARKSMAN_RIFLE, Weapon.Type.AUTOMATIC_RIFLE]))

PseudoPlayer.Gender = g = new Enum()
g.__addValue("MALE", new Enum.GenericEntry("Male"))
g.__addValue("FEMALE", new Enum.GenericEntry("Female"))
g.__addValue("OTHER", new Enum.GenericEntry("Other"))
