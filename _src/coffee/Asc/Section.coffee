GridUtil = require "../Common/GridUtil.js"

class Section

  {@UP, @DOWN, @LEFT, @RIGHT, @TOP_LEFT, @TOP_RIGHT, @ALL_DIRECTIONS} = require("../Common/Pathfinder.js").Node

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
    @__encounters = []

  getFloor: -> @__floor
  getX: -> @__x
  getY: -> @__y
  getLocation: -> {x: @__x, y: @__y}
  getEnvironment: -> @__environment
  getNeighbor: (dir) -> @__floor.getNeighborOf(@__x, @__y, dir)
  canMoveTo: (dir) -> @__floor.canMoveTo(@__x, @__y, dir)
