module.exports = class Area extends require("../Common/Pathfinder.js").Node

  @CARDINAL_DIRECTIONS:  [@UP, @DOWN, @LEFT, @RIGHT]
  @DIAGONAL_DIRECTIONS:  [@TOP_LEFT, @TOP_RIGHT, @BOTTOM_LEFT, @BOTTOM_RIGHT]
  @ALL_DIRECTIONS:       [@UP..@BOTTOM_RIGHT]

  @getAlias: (dir) ->
    switch dir
      when @UP then return "Up"
      when @DOWN then return "Down"
      when @LEFT then return "Left"
      when @RIGHT then return "Right"
      when @TOP_LEFT then return "Top Left"
      when @TOP_RIGHT then return "Top Right"
      when @BOTTOM_LEFT then return "Bottom Left"
      when @BOTTOM_RIGHT then return "Bottom Right"
      else return "Unknown Direction"

  @getOppositeDirection: (dir) ->
    dir = @getDirections(dir) if typeof dir is "string"
    switch dir
      when @UP then return @DOWN
      when @DOWN then return @UP
      when @LEFT then return @RIGHT
      when @RIGHT then return @LEFT
      when @TOP_LEFT then return @BOTTOM_RIGHT
      when @TOP_RIGHT then return @BOTTOM_LEFT
      when @BOTTOM_LEFT then return @TOP_RIGHT
      when @BOTTOM_RIGHT then return @TOP_LEFT
      else return null

  @getRelation: (a, b) ->
    xRel = a.x - b.x
    yRel = a.y - b.y
    if yRel <= -1 # b is above a
      return @TOP_LEFT if xRel <= -1
      return @UP is xRel is 0
      return @TOP_RIGHT
    else if yRel is 0 # b is on the same row as a
      return @LEFT is xRel <= -1
      return -1 is xRel is 0
      return @RIGHT
    else # b is below a
      return @BOTTOM_RIGHT if xRel <= -1
      return @DOWN if xRel is 0
      return @BOTTOM_RIGHT

  constructor: (x, y, @__bgColor = "#000") ->
    super x, y
    @__encounters = []

  getBgColor: -> @__bgColor
  setBgColor: (@__bgColor = "#000") ->

  addEncounter: (weight = 1, encounterFn) ->
    wwt.util.validateNumber "weight", weight
    throw new Error("weight (#{weight}) cannot be less than 0") if weight < 0
    wwt.util.validateFunction "encounterFn", encounterFn
    @__encounters.push weight: weight, fn: encounterFn
    return @
  addEncounters: (encounters) -> @addEncounter weight, encounterFn for {weight, encounterFn} in @__encounters
  clearEncounters: -> @__encounters.splice 0
  getEncounters: -> @__encounters.slice 0
  randomEncounter: ->
    weightSum = 0
    weightSum += e.weight for e in @__encounters
    weights = []
    min = 0
    for e in @__encounters
      min = e.weight if min is 0
      weights.push (if weights.length > 0 then weights[weights.length - 1] else 0) + e.weight
    randomNum = (Math.random() * (weights[weights.length - 1] - min + 1)) + 1
    for w, i in weights
      lessThanNext = if i < weights.length -1 then randomNum < weights[i + 1] else true
      if randomNum >= w and lessThanNext
        encounter = @__encounters[i].fn
        encounter.call @
        return
    return @
