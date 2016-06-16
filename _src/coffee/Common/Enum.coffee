class Enum

  constructor: ->
    @__values = []

  __addValue: (name, value) ->
    throw new Error("value must be an instanceof Enum.GenericEntry") if value not instanceof Enum.GenericEntry
    throw new Error("#{name} has already been defined") if typeof @[name] isnt "undefined"
    @[name] = value
    value.__internalName = name
    @__values.push value

  values: -> @__values.slice 0
  valueOf: (name) -> return v for v in @__values when v.name() is name

class Enum.GenericEntry

    constructor: (@__name) ->
    getName: -> @__name
    name: -> @__internalName

class Enum.GenericIdEntry extends Enum.GenericEntry
  constructor: (@__id, @__name) ->
  getId: -> @__id

if typeof module is "object" and typeof module.exports is "object"
  module.exports = Enum
else
  window.Enum = Enum
