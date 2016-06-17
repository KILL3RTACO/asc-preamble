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

module.exports = class Asc

  # functions will go here, someday...

for k, v of classes
  file = "./Asc/#{if v.length is 0 then k else v}"
  fn = (f) -> return () ->
    require f
  Object.defineProperty(Asc, k, {enumerable: true, get: fn(file)})
