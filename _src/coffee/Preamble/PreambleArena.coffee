{Arena, Floor} = require "../asc"
fs       = require "fs"

loadHooks = (floor) ->
  try
    require("#{__dirname}/Hooks/Floor#{floor.getId()}.js")(floor)
  catch error
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

  reloadFloor: (id, create = false, hooks = false) ->
    filename = @constructor.getFileName id
    floor = null
    try
      json = JSON.parse fs.readFileSync(filename, "utf8")
      floor = Floor.fromJson(json)
      @push floor
      return true
    catch err
      return false if not create
      floor = new Floor(id, "")
      @push floor
      @saveFloorState id
      return true

    loadHooks(floor) if hooks

  saveFloorState: (id) ->
    f = @get id
    return if f is null
    fs.writeFileSync @constructor.getFileName(id), JSON.stringify(f.toJson())

module.exports = new PreambleArena()
