Enum = require "../Common/Enum.js"

class Environment extends Enum.GenericIdEntry

  constructor: (id, name, @__color, @__accessible = true) ->
    super id, name

  getColor: -> @__color
  isAccessible: -> @__accessible

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
envs.__addValue("VOID", new Environment(0, "Void", "#000", false))

# Floor environment types - ids 1-9
envs.__addValue("FLOOR_PLAINS", new Environment(1, "Floor (Plains)", "#003e00"))

# Forest environments - ids 21 - 30
envs.__addValue("FOREST", new Environment(21, "Forest", "#38761d", false))
envs.__addValue("FOREST_DEEP", new Environment(22, "Forest (Deep)", false))
envs.__addValue("FOREST_PATH", new Environment(23, "Forest Path", false))

# Mountain environments - ids 31 - 40
envs.__addValue("MTN", new Environment(31, "Mountain", false))
envs.__addValue("MTN_CAVE", new Environment(32, "Mountain Cave"))
envs.__addValue("MTN_PATH", new Environment(33, "Mountain Path"))

# Town types, id = 100 + (corresponding floor type id)
envs.__addValue("TOWN_PLAINS", new Environment(101, "Town (Plains)"))

# Water environments - 41-50
envs.__addValue("WATER", new Environment(41, "Water", "#1c4587", false))
envs.__addValue("WATER_CROSSING", new Environment(42, "Water Crossing", "#775900"))
envs.__addValue("WATER_DEEP", new Environment(43, "Water (Deep)", "#20124d", false))
# envs.__addValue("WATER_SHALLOW", new Environment(44, "Water (Shallow)", ""))
