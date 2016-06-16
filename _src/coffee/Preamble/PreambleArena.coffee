Preamble       = require "../preamble"
Asc            = require "../asc"
{Arena, Floor} = Asc
fs             = require "fs"

loadHooks = (floor) ->
  try
    console.log "Preamble: Loading FloorHooks for [#{floor.getId()}]"
    require("#{__dirname}/Hooks/Floor#{floor.getId()}.js")(Asc, Preamble, floor)
  catch error
    console.error "Preamble: Could not load hooks: #{floor.getId()}"
    console.error error
    return

class PreambleArena extends Arena

  @getFileName: (floorId) -> return "#{__dirname}/Floors/Floor#{floorId}.json"

  constructor: ->
    super

  load: (hooks) ->
    @__floors.splice 0
    floorId = 1
    while true
      break if not reloadFloor floorId++, false, hooks

  loadIfUnloaded: (id, hooks = true) ->
    return if @get(id) isnt null
    @reloadFloor(id, false, hooks)

  reloadFloor: (id, create = false, hooks = false) ->
    filename = @constructor.getFileName id
    floor = null
    try
      json = JSON.parse fs.readFileSync(filename, "utf8")
      floor = Floor.fromJson(json)
      @push floor
    catch err
      return false if not create
      floor = new Floor(id, "")
      @push floor
      @saveFloorState id

    loadHooks(floor) if hooks
    return true

  saveFloorState: (id) ->
    f = @get id
    return if f is null
    fs.writeFileSync @constructor.getFileName(id), JSON.stringify(f.toJson())

module.exports = new PreambleArena()
