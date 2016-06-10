getRaw = (name, presets) ->
  return p for p in presets when p.name is name
  return null

module.exports = class ColorData

  ###
  {
    name: string
    color: string
  }
  ###

  constructor: (@__presets) ->

  setColor: (name, color) ->
    p = getRaw(name, @__presets)
    if p is null
      @__presets.push {name, color}
      @sort()
    else
      p.color = color
    return @
  getColor: (name) ->
    return "#000" if name is "void"
    c = getRaw(name, @__presets)
    return null if c is null
    return c.color
  removeColor: (name) ->
    index = @indexOf name
    return if index < 0
    @__presets.splice index, 1

  getNames: -> return (p.name for p in @__presets)

  indexOf: (name) ->
    return i for p, i in @__presets when p.name is name
    return -1

  exists: (name) -> @getColor(name) isnt null

  clear: -> @__presets.splice 0
  sort: -> @__presets.sort (a, b) -> return a.name.localeCompare(b.name)
  length: -> @__presets.length

  asPlain: -> @__presets
