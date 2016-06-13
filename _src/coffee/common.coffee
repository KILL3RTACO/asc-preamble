classes =
  Enum: ""
  GridUtil: ""
  MapRenderer: ""
  Pathfinder: ""
  Util: ""

module.exports = class Common

for k, v of classes
  file = "./Common/#{if v.length is 0 then k else v}"
  fn = (f) -> return () ->
    require f
  Object.defineProperty(Common, k, {enumerable: true, get: fn(file)})
