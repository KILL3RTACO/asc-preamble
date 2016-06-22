{GridUtil} = require("../common")

{
  Environment,
  Section,
  Town,
  Zone
} = require "../asc"

module.exports = class Floor

  @DEF_W: 25
  @DEF_H: 25

  @fromJson: (json) ->
    floor = new Floor(json.id, json.name, Environment.getEnvironment(json.env), json.size.x, json.size.y)
    floor.push(Section.fromJson(s, floor)) for s in json.sections
    floor.fillRemaining()
    return floor

  constructor: (@__id, @__name, @__environment = Environment.FLOOR_PLAINS, @__width = @constructor.DEF_W, @__height = @constructor.DEF_H) ->
    @__sections = []
    @__towns = []
    @__zones = []
    @__zonesFinal = false

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
    sections: (s.toJson() for s in @__sections when s isnt null and s isnt undefined and (s.getEnvironment() != @__environment or s.getMovementCost() != 1))

  addTown: (name, sections = []) ->
    town = new Town(this, name)
    town.push sections
    @__towns.push town
    return town
  getTown: (id) -> return @__towns[id - 1]
  getTowns: -> @__towns.slice 0
  getTownSize: -> @__towns.length

  createZone: (id, name) ->
    throw new Error("Zones have been finalized") if @__zonesFinal
    zone = new Zone(id, name)
    @__zones.push zone
  getZones: -> @__zones.slice 0

  finalizeZones: ->
    return if @__zones.length is 0
    for s in @__sections
      continue if s.isTownSection()
      for z in @__zones
        if z.isInside s.getLocation()
          s.setZone z
          for e in z.getEncounters()
            s.addEncounter e
    @__zonesFinal = true
  zonesAreFinal: -> @__zonesFinal

  push: (section) ->
    throw new Error("section.getFloor() and this don't match") if section.getFloor().getId() isnt @__id
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

  fillRemaining: ->
    for x in [0...@__width]
      for y in [0...@__height]
        @createSection(x, y) if @get(x, y) is null

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

  toPathfinder: ->
    {Grid} = require("../common").Pathfinder
    nodes = []
    nodes[i] = s.toPathfinder() for s, i in @__sections when s isnt null and s isnt undefined
    return new Grid(nodes, @__width, @__height)

  findPath: (start, goal, pfOptions) ->
    throw new Error("start must have a numeric x and y value") if typeof start.x isnt "number" and typeof start.y isnt "number"
    throw new Error("goal must have a numeric x and y value") if typeof goal.x isnt "number" and typeof goal.y isnt "number"
    {Pathfinder} = require "../common"
    pfOptions = {} if typeof pfOptions isnt "object"
    pfOptions.grid = @toPathfinder()

    startNode = pfOptions.grid.get(start.x, start.y)
    throw new Error("start node not equivalent not found") if startNode is null or startNode is undefined
    goalNode = pfOptions.grid.get(goal.x, goal.y)
    throw new Error("goal node not equivalent not found") if goalNode is null or goalNode is undefined
    return new Pathfinder(pfOptions).findPath(startNode, goalNode)

  setStartLocation: (start) ->
    return if typeof start isnt "object"
    @__startLocation = if start instanceof Section then start else @get(start.x, start.y)
  getStartLocation: -> @__startLocation
