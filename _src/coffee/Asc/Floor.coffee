Section     = require "./Section.js"
GridUtil    = require "../Common/GridUtil.js"
Environment = require "./Environment.js"

DEF_FLOOR_W = 25
DEF_FLOOR_H = 25

module.exports = class Floor

  @DEF_W: 25
  @DEF_H: 25

  @fromJson: (json) ->
    floor = new Floor(json.id, json.name, Environment.getEnvironment(json.env), json.size.x, json.size.y)
    floor.push(Section.fromJson(s, floor)) for s in json.sections
    return floor

  constructor: (@__id, @__name, @__environment = Environment.FLOOR_PLAINS, @__width = @constructor.DEF_W, @__height = @constructor.DEF_H) ->
    @__sections = []

  getId: -> @__id
  getName: -> @__name
  getWidth: -> @__width
  getHeight: -> @__height
  getEnvironment: -> @__environment

  toJson: ->
    id: @__id
    name: @__name
    size:
      x: @__width
      y: @__height
    env: @__environment.getId()
    sections: (s.toJson() for s in @__sections when s isnt null and s isnt undefined)

  push: (section) ->
    throw new Error("section.getFloor() and this don't match") if section.getFloor() isnt @
    @__sections[GridUtil.toIndex section.getX(), section.getY(), @getWidth()] = section
    return @
  get: (x, y) ->
    return null if GridUtil.isOutOfBounds(x, y, @__width, @__height)
    section = @__sections[GridUtil.toIndex x, y, @getWidth()]
    return null if section is null or section is undefined
    return section

  getNeighborOf: (x, y, dir) ->
    delta = Section.getDelta(dir)
    return @get(x + delta.x, y + delta.y)

  # Can the given section move in the given direction? (accessibleness must match the neighbor)
  # For diagonal direction, accessibleness must also match the neighbors in the two corresponding directions
  # Exmaple - TOP_LEFT must also match UP and LEFT
  canMoveTo: (x, y, dir) ->
    section = @get(x, y)
    accessible = if section isnt null then section.getEnvironment().isAccessible() else false
    neighbor = @getNeighborOf(x, y, dir)
    neighborAccessible = neighbor isnt null and neighbor.getEnvironment().isAccessible()
    accessibleMatch = neighborAccessible == accessible
    switch dir
      when Section.UP, Section.DOWN, Section.LEFT, Section.RIGHT
        return accessibleMatch
      when Section.TOP_LEFT
        return @canMoveTo(x, y, Section.UP) and @canMoveTo(x, y, Section.LEFT) and accessibleMatch
      when Section.TOP_RIGHT
        return @canMoveTo(x, y, Section.UP) and @canMoveTo(x, y, Section.RIGHT) and accessibleMatch
      when Section.BOTTOM_LEFT
        return @canMoveTo(x, y, Section.DOWN) and @canMoveTo(x, y, Section.LEFT) and accessibleMatch
      when Section.BOTTOM_RIGHT
        return @canMoveTo(x, y, Section.DOWN) and @canMoveTo(x, y, Section.RIGHT) and accessibleMatch
      else return false

  # @OverrideMe
  getStartLocation: ->
    x: 0
    y: 0
