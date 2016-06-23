{Window, FloorRenderer} = require "../asc"

Preamble = require "../preamble"

class MapWindow extends Window

  constructor: ->
    super

  createContents: ->
    @addCloseButton()
    controlContainer = new wwt.Composite(@getContainer(), "MapWindow-Controls")

    player = Preamble.getPlayer()
    currentFloor = player.getCurrentFloor()
    @__floorCombo = new wwt.Combo(controlContainer, "").setItems("Floor #{i}" for i in [1..player.getMaxFloorTraversed()])

    $canvas = $("<canvas></canvas>")
    mapContainer = new wwt.Composite(@getContainer(), "MapWindow-MapContainer")
    mapContainer.append $canvas
    @__fr = new FloorRenderer()
    @__fr.setCanvas $canvas[0]

  selectFloor: (id = Preamble.getPlayer().getCurrentFloorId()) ->
    Preamble.Arena.loadIfUnloaded id
    floor = Preamble.Arena.get id
    @__floorCombo.setText("Floor #{id}")
    @__fr.setFloor floor
    @__fr.render()

    if floor.getId() is Preamble.getPlayer().getCurrentFloorId()
      xy = Preamble.getPlayer().getXY()
      @__fr.colorMarkerRaw xy.x, xy.y, "orange"

module.exports = new MapWindow()
