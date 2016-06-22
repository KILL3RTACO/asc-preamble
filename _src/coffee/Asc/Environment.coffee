{Enum} = require "../common"

class Environment extends Enum.GenericIdEntry

  constructor: (id, name, @__movementCost,  @__color, @__list = [], @__black = true) ->
    super id, name

  getColor: -> @__color

  isAccessibleFrom: (environment) ->
    return true if @__black and @__list.length is 0 or (environment isnt null and environment isnt undefined and environment.getId() is @__id)
    return false if @__black and @__list[0] is "*"
    return not @__black for name in @__list when envs[name] is environment
    return @__black

  # Environments 1-9 are floor environments
  isFloorEnvironment: -> return 1 <= @getId() <= 9
  isTownEnvironment: -> return 101 <= @getId() <= 109

  getFloorEnvironment: ->
    switch this
      when envs.TOWN_PLAINS then return envs.FLOOR_PLAINS
      when envs.TOWN_SNOW then return envs.FLOOR_SNOW
      else return this

  getTownEnvironment: ->
    switch this
      when envs.FLOOR_PLAINS then return envs.TOWN_PLAINS
      when envs.FLOOR_SNOW then return envs.TOWN_SNOW
      else return this

class EnvironmentEnum extends Enum

  constructor: ->
    super

  getEnvironment: (id) ->
    if typeof id is "number"
      env = (=> return e for e in @values() when e.getId() is id)()
    else if typeof id is "string"
      env = (=> return e for e in @values() when e.getName() is id)()
    else
      return null

    return null if env is null or env is undefined
    return env

  getTownEnvironment: (id) -> return @getEnvironment(100 + id)

module.exports = envs = new EnvironmentEnum()

# Void - id 0
envs.__addValue("VOID", new Environment(0, "Void", 100, "#000", ["*"]))

# Floor environment types - ids 1-9
envs.__addValue("FLOOR_PLAINS", new Environment(1, "Floor (Plains)", 1, "#003e00"))
envs.__addValue("FLOOR_SNOW", new Environment(2, "Floor (Snow)", 1, "#ccc"))

# Forest environments - ids 21 - 30
envs.__addValue("FOREST", new Environment(21, "Forest", 100, "#38761d", ["*"]))
envs.__addValue("FOREST_DEEP", new Environment(22, "Forest (Deep)", 1, "#274e13", ["*"]))
envs.__addValue("FOREST_PATH", new Environment(23, "Forest Path", 1, "#459223"))

# Mountain environments - ids 31 - 40
envs.__addValue("MTN", new Environment(31, "Mountain", 100, "#775900", ["*"]))
envs.__addValue("MTN_CAVE", new Environment(32, "Mountain Cave", 1, "#674d00", ["MTN_PATH"]))
envs.__addValue("MTN_PATH", new Environment(33, "Mountain Path", 1, "#906c00", ["MTN_CAVE"]))

# Town types, id = 100 + (corresponding floor type id)
envs.__addValue("TOWN_PLAINS", new Environment(101, "Town (Plains)", 1, "#999"))
envs.__addValue("TOWN_SNOW", new Environment(102, "Town (Snow)", 1, "#777"))

# Water environments - 41-50
envs.__addValue("WATER", new Environment(41, "Water", 100, "#1c4587", ["WATER_DEEP"], false))
envs.__addValue("WATER_CROSSING", new Environment(42, "Water Crossing", 1, "#775900"))
envs.__addValue("WATER_DEEP", new Environment(43, "Water (Deep)", 100, "#20124d", ["WATER"], false))
