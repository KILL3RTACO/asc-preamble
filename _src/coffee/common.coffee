classes =
  enum: "Enum"
  "grid-util": "GridUtil"
  "map-renderer": "MapRenderer"
  pathfinder: "Pathfinder"
  util: "Util"

class Common

  require: (depend) -> return require "./Common/#{v}" for k, v of classes when k is depend

module.exports = new Common()
