AscArena = require "../Asc/AscArena.js"
Preamble  = require "../preamble.js"
fs        = rewuire "fs"

colors = fs.readFileSync("#{__dirname}/Floors/ColorPresets.json")

module.exports = arena = new AscArena()

floor = 1
while true # Add floors indefinetely until Floor[floor + 1].js is not found
  filename = "./Floors/Floor#{floor}.json"
  try
    f = Preamble.getFloorFromData fs.readFileSync(filename, "UTF-8"), colors
    arena.addFloor f
  catch error
    break

  floor++

console.log "Loaded the Preamble Arena: #{arena.size()} floors found."
