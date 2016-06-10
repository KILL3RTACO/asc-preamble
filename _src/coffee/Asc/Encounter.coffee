class Encounter

  constructor: (@__id, weight = 1, fn) ->
    throw new TypeError("weight must be a number") if typeof weight isnt "number"
    throw new TypeError("fn must be a function") if fn isnt null and typeof fn isnt "function"
    @__weight = weight
    @__fn = fn

  getWeight: -> @__weight

  run: (thisArg) ->
    @__fn.call(thisArg)
    return @
