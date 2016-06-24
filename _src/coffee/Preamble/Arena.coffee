Asc            = require "../asc"
{Arena, Floor} = Asc

Preamble  = require "../preamble"

class PreambleArena extends Arena

  constructor: ->
    super

  getFileName: (floorId) -> return "#{__dirname}/Floors/Floor#{floorId}.json"

  loadHooks: (floor) ->
    try
      console.log "Preamble: Loading FloorHooks for [#{floor.getId()}]"
      require("#{__dirname}/Hooks/Floor#{floor.getId()}.js")(Asc, Preamble, floor)
      floor.finalizeZones()
    catch error
      console.error "Preamble: Could not load hooks: #{floor.getId()}"
      console.error error
      return

module.exports = new PreambleArena()
