Area         = require "./Area.js"
PreambleArea = require "../Preamble/PreambleArea.js"
MapRenderer  = require "../Common/MapRenderer.js"

{TOP, BOTTOM, LEFT, RIGHT} = MapRenderer

getCorner = (x, y, floor) ->
  return Area.TOP_LEFT if x is 0 and y is 0
  return Area.TOP_RIGHT if y is 0 and x is floor.getWidth() - 1
  return Area.BOTTOM_LEFT if x is 0 and y is floor.getHeight() - 1
  return Area.BOTTOM_RIGHT if x is floor.getWidth() - 1 and y is floor.getHeight() - 1
  return null

onCorner = (corner, x, y, floor) -> return getCorner(x, y, floor) is corner

onSide = (side, x, y, floor) ->
  return (side is Area.UP and y is 0) or
         (side is Area.DOWN and y is floor.getHeight() - 1) or
         (side is Area.LEFT and x is 0) or
         (side is Area.RIGHT and x is floor.getWidth() - 1)

getSide = (x, y, floor) ->
  return Area.UP if onSide Area.UP, x, y, floor
  return Area.DOWN if onSide Area.DOWN, x, y, floor
  return Area.LEFT if onSide Area.LEFT, x, y, floor
  return Area.RIGHT if onSide Area.RIGHT, x, y, floor
  return null

AREA_TO_MR = []
AREA_TO_MR[Area.UP] = TOP
AREA_TO_MR[Area.LEFT] = LEFT
AREA_TO_MR[Area.DOWN] = BOTTOM
AREA_TO_MR[Area.RIGHT] = RIGHT

module.exports = class FloorRenderer extends MapRenderer

  constructor: () ->
    super

  setFloor: (@__floor) ->
    @setWidth @__floor.getWidth()
    @setHeight @__floor.getHeight()
  getFloor: -> @__floor

  render: ->
    areaVoid = false

    for y in [0...@__floor.getHeight()]
      for x in [0...@__floor.getWidth()]
        area = @__floor.get x, y
        areaVoid = area is undefined or area is null

        bg = if areaVoid then @__voidColor else area.getBgColor()

        #Render cell
        @colorRaw x, y, bg
        @colorBorderRaw x, y, bg

    for y in [0...@__floor.getHeight()]
      for x in [0...@__floor.getWidth()]
        area = @__floor.get x, y
        areaVoid = area is undefined or area is null

        for d in [Area.UP, Area.LEFT, Area.RIGHT, Area.DOWN]
          # do (x, y, d, areaVoid, area) =>
            areaTest = @__floor.neighborOf(x, y, d)
            areaTestVoid = areaTest is null or areaTest is undefined
            @colorBorderRaw x, y, @__borderColor, AREA_TO_MR[d] if onSide(d, x, y, @__floor) or not (areaVoid or area.canGo(d))

  findPathAndDraw: (start, goal, distanceFormula, color = "#FF7F00") ->
    path = @__floor.findPath start, goal, {distanceFormula} #CHEBYSHEV
    return null if path is null
    @colorPathRaw path, color, @constructor.CURVED
