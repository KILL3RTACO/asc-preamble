classes =
  arena: "AscArena"
  encounter: "Encounter"
  encounterable: "Encounterable"
  environment: "Environment"
  floor: "Floor"
  "floor-renderer": "FloorRenderer"
  player: "Player"
  section: "Section"
  "skill-tree": "SkillTree"
  town: "Town"
  weapon: "Weapon"
  zone: "Zone"

class Asc

  require: (depend) -> return require "./Asc/#{v}" for k, v of classes when k is depend

module.exports = new Asc()
