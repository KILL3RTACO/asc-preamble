Floor = require("../asc").require "floor"

fs = require "fs"

module.exports = class AscArena

  constructor: ->
    @__floors = []

  push: (floor) ->
    throw new TypeError("floor is must be an instance of Floor") if floor is null or floor is undefined or floor not instanceof Floor
    @__floors[floor.getId() - 1] = floor

  size: -> @__floors.length

  get: (id, reload = false, hooks) ->
    @reloadFloor(id, false, hooks) if reload
    f = @__floors[id - 1]
    return null if f is null or f is undefined
    return f

  load: (hooks) ->
    @__floors.splice 0
    floorId = 1
    while true
      break if not reloadFloor floorId++, false, hooks

  loadIfUnloaded: (id, hooks = true) ->
    return if @get(id) isnt null
    @reloadFloor(id, false, hooks)

  reloadFloor: (id, create = false, hooks = false) ->
    filename = @getFileName id
    floor = null
    try
      json = JSON.parse fs.readFileSync(filename, "utf8")
      floor = Floor.fromJson(json)
      @push floor
    catch err
      console.error err
      return false if not create
      floor = new Floor(id, "")
      @push floor
      @saveFloorState id

    @loadHooks(floor) if hooks
    return true

  saveFloorState: (id) ->
    f = @get id
    return if f is null
    fs.writeFileSync @constructor.getFileName(id), JSON.stringify(f.toJson())

  # @OverrideMe
  getFileName: ->

  # @OverrideMe
  loadHooks: ->
