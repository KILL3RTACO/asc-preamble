Journey = require "../journey"

{Enum} = require "../common"

{Floor, Section, Weapon, World} = require "../asc"

DEF_CREDIT_AMOUNT = 500

module.exports = class Player

  @fromJson: (json, arena) ->
    gender = g.valueOf json.gender
    classification = ctypes.valueOf json.classification
    kingdom = World.Kingdom.valueOf json.kingdom

    player = new Player(json.name, gender, classification, kingdom)
    player.setLocation(arena.get(json.location.floor, true, true), json.location.x, json.location.y)
    player.setMaxFloorTraversed json.maxFloor or 1
    player.setCredit json.credit or DEF_CREDIT_AMOUNT
    return player

  constructor: (@__name, @__gender, @__classification, @__kingdom, @__credit = DEF_CREDIT_AMOUNT) ->
    @__location = {}

  getName: -> @__name
  getGender: -> @__gender
  getClassification: -> @__classification
  getHailingKingdom: -> @__kingdom

  addCredit: (credit) ->
    @__credit += credit
    return @
  removeCredit: (credit) ->
    @__credit -= credit
    return @
  setCredit: (@__credit) ->
  getCredit: -> @__credit

  setMaxFloorTraversed: (@__maxFloor) ->
  getMaxFloorTraversed: -> @__maxFloor

  getXY: -> @__location.getLocation()

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

  getCurrentFloor: -> @__location.getFloor()
  getCurrentFloorId: -> @__location.getFloor().getId()

  isInTown: -> @__location.getEnvironment().isTownEnvironment()

  canMove: (dir) -> return @__location.canMoveTo dir
  move: (dir) ->
    section = @__location.getNeighbor dir
    throw new Error("Neighbor from move result cannot be null (dir: #{dir})")
    @setLocation section

  getDesignation: ->
    "#{@__name.replace(/\-/g, "_")}/#{@__gender.name().charAt(0)}/#{@__classification.getCode()}/#{@__kingdom.getCode()}"

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
    maxFloor: @__maxFloor
    credit: @__credit

class CType extends Enum.GenericEntry

  constructor: (@__name, @__code, @__weaponTypes) ->

  getCode: -> @__code

  getNormalWeaponTypes: -> @__weaponTypes.slice 0
  getNormalWeaponTypesString: ->
    return @__weaponTypes[0].getName() if @__weaponTypes.length is 0
    str = ""
    str += "#{@__weaponTypes[i].getName()} or " for i in [0...@__weaponTypes.length - 1]
    str += @__weaponTypes[@__weaponTypes.length - 1].getName()

Player.ClassificationType = ctypes = new Enum()
ctypes.__addValue("AURORA", new CType("Aurora", "AUR", [Weapon.Type.SWORD]))
ctypes.__addValue("GOLEM", new CType("Golem", "GLM", [Weapon.Type.MINIGUN, Weapon.Type.ROCKET_LAUNCHER, Weapon.Type.AUTOMATIC_RIFLE, Weapon.Type.MARKSMAN_RIFLE]))
ctypes.__addValue("SALAMANDER", new CType("Salamander", "SLM", [Weapon.Type.SHOTGUN, Weapon.Type.AUTOMATIC_RIFLE]))
ctypes.__addValue("SHADOWBORNE", new CType("Shadowborne", "SBN", [Weapon.Type.SNIPER_RIFLE]))
ctypes.__addValue("XARYA", new CType("Xarya", "XRA", [Weapon.Type.AUTOMATIC_RIFLE, Weapon.Type.MARKSMAN_RIFLE]))
ctypes.__addValue("ZEPHYR", new CType("Zephyr", "ZPR", [Weapon.Type.MARKSMAN_RIFLE, Weapon.Type.AUTOMATIC_RIFLE]))

Player.Gender = g = new Enum()
g.__addValue("MALE", new Enum.GenericEntry("Male"))
g.__addValue("FEMALE", new Enum.GenericEntry("Female"))
g.__addValue("OTHER", new Enum.GenericEntry("Other"))
