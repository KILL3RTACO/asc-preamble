Journey = require "../journey"

{Enum} = require "../common"

{Floor, Section, Weapon} = require "../asc"

module.exports = class Player

  @fromJson: (json, arena) ->
    gender = g.valueOf json.gender
    classification = ctypes.valueOf json.classification
    kingdom = k.valueOf json.kingdom

    player = new Player(json.name, gender, classification, kingdom)
    player.setLocation(arena.get(json.location.floor, true, true), json.location.x, json.location.y)
    return player

  constructor: (@__name, @__gender, @__classification, @__kingdom) ->
    @__location = {}

  getName: -> @__name
  getGender: -> @__gender
  getClassification: -> @__classification
  getHailingKingdom: -> @__kingdom

  getLocation: -> @__location
  setLocation:  ->
    return if arguments.length is 0

    # setLocation(section: Section | {floor?: int, x: int, y: int})
    if arguments.length is 1
      section = arguments[0]
      if section instanceof Section
        @__location = section
      else # assumed to be a plain object
        floor = null
        if section.floor instanceof Floor
          floor = section.floor
        throw new Error("Previous location not set, cannot retrieve current floor") if not floor

        s = if floor then floor.get(section.x, section.y) else null
        throw new Error("Cannot find section (#{section.x}, #{section.y})") if s is null

        @__location = s

    # setLocation(x: int, y: int)
    else if arguments.length is 2
      @setLocation {x: arguments[0], y: arguments[1]}

    # setLocation(floor: Floor, x: int, y: int)
    else if arguments.length is 3
      @setLocation {floor: arguments[0], x: arguments[1], y: arguments[2]}

    return @

  isInTown: -> @__location.getEnvironment().isTownEnvironment()

  canMove: (dir) -> return @__location.canMoveTo dir
  move: (dir) ->
    section = @__location.getNeighbor dir
    throw new Error("Neighbor from move result cannot be null (dir: #{dir})")
    @setLocation section

  toJson: ->
    name: @__name
    gender: @__gender.name()
    classification: @__classification.name()
    kingdom: @__kingdom.name()
    location:
      areaName: @__location.getAreaName()
      floor: @__location.getFloor().getId()
      floorName: @__location.getFloor().getName()
      x: @__location.getX()
      y: @__location.getY()

class CType extends Enum.GenericEntry

  constructor: (@__name, @__weaponTypes) ->

  getNormalWeaponTypes: -> @__weaponTypes.slice 0
  getNormalWeaponTypesString: ->
    return @__weaponTypes[0].getName() if @__weaponTypes.length is 0
    str = ""
    str += "#{@__weaponTypes[i].getName()} or " for i in [0...@__weaponTypes.length - 1]
    str += @__weaponTypes[@__weaponTypes.length - 1].getName()

Player.ClassificationType = ctypes = new Enum()
ctypes.__addValue("AURORA", new CType("Aurora", [Weapon.Type.SWORD]))
ctypes.__addValue("GOLEM", new CType("Golem", [Weapon.Type.MINIGUN, Weapon.Type.ROCKET_LAUNCHER, Weapon.Type.AUTOMATIC_RIFLE, Weapon.Type.MARKSMAN_RIFLE]))
ctypes.__addValue("SALAMANDER", new CType("Salamander", [Weapon.Type.SHOTGUN, Weapon.Type.AUTOMATIC_RIFLE]))
ctypes.__addValue("SHADOWBORNE", new CType("Shadowborne", [Weapon.Type.SNIPER_RIFLE]))
ctypes.__addValue("XARYA", new CType("Xarya", [Weapon.Type.AUTOMATIC_RIFLE, Weapon.Type.MARKSMAN_RIFLE]))
ctypes.__addValue("ZEPHYR", new CType("Zephyr", [Weapon.Type.MARKSMAN_RIFLE, Weapon.Type.AUTOMATIC_RIFLE]))

Player.Gender = g = new Enum()
g.__addValue("MALE", new Enum.GenericEntry("Male"))
g.__addValue("FEMALE", new Enum.GenericEntry("Female"))
g.__addValue("OTHER", new Enum.GenericEntry("Other"))

Player.Kingdom = k = new Enum()
k.__addValue("ARIA", new Enum.GenericIdEntry(1, "Aria"))
k.__addValue("DYRE", new Enum.GenericIdEntry(2, "Dyre"))
k.__addValue("ELODIA", new Enum.GenericIdEntry(3, "Elodia"))
k.__addValue("HELIX", new Enum.GenericIdEntry(4, "Helix"))
k.__addValue("VACANT", new Enum.GenericIdEntry(5, "Vacant"))
