{Section} = require "../asc"
{MapRenderer, GridUtil} = require "../common"

{TOP, BOTTOM, LEFT, RIGHT} = MapRenderer

SECTION_TO_MR = []
SECTION_TO_MR[Section.UP] = TOP
SECTION_TO_MR[Section.LEFT] = LEFT
SECTION_TO_MR[Section.DOWN] = BOTTOM
SECTION_TO_MR[Section.RIGHT] = RIGHT

onSide = (dir, x, y, floor) ->
  switch dir
    when Section.UP then return GridUtil.isTop y
    when Section.DOWN then return GridUtil.isBottom y, floor.getHeight()
    when Section.LEFT then return GridUtil.isLeft x
    when Section.RIGHT then return GridUtil.isRight x, floor.getWidth()

module.exports = class FloorRenderer extends MapRenderer

  constructor: () ->
    super

  setFloor: (@__floor) ->
    @setWidth @__floor.getWidth()
    @setHeight @__floor.getHeight()
  getFloor: -> @__floor

  render: ->
    for y in [0...@__floor.getHeight()]
      for x in [0...@__floor.getWidth()]
        section = @__floor.get x, y
        sectionVoid = section is null

        bg = if sectionVoid then @__voidColor else section.getEnvironment().getColor()

        #Render cell
        @colorRaw x, y, bg
        @colorBorderRaw x, y, bg

    for y in [0...@__floor.getHeight()]
      for x in [0...@__floor.getWidth()]
        section = @__floor.get x, y
        sectionVoid = section is null

        for d in Section.CARDINAL_DIRECTIONS
          sectionTest = @__floor.getNeighborOf(x, y, d)
          sectionTestVoid = sectionTest is null
          @colorBorderRaw x, y, @__borderColor, SECTION_TO_MR[d] if onSide(d, x, y, @__floor) or not (sectionVoid or section.canMoveTo(d))

  findPathAndDraw: (start, goal, distanceFormula, color = "#FF7F00") ->
    path = @__floor.findPath start, goal, {distanceFormula} #CHEBYSHEV
    return null if path is null
    @colorPathRaw path, color
