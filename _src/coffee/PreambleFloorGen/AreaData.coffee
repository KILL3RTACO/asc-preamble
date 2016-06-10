sort = (areas) ->
  areas.sort (a, b) ->
    if a.x is b.x
      return a.y - b.y
    else
      return a.x - b.x

module.exports = class AreaData

  constructor: ->
    @__areas = []

  get: (x, y) ->
    return area for area in @__areas when area.x is x and area.y is y
    area = {x, y, bg: "void", neighbors: [false, false, false, false, false, false, false, false], zoneId: -1}
    @__areas.push area
    return area

  addAll: (areas) -> @__areas.push area for area in areas

  clear: -> @__areas.splice 0

  asPlain: -> @__areas
