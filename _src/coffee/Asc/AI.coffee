{Enum} = require "../common"


{World}   = require("../asc")

encode = (num) ->
  return "0" if num is 0
  letters = "0123456789RMNT#{World.getCode()}"
  string = ""
  while num > 0
    string = letters.charAt(num % letters.length) + string
    num //= letters.length
  return string

encodeTime = -> encode(new Date().getTime())

module.exports = class AI extends Enum.GenericIdEntry

  constructor: (@__id, @__name, @__nameAbbr, @__level, @__kingdom, @__role) ->

  getNameAbbr: -> @__nameAbbr
  getNameHtml: -> "<span class='ai-name-#{@__name.toLowerCase()}'>#{@__name}</span>"
  getDesignationHtml: -> "<span class='ai-designation ai-designation-#{@__name.toLowerCase()}'>#{@getDesignation()}</span>"
  getDesignation: -> "#{@getDesignationPrefix()}/#{@__nameAbbr}"
  getDesignationPrefix: -> "AI-#{@__level}/#{@getKingdomAbbr()}-#{@__role}"
  getLevel: -> @__level
  getRole: -> @__role
  getKingdom: -> @__kingdom
  getKingdomAbbr: -> @__kingdom.getCode()

  beginTransmission: -> "// #{@getDesignation()} // #{encodeTime()} // TRANSMISSION_START //"
  beginTransmissionHtml: -> "<span class='ai-transmission'>#{@beginTransmission()}</span>"

  endTransmission: -> "// #{@getDesignation()} // #{encodeTime()} // TRANSMISSION_END //"
  endTransmissionHtml: -> "<span class='ai-transmission'>#{@endTransmission()}</span>"
