Enum = require "../Common/Enum.js"

class Environment extends Enum.GenericIdEntry

  constructor: (id, name, @__color, @__blacklist = []) ->
    super id, name

  getColor: -> @__color

  isAccessibleFrom: (environment) ->
    return true if @__blacklist.length is 0 or (environment isnt null and environment.getId() is @__id)
    return false if @__blacklist[0] is "*"
    return false for name in @__blacklist when envs[name] is environment
    return true

  # Environments 1-9 are floor environments
  isFloorEnvironment: -> return 1 <= @getId() <= 9

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

module.exports = envs = new EnvironmentEnum()

# Void - id 0
envs.__addValue("VOID", new Environment(0, "Void", "#000", ["*"]))

# Floor environment types - ids 1-9
envs.__addValue("FLOOR_PLAINS", new Environment(1, "Floor (Plains)", "#003e00"))

# Forest environments - ids 21 - 30
envs.__addValue("FOREST", new Environment(21, "Forest", "#38761d", ["*"]))
envs.__addValue("FOREST_DEEP", new Environment(22, "Forest (Deep)", "#274e13", ["*"]))
envs.__addValue("FOREST_PATH", new Environment(23, "Forest Path", "#459223"))

# Mountain environments - ids 31 - 40
envs.__addValue("MTN", new Environment(31, "Mountain", "#775900", ["*"]))
envs.__addValue("MTN_CAVE", new Environment(32, "Mountain Cave", "#674d00", ["MTN_PATH"]))
envs.__addValue("MTN_PATH", new Environment(33, "Mountain Path", "#906c00", ["MTN_CAVE"]))

# Town types, id = 100 + (corresponding floor type id)
envs.__addValue("TOWN_PLAINS", new Environment(101, "Town (Plains)", "#999"))

# Water environments - 41-50
envs.__addValue("WATER", new Environment(41, "Water", "#1c4587", ["*"]))
envs.__addValue("WATER_CROSSING", new Environment(42, "Water Crossing", "#775900"))
envs.__addValue("WATER_DEEP", new Environment(43, "Water (Deep)", "#20124d", ["*"]))
