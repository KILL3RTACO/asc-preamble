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
  Window: ""
  Zone: ""

class Asc extends RequireTree

  constructor: ->
    super module, classes, "./Asc"

  init: ->
    $("head").append("<link rel='stylesheet' href='./css/asc.css'>")

module.exports = new Asc()
