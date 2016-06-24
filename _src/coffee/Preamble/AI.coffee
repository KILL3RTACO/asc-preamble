{Enum} = require "../common"

{AI, World}   = require("../asc")
{Kingdom}     = World

module.exports = ais = new Enum()
ais.__addValue("IRIS", new AI(1, "Iris", "IRIS", 5, Kingdom.HELIX, "AM"))
ais.__addValue("SHERLOCK", new AI(2, "Sherlock", "SRLK", 5, Kingdom.VACANT, "PR"))
ais.__addValue("ADRIAN", new AI(3, "Adrian", "ADRN", 5, Kingdom.ARIA, "HK"))
