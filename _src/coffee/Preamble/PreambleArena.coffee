AscArena = require "../Asc/AscArena.js"
Floor    = require "../Asc/Floor.js"
fs       = require "fs"

class PreambleArena extends AscArena

  @getFileName: (floorId) -> return "#{__dirname}/Floors/Floor#{floorId}.json"

  constructor: ->
    super

  load: ->
    @__floors.splice 0
    floorId = 1
    while true
      break if not reloadFloor floorId++

  reloadFloor: (id, create = false) ->
    filename = @constructor.getFileName id
    try
      json = JSON.parse fs.readFileSync(filename, "utf8")
      @push Floor.fromJson(json)
      return true
    catch err
      return false if not create
      floor = new Floor(id, "")
      @push floor
      @saveFloorState id
      return true

  saveFloorState: (id) ->
    f = @get id
    return if f is null
    fs.writeFileSync @constructor.getFileName(id), JSON.stringify(f.toJson())

module.exports = new PreambleArena()
