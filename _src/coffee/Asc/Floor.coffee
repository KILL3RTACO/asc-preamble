Area       = require "./Area.js"
Pathfinder = require "../Common/Pathfinder.js"

getIndex = (x, y, width) -> return (y * width) + x

module.exports = class Floor extends Pathfinder.Grid

  @DEF_SIZE_X: 25
  @DEF_SIZE_Y: 25

  constructor: (id, name, sizeX, sizeY) ->
    wwt.util.validateInt "id", id
    wwt.util.validateString "name", name
    @__id = id
    @__name = name
    sizeX = if typeof sizeX is "number" and Number.isInteger(sizeX) then sizeX else @constructor.DEF_SIZE_X
    sizeY = if typeof sizeY is "number" and Number.isInteger(sizeY) then sizeY else @constructor.DEF_SIZE_Y
    super [], sizeX, sizeY
    @__initZones()
    @__initAreas()
    @__initNeighbors()

  getId: -> @__id
  getName: -> @__name
  getSize: -> {x: @getWidth(), y: @getHeight()}

  set: (x, y, area) ->
    throw new Error("area must be an instance of Area") if area not instanceof Area
    return super(x, y, area)

  # Subclasses should override these
  __initZones: ->
  __initAreas: ->
  __initNeighbors: ->

  allowNeighbor: (x, y, dir = Area.ALL_DIRECTIONS, allow = true) ->
    area = @getArea x, y
    return if area is null

    if wwt.util.isArray dir
      (@allowNeighbor x, y, d) for d in dir
      return
    else
      return if not Number.isInteger dir

    if allow
      area.setNeighbor dir, @neighborOf x, y, dir
    else
      area.setNeighbor dir, null

    return @

  neighborOf: (x, y, dir) ->
    delta = Area.getDeltas dir
    return @get(x + delta.x, y + delta.y)

  isEdge: (x, y, dir) ->
    switch dir
      when Area.UP then return y is 0
      when Area.LEFT then return x is 0
      when Area.RIGHT then return x is @getWidth() - 1
      when Area.DOWN then return y is @getHeight() - 1
      when Area.TOP_LEFT then return y is 0 or x is 0
      when Area.TOP_RIGHT then return y is 0 or x is @getWidth() - 1
      when Area.BOTTOM_LEFT then return x is 0 or y is @getHeight() - 1
      when Area.BOTTOM_RIGHT then return x is @getWidth() - 1 or y is @getHeight() - 1
      else return false

  findPath: (start, goal, options) ->
    startArea = @get(start.x, start.y); throw new Error("Start node has nowhere to go") if startArea is null or startArea is undefined or startArea.isWall()
    goalArea = @get(goal.x, goal.y); throw new Error("Goal node is inaccessible") if goalArea is null or goalArea is undefined or goalArea.isWall()

    options ?= {}
    options.grid = this
    pathfinder = new Pathfinder(options)
    path = pathfinder.findPath startArea, goalArea

    return null if path is null
    return path

  # Subclasses should override
  getStartLocation: ->
    x: 0
    y: 0
