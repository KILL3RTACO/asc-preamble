Journey = require "../journey"

{Enum} = require "../common"

{PseudoPlayer, Floor, Section} = require "../asc"

DEF_CREDIT_AMOUNT = 500

module.exports = class Player extends PseudoPlayer

  {@Gender, @ClassificationType} = PseudoPlayer

  @fromJson: (json, arena) =>
    player = @fromPseudo(super)
    player.setLocation(arena.get(json.location.floor, true, true), json.location.x, json.location.y)
    player.setMaxFloorTraversed json.maxFloor or 1
    player.setCredit json.credit or DEF_CREDIT_AMOUNT
    return player

  @fromPseudo: (pseudo) ->
    return new Player(pseudo.getName(), pseudo.getGender(), pseudo.getClassification(), pseudo.getKingdom())

  constructor: (name, gender, classification, kingdom, @__credit = DEF_CREDIT_AMOUNT) ->
    super
    @__location = {}

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

  toJson: ->
    return $.extend {}, super,
      location:
        areaName: @__location.getAreaName()
        floor: @__location.getFloor().getId()
        floorName: @__location.getFloor().getName()
        x: @__location.getX()
        y: @__location.getY()
      maxFloor: @__maxFloor
      credit: @__credit
