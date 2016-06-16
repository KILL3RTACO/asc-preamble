class Enum

  constructor: ->
    @__values = []

  __addValue: (name, value) ->
    throw new Error("#{name} has already been defined") if typeof @[name] isnt "undefined"
    @[name] = value
    @__values.push value

  values: -> @__values.slice 0

class Enum.GenericEntry

    constructor: (@__name) ->
    getName: -> @__name

class Enum.GenericIdEntry extends Enum.GenericEntry
  constructor: (@__id, @__name) ->
  getId: -> @__id

if typeof module is "object" and typeof module.exports is "object"
  module.exports = Enum
else
  window.Enum = Enum
