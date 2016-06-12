Section     = require "./Section.js"
GridUtil    = require "../Common/GridUtil.js"
Environment = require "./Environment.js"

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
    return if GridUtil.isOutOfBounds section.getX(), section.getY(), @__width, @__height
    @__sections[GridUtil.toIndex section.getX(), section.getY(), @getWidth()] = section
    return @
  get: (x, y) ->
    return null if GridUtil.isOutOfBounds(x, y, @__width, @__height)
    section = @__sections[GridUtil.toIndex x, y, @getWidth()]
    return null if section is null or section is undefined
    return section
  createSection: (x, y) ->
    return null if GridUtil.isOutOfBounds x, y, @__width, @__height
    section = new Section(this, x, y)
    @push section
    return section

  getNeighborOf: (x, y, dir) ->
    delta = Section.getDelta(dir)
    return @get(x + delta.x, y + delta.y)

  canMoveTo: (x, y, dir) ->
    section = @get(x, y)
    neighbor = @getNeighborOf(x, y, dir)

    # if both sections are null, accessibleness is true
    # if section isnt null, but neighbor is, then accessibleness is true if section is inaccessible by all environments
    accessible = (->
      if section is null
        if neighbor is null # both are null
          return true
        else # section is null, neighbor isnt
          return not neighbor.getEnvironment().isAccessibleFrom(null)
      else
        if neighbor is null # section isnt null, neighbor is
          return not section.getEnvironment().isAccessibleFrom(null)
        else # neither are null
          return neighbor.getEnvironment().isAccessibleFrom(section.getEnvironment())
    )()

    switch dir
      when Section.UP, Section.DOWN, Section.LEFT, Section.RIGHT
        return accessible
      when Section.TOP_LEFT
        return accessible and (@canMoveTo(x, y, Section.UP) or @canMoveTo(x, y, Section.LEFT))
      when Section.TOP_RIGHT
        return accessible and (@canMoveTo(x, y, Section.UP) or @canMoveTo(x, y, Section.RIGHT))
      when Section.BOTTOM_LEFT
        return accessible and (@canMoveTo(x, y, Section.DOWN) or @canMoveTo(x, y, Section.LEFT))
      when Section.BOTTOM_RIGHT
        return accessible and (@canMoveTo(x, y, Section.DOWN) or @canMoveTo(x, y, Section.RIGHT))
      else return false

  # @OverrideMe
  getStartLocation: ->
    x: 0
    y: 0
