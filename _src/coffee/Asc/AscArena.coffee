Floor = require "./Floor.js"

class module.exports

  constructor: ->
    @__floors = []

  addFloor: (floor) ->
    throw new TypeError("floor is must be an instanceof Floor") if not floor instanceof Floor
    @__floors.push floor
  getFloor: (id) ->
    return f for f in @__floors when f.getId() is id
    return null
  size: -> @__floors.length
