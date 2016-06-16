Journey = require "../journey"

module.exports = class Encounter

  constructor: (@__placeTitle = "", @__placeLine1 = "", @__placeLine2 = "", weight = 1, fn) ->
    throw new TypeError("weight must be a number") if typeof weight isnt "number"
    throw new TypeError("fn must be a function") if fn isnt null and typeof fn isnt "function"
    @__weight = weight
    @__fn = fn

  getWeight: -> @__weight

  run: (thisArg) ->
    Journey.reset()
    Journey.setPlaceTitle(@__placeTitle)
    Journey.setPlaceLine1(@__placeLine1)
    Journey.setPlaceLine2(@__placeLine2)
    @__fn.call(thisArg)
    return @
