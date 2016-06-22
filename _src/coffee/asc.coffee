{RequireTree} = require  "./common"

classes =
  Arena: "AscArena"
  Encounter: ""
  Encounterable: ""
  Environment: ""
  Floor: ""
  FloorRenderer: ""
  Player: ""
  Section: ""
  SkillTree: ""
  Town: ""
  Weapon: ""
  Zone: ""

class Asc extends RequireTree

  constructor: ->
    super module, classes, "./Asc"

module.exports = new Asc()
