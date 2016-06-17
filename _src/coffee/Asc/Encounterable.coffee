module.exports = class Encounterable

  constructor: ->
    @__encounters = []

  addEncounter: (encounter) ->
    @__encounters.push encounter
    return @
  randomEncounter: ->
    return null if @__encounters.length is 0
    return @__encounters[0] if @__encounters.length is 1
    weightSum = 0
    weightSum += e.getWeight() for e in @__encounters
    weights = []
    min = 0

    for e in @__encounters
     min = e.getWeight() if min is 0
     weights.push (if weights.length > 0 then weights[weights.length - 1] else 0) + e.getWeight()

    randomNum = (Math.random() * (weights[weights.length - 1] - min + 1)) + 1
    for w, i in weights
     lessThanNext = if i < weights.length -1 then randomNum < weights[i + 1] else true
     if randomNum >= w and lessThanNext
        return @__encounters[i]

    return null
  clearEncounters: ->
    @__encounters.splice 0
    return @
  getEncounterSize: -> @__encounters.length
