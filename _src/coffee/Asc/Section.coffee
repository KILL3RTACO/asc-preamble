GridUtil = require("../common").require "grid-util"

Asc           = require '../asc'
Enocunter     = Asc.require "encounter"
Encounterable = Asc.require "encounterable"
Environment   = Asc.require "environment"

module.exports = class Section extends Encounterable

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
    super
    @__movementCost = 1

  getFloor: -> @__floor
  getX: -> @__x
  getY: -> @__y
  getLocation: -> {x: @__x, y: @__y}
  getEnvironment: -> @__environment
  getNeighbor: (dir) -> @__floor.getNeighborOf(@__x, @__y, dir)
  canMoveTo: (dir) -> @__floor.canMoveTo(@__x, @__y, dir)
  setAreaName: (@__areaName) ->
  getAreaName: -> if @__areaName then @__areaName else @__zone.getName()

  isTownSection: -> @getEnvironment().isTownEnvironment()

  setZone: (@__zone) ->
  getZone: -> @__zone

  getMovementCost: -> @getEnvironment().getMovementCost()

  toJson: ->
    floor: @__floor.getId()
    x: @__x
    y: @__y
    env: @__environment.getId()

  toPathfinder: ->
    {Node} = require "../Common/Pathfinder.js"
    directions = (@canMoveTo(dir) for dir in @constructor.ALL_DIRECTIONS)
    return new Node(@__x, @__y, directions, @__movementCost)
