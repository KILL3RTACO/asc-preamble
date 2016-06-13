{Floor} = require "../asc"

module.exports = class AscArena

  constructor: ->
    @__floors = []

  push: (floor) ->
    throw new TypeError("floor is must be an instance of Floor") if floor is null or floor is undefined or floor not instanceof Floor
    @__floors[floor.getId() - 1] = floor
  get: (id) ->
    f = @__floors[id - 1]
    return null if f is null or f is undefined
    return f
  size: -> @__floors.length
