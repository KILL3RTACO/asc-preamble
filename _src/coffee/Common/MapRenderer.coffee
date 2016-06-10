class MapRenderer

  # Marker styles
  @SQUARE:            0
  @CIRCLE:            1
  @DIAMOND:           2
  @TRIANGLE_UP:       3
  @TRIANGLE_LEFT:     4
  @TRIANGLE_RIGHT:    5
  @TRIANGLE_DOWN:     6
  @TRIANGLE_UP_EQ:    7
  @TRIANGLE_LEFT_EQ:  8
  @TRIANGLE_RIGHT_EQ: 9
  @TRIANGLE_DOWN_EQ:  10

  # Border directions
  @TOP:    0
  @LEFT:   1
  @BOTTOM: 2
  @RIGHT:  3

  # Path styles
  # @STRAIGHT: 0
  # @CURVED:   1

  constructor: (@__width, @__height) ->
    @__borderSize = 1
    @__cellSize = 20
    @__voidColor = "#FFF"
    @__inactiveBorderColor = "#AAA"
    @__borderColor = "#000"
    @__colors = []

  setWidth: (@__width) -> @__updateSize()
  getWidth: -> @__width

  setHeight: (@__height) -> @__updateSize()
  getHeight: -> @__height

  __updateSize: ->
    @__ctx.canvas.width = @getOffset @getWidth()
    @__ctx.canvas.height = @getOffset @getHeight()
    return

  setVoidColor: (@__voidColor) -> return @
  getVoidColor: -> @__voidColor

  setColorData: (@__colors) ->
  getColorData: -> @__colors

  getOffset: (amount) -> ((@getCellSize() + @getBorderSize()) * amount) + @getBorderSize()
  getOffsetPoint: (x, y) ->
    return {
      x: @getOffset x
      y: @getOffset y
    }

  getCenter: (amount) -> @getOffset(amount) + (@__cellSize / 2)
  getCenterPoint: (x, y) ->
    return {
      x: @getCenter x
      y: @getCenter y
    }

  setCanvas: (canvas) ->
    @__ctx = canvas.getContext("2d")
    @__updateSize()
    return @
  getContext: -> @__ctx

  color: (x, y, color) -> @colorRaw x, y, @__colors.getColor color
  colorRaw: (x, y, color) ->
    @__ctx.save()
    @__ctx.fillStyle = color
    @__ctx.fillRect @getOffset(x), @getOffset(y), @__cellSize, @__cellSize
    @__ctx.restore()

  colorBorder: (x, y, color, direction) -> @colorBorderRaw x, y, @__colors.getColor(color), direction
  colorBorderRaw: (x, y, color, direction) ->
    @__ctx.save()
    @__ctx.fillStyle = color
    if direction is @constructor.TOP
      @__ctx.fillRect @getOffset(x) - @__borderSize, @getOffset(y) - @__borderSize, @__cellSize + (@__borderSize * 2), @__borderSize
    else if direction is @constructor.LEFT
      @__ctx.fillRect @getOffset(x) - @__borderSize, @getOffset(y) - @__borderSize, @__borderSize, @__cellSize + (@__borderSize * 2)
    else if direction is @constructor.BOTTOM
      @__ctx.fillRect @getOffset(x) - @__borderSize, @getOffset(y) + @__cellSize, @__cellSize + (@__borderSize * 2), @__borderSize
    else if direction is @constructor.RIGHT
      @__ctx.fillRect @getOffset(x) + @__cellSize, @getOffset(y) - @__borderSize, @__borderSize, @__cellSize + (@__borderSize * 2)
    else
      @colorBorderRaw x, y, color, d for d in [@constructor.TOP, @constructor.LEFT, @constructor.RIGHT, @constructor.BOTTOM]
    @__ctx.restore()

  colorMarker: (x, y, color, style) -> @colorMakerRaw x, y, @getColor(color), style
  colorMarkerRaw: (x, y, color, style) ->
    ox = @getOffset x
    oy = @getOffset y

    om = (@__cellSize / 4)
    size = (@__cellSize / 2)

    top = oy + om
    left = ox + om
    midX = ox + size
    midY = oy + size
    right = (ox + @__cellSize) - om
    bottom = (oy + @__cellSize) - om

    @__ctx.save()
    @__ctx.fillStyle = color
    triEq = style is @constructor.TRIANGLE_UP_EQ or
            style is @constructor.TRIANGLE_LEFT_EQ or
            style is @constructor.TRIANGLE_RIGHT_EQ or
            style is @constructor.TRIANGLE_DOWN_EQ
    triMod = (if triEq then om / 2 else 0)
    if style is @constructor.CIRCLE
      @__ctx.beginPath()
      @__ctx.arc midX, midY, om, 0, 2 * Math.PI
      @__ctx.closePath()
      @__ctx.fill()
    else if style is @constructor.DIAMOND
      @__ctx.beginPath()
      @__ctx.moveTo left, midY
      @__ctx.lineTo midX, top
      @__ctx.lineTo right, midY
      @__ctx.lineTo midX, bottom
      @__ctx.closePath()
      @__ctx.fill()
    else if style is @constructor.TRIANGLE_UP or style is @constructor.TRIANGLE_UP_EQ
      @__ctx.beginPath()
      @__ctx.moveTo left, bottom - triMod
      @__ctx.lineTo midX, top + triMod
      @__ctx.lineTo right, bottom - triMod
      @__ctx.closePath()
      @__ctx.fill()
    else if style is @constructor.TRIANGLE_LEFT or style is @constructor.TRIANGLE_LEFT_EQ
      @__ctx.beginPath()
      @__ctx.moveTo left + triMod, midY
      @__ctx.lineTo right - triMod, top
      @__ctx.lineTo right - triMod, bottom
      @__ctx.closePath()
      @__ctx.fill()
    else if style is @constructor.TRIANGLE_RIGHT or style is @constructor.TRIANGLE_RIGHT_EQ
      @__ctx.beginPath()
      @__ctx.moveTo left + triMod, top
      @__ctx.lineTo right - triMod, midY
      @__ctx.lineTo left + triMod, bottom
      @__ctx.closePath()
      @__ctx.fill()
    else if style is @constructor.TRIANGLE_DOWN or style is @constructor.TRIANGLE_DOWN_EQ
      @__ctx.beginPath()
      @__ctx.moveTo left, top + triMod
      @__ctx.lineTo right, top + triMod
      @__ctx.lineTo midX, bottom - triMod
      @__ctx.closePath()
      @__ctx.fill()
    else # SQUARE
      @__ctx.fillRect ox + om, oy + om, size, size
    @__ctx.restore()

  setBorderSize: (size) ->
    @__borderSize = if Number.isInteger(size) and size > 0 then size else 1
    @__updateSize()
    return @
  getBorderSize: -> @__borderSize

  setBorderColor: (@__borderColor) -> return @
  getBorderColor: -> @__borderColor

  setCellSize: (size) ->
    @__cellSize = if Number.isInteger(size) and size > 0 then size else 1
    @__updateSize()
    return @
  getCellSize: -> return @__cellSize

  colorPath: (path, color) -> drawPathRaw path, @getColor(color)
  colorPathRaw: (path, color) ->
    return if path is null or path.length < 2
    @__ctx.save()
    @__ctx.strokeStyle = color
    @__ctx.beginPath()
    prev = null
    for {x, y} in path
      if prev is null
        prev = @getCenterPoint x, y
        @__ctx.moveTo prev.x, prev.y
      else
        @__ctx.lineTo prev.x, prev.y
        prev = @getCenterPoint x, y
    @__ctx.lineTo prev.x, prev.y
    @__ctx.stroke()
    @__ctx.closePath()
    @__ctx.restore()

  getCellLocation: (pixelX, pixelY) ->
    return {
      x: pixelX // (@__cellSize + @__borderSize)
      y: pixelY // (@__cellSize + @__borderSize)
    }

if typeof module is "object" and typeof module.exports is "object"
  module.exports = MapRenderer
else
  window.MapRenderer = MapRenderer
