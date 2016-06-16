module.exports = (Asc, Preamble, floor) ->

  START = {x: 21, y: 21}

  floor.setStartLocation START

  # Towns
  floor.addTown("Rubicon A", [
    {x: 20, y: 20}
    {x: 21, y: 20}
    {x: 20, y: 21}
    START
  ])

  floor.addTown("Rubicon B", [
    {x: 7, y: 20}
    {x: 7, y: 21}
  ])

  floor.addTown("Rubicon D", [ # We don't talk about Rubicon C...
    {x: 17, y: 11}
    {x: 18, y: 11}
    {x: 18, y: 12}
  ])

    # Encounters (Towns)
