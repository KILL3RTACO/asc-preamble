# Asc
Environment   = require "../Asc/Environment.js"
FloorRenderer = require "../Asc/FloorRenderer.js"

# Preamble
Preamble = require "../preamble.js"

# Node
fs       = require "fs"

# GUI - Widget Declaration
env = floor = name = width = height = mapDataControl = paintOn = paintEnv = zoneId = pfControl = canvas = null

# util vars
envNames = (e.getName() for e in Environment.values())
util = null
selected = null

# GUI - Define and Layout Widgets
initGui = ->
  mainContainer = new wwt.Composite("", "mainContainer")

  env = new wwt.Combo(mainContainer, "environmentList").setItems(envNames).setText(Environment.FLOOR_PLAINS.getName())
  floor = new wwt.Combo(mainContainer, "floorList").setItems("Floor #{num}" for num in [1...100]).setText("Floor 1")
  name = new wwt.Text(mainContainer, "floorName").setPlaceholder("Floor Name")

  new wwt.Label(mainContainer, "floorSizeLabel").setText("Size:")
  width = new wwt.Spinner(mainContainer, "width").setMinimum(0)
  height = new wwt.Spinner(mainContainer, "height").setMinimum(0)

  mapDataControl = new wwt.ButtonGroup(mainContainer, "mapDataControl")
  mapDataControl.addButton("", "Clear")
  mapDataControl.addButton("", "Reset")

  mainContainer.append("<br/>")

  paintOn = new wwt.Check(mainContainer, "paintOn").setText("Paint").setState(true)
  paintEnv = new wwt.Combo(mainContainer, "paintEnv").setItems(["Default", envNames...]).setText("Default").setEnabled(paintOn.getState())

  new wwt.Label(mainContainer, "zoneIdLabel").setText("Zone ID:")
  zoneId = new wwt.Spinner(mainContainer, "zoneId").setMinimum(0)

  new wwt.Label(mainContainer, "pfControlLabel").setText("Pathfinder:")
  pfControl = new wwt.ButtonGroup(mainContainer, "pfControl")
  pfControl.addButton("", "Start")
  pfControl.addButton("", "Goal")
  pfControl.addButton("", "Run")

  mapContainer = new wwt.Composite("", "mapContainer")
  mapContainer.append("<canvas id='mrCanvas'></canvas>")
  canvas = $("#mrCanvas")[0]

  util = new EditorUtil()

# GUI - Listeners
initGuiListeners = ->
  env.addListener wwt.event.Selection, (e) ->
    util.floor.__environment = Environment.values()[e.index]
    util.save()

  floor.addListener wwt.event.Selection, (e) -> util.reloadAndSelect(e.index + 1)

  name.addListener wwt.event.Modify, (e) ->
    util.floor.__name = e.value
    util.save()

  sizeListener = (prop) ->
    return (e) ->
      util.floor[prop] = e.value
      util.save()
      util.reload()
      util.render()
  width.addListener wwt.event.Modify, sizeListener("__width")
  height.addListener wwt.event.Modify, sizeListener("__height")

  mapDataControl.getButton(0).addListener wwt.event.Selection, (e) -> util.clear(); util.save()
  mapDataControl.getButton(1).addListener wwt.event.Selection, (e) -> util.reset(); util.save()

  paintOn.addListener wwt.event.Selection, (e) -> paintEnv.setEnabled e.state

  $(canvas).mousedown (e) ->
    # If we are painting, edit the sections via paintEnv
    if paintOn.getState()
      util.selectSection null
      util.paintCell e

      $(this).mousemove (e) -> util.paintCell e
      $(this).mouseup -> $(this).off "mousemove"


    # Otherwise, select(mark) the clicked cell
    else
      util.selectSection util.getCell(e)
      util.render()
      util.fr.colorMarkerRaw selected.x, selected.y, "orange"

module.exports =

  start: ->
    wwt.init()
    $("head").append("<link rel='stylesheet' href='./css/editor.css'>")
    initGui()
    initGuiListeners()

class EditorUtil

  constructor: ->
    @arena = require "../Preamble/PreambleArena.js"
    @selected = null
    @fr = new FloorRenderer()
    @fr.setCanvas canvas
    @reloadAndSelect 1

  getCell: (e) ->
    pos = $(canvas).offset()
    return @fr.getCellLocation(e.pageX - pos.left, e.pageY - pos.top)

  paintCell: (e) ->
    currentCell = util.getCell e
    currentEnv = Environment.getEnvironment(paintEnv.getText())
    currentEnv ?= util.floor.getEnvironment()
    section = util.floor.get(currentCell.x, currentCell.y)
    created = false
    if section is null
      section = util.floor.createSection(currentCell.x, currentCell.y)
      created = true
    return if not created and section.getEnvironment().getId() is currentEnv.getId()
    section.__environment = currentEnv
    @save()
    @render()

  render: ->
    @fr.setFloor @floor
    @fr.render()

  selectSection: (section) ->
    @selected = section

  select: (id) ->
    (@getFloor(id)) if typeof id is "number"
    env.setText(@floor.getEnvironment().getName())
    name.setText(@floor.getName())
    width.setValue(@floor.getWidth())
    height.setValue(@floor.getHeight())
    @render()
  reload: (id = @floor.getId()) ->
    @arena.reloadFloor id, true
    @getFloor id
  reloadAndSelect: (id) ->
    @reload id
    @select()

  save: -> @arena.saveFloorState @floor.getId()
  get: (id) -> @arena.get id
  getFloor: (id = @floor.getId()) ->
    @floor = @get id
    @fr.setFloor @floor

  clear: ->
    @floor.__sections.splice 0
    @render()
  reset: ->
    @clear()
    @floor.__width = Floor.DEF_W
    @floor.__height = Floor.DEF_H
