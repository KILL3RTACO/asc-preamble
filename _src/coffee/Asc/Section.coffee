{GridUtil} = require "../common"
{Environment} = require "../asc"

module.exports = class Section

  {@UP, @DOWN, @LEFT, @RIGHT, @TOP_LEFT, @TOP_RIGHT, @BOTTOM_LEFT, @BOTTOM_RIGHT, @ALL_DIRECTIONS} = require("../Common/Pathfinder.js").Node
  @CARDINAL_DIRECTIONS: [@UP, @DOWN, @LEFT, @RIGHT]
  @DIAGONAL_DIRECTIONS: [@TOP_LEFT, @TOP_RIGHT, @BOTTOM_LEFT, @BOTTOM_RIGHT]

  @fromJson: (json, floor) ->
    return new Section(floor, json.x, json.y, Environment.getEnvironment(json.env))

  @getDelta: (dir) ->
    switch dir
      when @UP then return GridUtil.getUpDelta()
      when @DOWN then return GridUtil.getDownDelta()
      when @LEFT then return GridUtil.getLeftDelta()
      when @RIGHT then return GridUtil.getRightDelta()
      when @TOP_LEFT then return GridUtil.getTopLeftDelta()
      when @TOP_RIGHT then return GridUtil.getTopRightDelta()
      when @BOTTOM_LEFT then return GridUtil.getBottomLeftDelta()
      when @BOTTOM_RIGHT then return GridUtil.getBottomRightDelta()
      else {x: 0, y: 0}

  constructor: (@__floor, @__x, @__y, @__environment = @__floor.getEnvironment()) ->
    @__movementCost = 1
    @__encounters = []

  getFloor: -> @__floor
  getX: -> @__x
  getY: -> @__y
  getLocation: -> {x: @__x, y: @__y}
  getEnvironment: -> @__environment
  getNeighbor: (dir) -> @__floor.getNeighborOf(@__x, @__y, dir)
  canMoveTo: (dir) -> @__floor.canMoveTo(@__x, @__y, dir)

  addEncounter: (encounter) ->
    @__encounters.push encounter
    return @
  randomEncounter: ->
    return null if @__encounters.length is 0
    return @__encounters[0] if @__encounters.length is 1
    weightSum = 0
    weightSum += e.getWeight() for e in @__encounters
    weights = []
    min = 0

    for e in @__encounters
     min = e.getWeight() if min is 0
     weights.push (if weights.length > 0 then weights[weights.length - 1] else 0) + e.getWeight()

    randomNum = (Math.random() * (weights[weights.length - 1] - min + 1)) + 1
    for w, i in weights
     lessThanNext = if i < weights.length -1 then randomNum < weights[i + 1] else true
     if randomNum >= w and lessThanNext
        return @__encounters[i]

    return null
  clearEncounters: ->
    @__encounters.splice 0
    return @
  getEncounterSize: -> @__encounters.length

  setMovementCost: (cost) ->
    @__movementCost = cost
    return @
  getMovementCost: -> @__movementCost

  toJson: ->
    floor: @__floor.getId()
    x: @__x
    y: @__y
    env: @__environment.getId()

  toPathfinder: ->
    {Node} = require "../Common/Pathfinder.js"
    directions = (@canMoveTo(dir) for dir in @constructor.ALL_DIRECTIONS)
    return new Node(@__x, @__y, directions, @__movementCost)
