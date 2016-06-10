Enum    = require "../Common/Enum.js"
Kingdom = require("../Asc/Character").Kingdom

class AI extends Enum.GenericIdEntry

  constructor: (@__id, @__name, @__nameAbbr, @__level, @__kingdom, @__role) ->
    @__kingdomAbbr = (switch @__kingdom
      when Kingdom.ARIA
        "ARIA"
      when Kingdom.DYRE
        "DYRE"
      when Kingdom.HELIX
        "HLX"
      when Kingdom.VACANT
        "VCNT"
    )
  getNameAbbr: -> @__nameAbbr
  getNameHtml: -> "<span class='ai-name-#{@__name.toLowerCase()}'>#{@__name}</span>"
  getDesignationHtml: -> "<span class='ai-designation ai-designation-#{@__name.toLowerCase()}'>#{@getDesignation()}</span>"
  getDesignation: -> "#{@getDesignationPrefix()}/#{@__nameAbbr}"
  getDesignationPrefix: -> "AI-#{@__level}/#{@getKingdomAbbr()}-#{@__role}"
  getLevel: -> @__level
  getRole: -> @__role
  getKingdom: -> @__kingdom
  getKingdomAbbr: -> @__kingdomAbbr

module.exports = ais = new Enum()
ais.__addValue("IRIS", new AI(1, "Iris", "IRIS", 5, Kingdom.HELIX, "AM"))
ais.__addValue("SHERLOCK", new AI(2, "SRLK", 5, Kingdom.ARIA, "SE"))
