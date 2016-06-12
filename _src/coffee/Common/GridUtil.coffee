module.exports = class GridUtil

  @toIndex: (x, y, w) -> return (w * y) + x
  @fromIndex: (index, w) -> return {x: index % w, y: index // w}

  @isTop: (y) -> return y is 0
  @isLeft: (x) -> return x is 0
  @isBottom: (y, h) -> return y is h - 1
  @isRight: (x, w) -> return x is w - 1

  @isTopLeft: (x, y) -> return @isTop(y) and @isLeft(x)
  @isTopRight: (x, y, w) -> return @isTop(y) and @isRight(x, w)
  @isBottomLeft: (x, y, h) -> return @isBottom(y, h) and @isLeft(x)
  @isBottomRight: (x, y, w, h) -> return @isBottom(y, h) and @isRight(x, w)
  @isCorner: (x, y, w, h) ->
    return @isTopLeft(x, y) or @isTopRight(x, y, w) or @isBottomLeft(x, y, h) or @isBottomRight(x, y, w, h)

  @isOutOfBounds: (x, y, w, h) -> return x < 0 or y < 0 or x >= w or y >= h

  @getUpDelta: -> {x: 0, y: -1}
  @getDownDelta: -> {x: 0, y: 1}
  @getLeftDelta: -> {x: -1, y: 0}
  @getRightDelta: -> {x: 1, y: 0}
  @getTopLeftDelta: -> {x: -1, y: -1}
  @getTopRightDelta: -> {x: 1, y: -1}
  @getBottomLeftDelta: -> {x: -1, y: 1}
  @getBottomRightDelta: -> {x: 1, y: 1}
