class World

  constructor = ->
    @__name = "Anavasi"
    @__code = "AVSI"

  getName: -> @__name
  getCode: -> @__code


module.exports = new World() # A whole new woooorlldd ~
