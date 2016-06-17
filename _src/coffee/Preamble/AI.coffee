{Enum} = require "../common"
{Kingdom} = require("../asc").Player

encode = (num) ->
  return "0" if num is 0
  # Why this code? Well, theres numbers, RMNT (Remant, a la RWBY) and AVSI (Anavasi, a la Ascension)
  # No character is repeated, so it could technically be decoded
  letters = "0123456789RMNTAVSI"
  string = ""
  while num > 0
    string = letters.charAt(num % letters.length) + string
    num //= letters.length
  return string

encodeTime = -> encode(new Date().getTime())

class AI extends Enum.GenericIdEntry

  constructor: (@__id, @__name, @__nameAbbr, @__level, @__kingdom, @__role) ->
    @__kingdomAbbr = (switch @__kingdom
      when Kingdom.ARIA then "ARIA"
      when Kingdom.DYRE then "DYRE"
      when Kingdom.ELODIA then "ELDA"
      when Kingdom.HELIX then "HELX"
      when Kingdom.VACANT then "VCNT"
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

  beginTransmission: -> "// #{@getDesignation()} // #{encodeTime()} // TRANSMISSION_START //"
  beginTransmissionHtml: -> "<span class='ai-transmission'>#{@beginTransmission()}</span>"

  endTransmission: -> "// #{@getDesignation()} // #{encodeTime()} // TRANSMISSION_END //"
  endTransmissionHtml: -> "<span class='ai-transmission'>#{@endTransmission()}</span>"

module.exports = ais = new Enum()
ais.__addValue("IRIS", new AI(1, "Iris", "IRIS", 5, Kingdom.HELIX, "AM"))
ais.__addValue("SHERLOCK", new AI(2, "Sherlock", "SRLK", 5, Kingdom.VACANT, "PR"))
ais.__addValue("ADRIAN", new AI(3, "Adrian", "ADRN", 5, Kingdom.ARIA, "HK"))
