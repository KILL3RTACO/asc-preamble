{Section, Encounterable}  = require "../asc"
{max, min}                = Math

class PointList

  constructor: (p1, p2, @__isWhitelist = true) ->
    @__min = {x: min(p1.x, p2.x), y: min(p1.y, p2.y)}
    @__max = {x: max(p1.x, p2.x), y: max(p1.y, p2.y)}

  isWhitelist: -> @__isWhitelist

  isInside: (point) ->
    return point.x >= @__min.x and
           point.x <= @__max.x and
           point.y >= @__min.y and
           point.y <= @__max.y

module.exports = class Zone extends Encounterable

  constructor: (@__id, @__name) ->
    @__lists = []

  getId: -> @__id
  getName: -> @__name

  addBlacklist: (p1, p2) ->
    @__lists.push new PointList(p1, p2, false)
    return @
  addWhiteList: (p1) ->
    @__lists.push new PointList(p1, p2)
    return @

  isInside: (point) ->
    inside = false
    (inside = pl.isWhitelist()) for pl in @__lists when pl.isInside point
    return inside
