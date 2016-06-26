{Enum} = require "../common"

class Kingdom extends Enum.GenericIdEntry

  constructor: (id, name, @__code) ->
    super

  getCode: -> @__code

module.exports = class World

  @getName: -> "Anavasi"
  @getCode: -> "AVSI"
  @getChallengeTraditionName: -> "Celebration of Harmony"
  @getChallengeTraditionNameHtml: -> "<b>#{@getChallengeTraditionName()}</b>"
  @getFirstWarName: -> ""
  @getFirstWarNameHtml: -> "<i>#{@getFirstWarName()}</i>"
  @getSecondWarName: -> "The Luminant War"
  @getSecondWarNameHtml: -> "<i>#{@getSecondWarName()}</i>"

World.Kingdom = k = new Enum()
k.__addValue("ARIA", new Kingdom(1, "Aria", "ARIA"))
k.__addValue("DYRE", new Kingdom(2, "Dyre", "DYRE"))
k.__addValue("ELODIA", new Kingdom(3, "Elodia", "ELDA"))
k.__addValue("HELIX", new Kingdom(4, "Helix", "HELX"))
k.__addValue("VACANT", new Kingdom(5, "Vacant", "VCNT"))
