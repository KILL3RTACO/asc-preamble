# Asc
{Environment, FloorRenderer} = require "../asc"

# Node
fs       = require "fs"

# GUI - Widget Declaration
env = floor = name = width = height = mapDataControl = paintOn = paintEnv = zoneId = pfControl = canvas = null

getFloorEnvName = (name) -> name.substring("Floor (".length, name.length - 1)

# util vars
envNames = (e.getName() for e in Environment.values() when not (e.isFloorEnvironment() or e.isTownEnvironment()))
floorEnvNames = (getFloorEnvName(e.getName()) for e in Environment.values() when e.isFloorEnvironment())
util = null
selected = null

# GUI - Define and Layout Widgets
initGui = ->
  mainContainer = new wwt.Composite("", "mainContainer")

  env = new wwt.Combo(mainContainer, "environmentList").setItems(floorEnvNames)
  floor = new wwt.Combo(mainContainer, "floorList").setItems("Floor #{num}" for num in [1...100])
  name = new wwt.Text(mainContainer, "floorName").setPlaceholder("Floor Name")

  new wwt.Label(mainContainer, "floorSizeLabel").setText("Size:")
  width = new wwt.Spinner(mainContainer, "width").setMinimum(0)
  height = new wwt.Spinner(mainContainer, "height").setMinimum(0)

  mapDataControl = new wwt.ButtonGroup(mainContainer, "mapDataControl")
  mapDataControl.addButton("", "Clear")
  mapDataControl.addButton("", "Reset")

  mainContainer.append("<br/>")

  paintOn = new wwt.Check(mainContainer, "paintOn").setText("Paint")
  paintEnv = new wwt.Combo(mainContainer, "paintEnv").setItems(["Default", "Town", envNames...])

  new wwt.Label(mainContainer, "pfControlLabel").setText("Pathfinder:")
  pfControl = new wwt.ButtonGroup(mainContainer, "pfControl")
  pfControl.addButton("", "Start")
  pfControl.addButton("", "Goal")
  pfControl.addButton("", "Clear")
  pfControl.addButton("", "Run")
  pfControl.setEnabled(false)

  mapContainer = new wwt.Composite("", "mapContainer")
  mapContainer.append("<canvas id='mrCanvas'></canvas>")
  canvas = $("#mrCanvas")[0]

  util = new EditorUtil()
  util.materializeState()

# GUI - Listeners
initGuiListeners = ->
  env.addListener wwt.event.Selection, (e) ->
    util.floor.__environment = Environment.getEnvironment(e.index + 1)
    for s in util.floor.__sections
      continue if s is null or s is undefined
      if s.getEnvironment().isFloorEnvironment()
        s.__environment = util.floor.getEnvironment()
      else if s.getEnvironment().isTownEnvironment()
        s.__environment = util.floor.getEnvironment().getTownEnvironment()
    util.render()
    util.save()

  floor.addListener wwt.event.Selection, (e) ->
    util.clearPf()
    util.reloadAndSelect(e.index + 1)
    util.state.floor = e.index + 1
    util.saveState()

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

  pfListener = (prop) ->
    return () ->
      util.pf[prop] = util.selected
      util.updatePathfinderControl()
      util.selectSection null
      util.render()
      util.state.pf = util.pf
      util.saveState()
  pfControl.getButton(0).addListener wwt.event.Selection, pfListener("start")
  pfControl.getButton(1).addListener wwt.event.Selection, pfListener("goal")
  pfControl.getButton(2).addListener wwt.event.Selection, ->
    util.clearPf()
    util.selectSection null
    util.render()
    util.updatePathfinderControl()
  pfControl.getButton(3).addListener wwt.event.Selection, ->
    path = null
    try
      path = util.floor.findPath(util.pf.start, util.pf.goal)
    catch error
      alert(error)
      return

    if path is null
      alert("Pathfinder Error - Could not find a path")
      return

    util.fr.colorPathRaw(path, "orange")

  paintOn.addListener wwt.event.Selection, (e) ->
    util.selectSection null
    util.render()
    paintEnv.setEnabled e.state
    util.state.paint = e.state
    util.saveState()

  paintEnv.addListener wwt.event.Selection, (e) ->
    util.state.env = e.selection
    util.saveState()

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
      util.saveState()

module.exports =

  start: ->
    wwt.init()
    $("head").append("<link rel='stylesheet' href='./css/editor.css'>")
    initGui()
    initGuiListeners()

class EditorUtil

  @CLEAR_PF: {start: null, goal: null}
  @STATE_FILE: "#{__dirname}/EditorState.json"

  constructor: ->
    @loadState()
    @arena = require "../Preamble/PreambleArena.js"
    @fr = new FloorRenderer()
    @fr.setCanvas canvas

  loadState: ->
    try
      @state = JSON.parse(fs.readFileSync(@constructor.STATE_FILE, "utf8"))
    catch error
      @state =
        floor: 1
        paint: true
        pf: @pf ? @constructor.CLEAR_PF
        selected: null
        env: "Default"
      @saveState()
  saveState: -> fs.writeFile @constructor.STATE_FILE, JSON.stringify(@state)
  materializeState: ->
    @pf = @state.pf
    @updatePathfinderControl()

    @selectSection(@state.selected)

    floor.setText("Floor #{@state.floor}")
    @reloadAndSelect(@state.floor)

    paintOn.setState(@state.paint)
    paintEnv.setEnabled(paintOn.getState())
    paintEnv.setText(@state.env)

  clearPf: ->
    @pf = @constructor.CLEAR_PF
    @state.pf = @constructor.CLEAR_PF
    @saveState()
    return @

  updatePathfinderControl: ->
    pfControl.getButton(2).setEnabled(@pf.start isnt null or @pf.goal isnt null)
    pfControl.getButton(3).setEnabled(@pf.start isnt null and @pf.goal isnt null)

  getCell: (e) ->
    pos = $(canvas).offset()
    return @fr.getCellLocation(e.pageX - pos.left, e.pageY - pos.top)

  paintCell: (e) ->
    currentCell = util.getCell e
    if @lastPainted is null or @lastPainted is undefined or @lastPainted.x isnt currentCell.x or @lastPainted.y isnt currentCell.y
      @lastPainted = currentCell
    else
      return

    currentEnv = switch paintEnv.getText()
      when "Default" then @floor.getEnvironment()
      when "Town" then @floor.getEnvironment().getTownEnvironment()
      else Environment.getEnvironment(paintEnv.getText())

    console.log currentEnv

    section = @floor.get(currentCell.x, currentCell.y)
    created = false
    if section is null
      section = @floor.createSection(currentCell.x, currentCell.y)
      created = true
    return if not created and section.getEnvironment().getId() is currentEnv.getId()
    if paintEnv.getText() is "Default"
      section.__environment = floor.getEnvironment()
    else
      section.__environment = currentEnv
    @save()
    @render()

  render: ->
    @fr.setFloor @floor
    @fr.render()
    if @pf.start
      @fr.colorMarkerRaw @pf.start.x, @pf.start.y, "#0F0"
    if @pf.goal
      @fr.colorMarkerRaw @pf.goal.x, @pf.goal.y, "#F00"
    if @selected
      util.fr.colorMarkerRaw @selected.x, @selected.y, "orange"

  selectSection: (section) ->
    @selected = section
    @state.selected = section
    pfControl.getButton(0).setEnabled(section isnt null)
    pfControl.getButton(1).setEnabled(section isnt null)

  select: (id) ->
    (@getFloor(id)) if typeof id is "number"
    env.setText(getFloorEnvName(@floor.getEnvironment().getName()))
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
    @floor.fillRemaining()
    @render()
  reset: ->
    @clear()
    @floor.__width = Floor.DEF_W
    @floor.__height = Floor.DEF_H
