module.exports = class AreaSelector

  constructor: (@__mr, @__areaData) ->
    @__selected = []

  select: (x, y) ->
    @__selected.push {x, y}

  unselectColor: (x, y) -> @__mr.color x, y, @__areaData.get(x, y).bg

  unselect: (x, y) ->
    @unselectColor x, y
    index = @selectedIndex x, y
    return if index is -1
    @__selected.splice index, 1

  selectedIndex: (x, y) -> return i for area, i in @__selected when area.x is x and area.y is y
  isSelected: (x, y) -> return @selectedIndex(x, y) > -1

  unselectAll: ->
    @unselectColor(x, y) for {x, y} in @__selected
    @__selected.splice 0

  length: -> @__selected.length
  isEmpty: -> @length() is 0

  get: (index = -1) -> if index < 0 then @__selected else @__selected[index]
