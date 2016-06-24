{RequireTree} = require  "./common"

classes = [
  "AI"
  "Arena"
  "Encounter"
  "Encounterable"
  "Environment"
  "Floor"
  "FloorRenderer"
  "Player"
  "PseudoPlayer"
  "Section"
  "SkillTree"
  "Town"
  "Weapon"
  "Window"
  "World"
  "Zone"
]

class Asc extends RequireTree

  constructor: ->
    super module, classes, "./Asc"

  init: ->
    $("head").append("<link rel='stylesheet' href='./css/asc.css'>")

module.exports = new Asc()
