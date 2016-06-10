module.exports = class PreambleArea extends require "../Asc/Area.js"

  constructor: (x, y, @__zoneId, bgColor) ->
    super x, y, bgColor

  getZoneId: -> @__zoneId
