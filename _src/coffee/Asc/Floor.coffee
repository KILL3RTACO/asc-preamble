Section = require "Section.js"
GridUtil = require "../Common/GridUtil.js"

DEF_FLOOR_W = 25
DEF_FLOOR_H = 25

class Floor

  constructor: (@__id, @__name, @__environment, @__width = DEF_FLOOR_W, @__height = DEF_FLOOR_H) ->
    @__sections = []

  getId: -> @__id
  getName: -> @__name
  getWidth: -> @__width
  getHeight: -> @__height
  getEnvironment: -> @__environment

  push: (section) ->
    throw new Error("section.getFloor() and this don't match") if section.getFloor() isnt @
    @__sections[GridUtil.toIndex section.getX(), section.getY(), @getWidth()] = section
    return @
  get: (x, y) ->
    return null if GridUtil.isOutOfBounds(x, y, @__width, @__height)
    section = @__sections[GridUtil.toIndex section.getX(), section.getY(), @getWidth()]
    return null if section is null or section is undefined
    return section

  getNeighborOf: (x, y, dir) ->
    delta = Section.getDelta(dir)
    return @get(x + delta.x, y + delta.y)

  # Assuming the given section is accessible, is it possible to move in the given direction?
  # For Cardinal Directions - true if the neighbor is not null and accessible
  # For Diagonal Directions - true if it's possible to move in both of the two corresponding cardinal directions (TOP_LEFT = UP, LEFT)
  canMoveTo: (x, y, dir) ->
    switch dir
      when Section.UP, Section.DOWN, Section.LEFT, Section.RIGHT
        neighbor = @getNeighborOf(x, y, dir)
        return neighbor isnt null and neighbor.getEnvironment().isAccessible()
      when Section.TOP_LEFT
        return @canMoveTo(x, y, Section.UP) and @canMoveTo(x, y, Section.LEFT)
      when Section.TOP_RIGHT
        return @canMoveTo(x, y, Section.UP) and @canMoveTo(x, y, Section.RIGHT)
      when Section.BOTTOM_LEFT
        return @canMoveTo(x, y, Section.DOWN) and @canMoveTo(x, y, Section.LEFT)
      when Section.BOTTOM_RIGHT
        return @canMoveTo(x, y, Section.DOWN) and @canMoveTo(x, y, Section.RIGHT)
      else return false

  # @OverrideMe
  getStartLocation: ->
    x: 0
    y: 0
