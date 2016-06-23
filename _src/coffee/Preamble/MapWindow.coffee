{Window} = require "../asc"

class MapWindow

  constructor: ->
    super

  createContents: ->
    @addCloseButton()

module.exports = new MapWindow()
