# Common
{RequireTree} = require "./common"

Journey = require "./journey.js"

# Asc
Asc                            = require "./asc"
{FloorRenderer, Player, World} = Asc

# Node
fs = require "fs"

specialThanks = null

hasBeenInit = false

FILE = null
PLAYER = null

SAVE_DIR = "#{require("electron").remote.app.getAppPath()}/../saves"
SAVES = []

MR = null

keyFromFilename = (filename) ->
  return filename.substring filename.lastIndexOf("/") + 1, filename.lastIndexOf(".")

classes =
  AI: ""
  Arena: "PreambleArena"
  Registration: ""
  MapWindow: ""

class Preamble extends RequireTree

  constructor: ->
    super module, classes, "./Preamble"

  TOWN_ENCOUNTER: (town) ->
    {Encounter} = Asc
    return new Encounter "Floor #{town.getFloor().getId()}: #{town.getFloor().getName()}", "#{town.getName()}", "", 1, =>
      mButtons = @addMovementButtons()
      desc = town.getDescription()
      fullDesc = """
        #{@AI.ADRIAN.beginTransmissionHtml()}<br/><br/>

        #{desc}<br/><br/>

        #{@AI.ADRIAN.endTransmissionHtml()}
      """

      @enableMovement mButtons
      Journey.getButton(4, 0).setEnabled().setText("Town Center").addListener wwt.event.Selection, -> town.enterTownCenter()
      Journey.getMainContent().append(if desc then fullDesc else "")
      Journey.setButtonToDefault mButtons[mButtons.length - 1]
      @addMapButton()

  addTown: (floor, name, sections) ->
    town = floor.addTown(name, sections)
    town.setEncounter @TOWN_ENCOUNTER(town)
    return town

  init: ->
    return if hasBeenInit
    Journey.init()
    Asc.init()

    $("head").append "<link rel='stylesheet' href='./css/preamble.css'>"

    # Show a loading screen until most of the loading that needs to be done is finished
    loadingLabel = new wwt.Label(Journey.getMainContent(), "loadingLabel").setText("Loading...");
    loadingProgress = new wwt.ProgressBar(Journey.getMainContent(), "loadingBar").setIndeterminate();

    specialThanks = fs.readFileSync("#{__dirname}/../special-thanks.html", "UTF-8")

    Journey.getSystemControl("main-menu").setEnabled().addListener wwt.event.Selection, => @mainMenu()
    Journey.getSystemControl("settings").addListener wwt.event.Selection, => @settings()
    Journey.getSystemControl("user").addListener wwt.event.Selection, => @user()
    Journey.getSystemControl("new-game").setEnabled().addListener wwt.event.Selection, => @newGame()
    Journey.getSystemControl("save-game").addListener wwt.event.Selection, => @save()
    Journey.getSystemControl("load-game").setEnabled().addListener wwt.event.Selection, => @loadScreen()

    hasBeenInit = true
    @mainMenu()

  newGame: ->
    @Registration.done =>
      name = @Registration.getName()
      classification = @Registration.getClassification()
      kingdom = @Registration.getKingdom()
      gender = @Registration.getGender()
      weaponType = @Registration.getWeaponType()
      PLAYER = new Player(name, gender, classification, kingdom)
      resolvedPlayerName = name.toLowerCase().replace(/[\s+_]/, "-")
      FILE = @getSaveFile resolvedPlayerName
      PLAYER.setLocation(@Arena.get(1, true, true).getStartLocation())
      @save()
      @updatePlayer()

    @Registration.start()

  mainMenu: ->
    Journey.reset({map: true})
    Journey.getButton(0, 0).setEnabled(true).setText("New Game").addListener wwt.event.Selection, => @newGame()
    Journey.getButton(1, 0).setEnabled(true).setText("Load Game").addListener wwt.event.Selection, => @loadScreen()
    Journey.getButton(4, 0).setEnabled().setText("Special Thanks").addListener wwt.event.Selection, =>
      Journey.reset()
      Journey.getButton(0, 0).setEnabled(true).setText("Back").addListener wwt.event.Selection, => @mainMenu()
      Journey.getMainContent().append specialThanks

  load: (file) ->
    FILE = file
    try
      json = JSON.parse(fs.readFileSync file)
    catch err
      alert "File #{FILE} may be missing or corrupted."
      return
    PLAYER = Player.fromJson json.player, @Arena
    @updatePlayer()

  loadScreen: ->
    {Player} = Asc
    selected = null
    selectedContainer = null

    loadSelected = => @load @getSaveFileName selected

    updateButtons = ->
      Journey.getButton(1, 0).setEnabled(selected isnt null)
      Journey.getButton(2, 0).setEnabled(selected isnt null)

    addListener = (container, key) ->
      container.$__element.click (e) ->
          selectedContainer.removeClass("selected") if selectedContainer isnt null
          container.addClass("selected")
          selected = key
          selectedContainer = container
          updateButtons()
      container.$__element.dblclick -> loadSelected()

    Journey.reset({map: true})
    SAVES = {}
    try
      files = fs.readdirSync SAVE_DIR
      for f in files
        try
          json = JSON.parse fs.readFileSync("#{SAVE_DIR}/#{f}")
          if json and json.player
            SAVES[keyFromFilename f] = json.player
        catch
          continue

    catch err

    keys = (k for k of SAVES)

    keys.sort (a, b) -> SAVES[a].name.localeCompare(SAVES[b].name)

    for key in keys
      playerInfo = SAVES[key]
      location = playerInfo.location
      gender = Player.Gender.valueOf(playerInfo.gender).getName()
      classification = Player.ClassificationType.valueOf(playerInfo.classification).getName()
      kingdom = World.Kingdom.valueOf(playerInfo.kingdom).getName()
      container = new wwt.Composite(Journey.getMainContent(), "").addClass("load-screen-save").addClass("noselect")
      container.append """
        <span class='load-screen-save-name'>#{playerInfo.name}</span>
        <div class='load-screen-save-meta'>
          <span class='load-screen-save-meta-item'>#{Journey.glyphicon("user")} #{gender}</span>
          <span class='load-screen-save-meta-item'>#{Journey.glyphicon("list")} #{classification}</span>
          <span class='load-screen-save-meta-item'>#{Journey.glyphicon("tower")} #{kingdom}</span>
        </div>
        <div class='load-screen-save-location'>
          <b>Floor</b>: #{location.floor} (#{location.floorName})<br/>
          <b>Area</b>: #{location.areaName} -- (#{location.x}, #{location.y})
        </div>
      """
      addListener container, key

    Journey.getButton(0, 0).setText("Back").setEnabled().addListener wwt.event.Selection, => @mainMenu()
    Journey.getButton(1, 0).setText("Load").addListener wwt.event.Selection, => loadSelected()
    Journey.getButton(2, 0).setText("Delete").addListener wwt.event.Selection, =>
      SAVES[selected] = undefined if selected
      fs.unlink @getSaveFileName(selected)
      selectedContainer.dispose()
      selectedContainer = null
      selected = null
      updateButtons()

  getSaveFileName: (name) -> "#{SAVE_DIR}/#{name}.json"

  getSaveFile: (name) ->
    num = ""
    while true
      fullname = @getSaveFileName(name + num)
      try
        fs.accessSync fullname
        num = if num.length is 0 then 1 else num + 1
      catch
        return fullname

  save: (file = FILE) ->
    json = {}
    json.player = PLAYER.toJson()
    try
      fs.mkdirSync SAVE_DIR
    catch
    fs.writeFile file, JSON.stringify(json)

  addMovementButtons: (resetButtons = false) ->
    Journey.resetButtons() if resetButtons
    buttons = [] # This array is compatible with Section.UP, DOWN, etc..
    buttons.push Journey.getButton(1, 0).setText("North")
    buttons.push Journey.getButton(1, 2).setText("South")
    buttons.push Journey.getButton(2, 1).setText("West")
    buttons.push Journey.getButton(0, 1).setText("East")
    buttons.push Journey.getButton(0, 0).setText("Northwest")
    buttons.push Journey.getButton(2, 0).setText("Northeast")
    buttons.push Journey.getButton(0, 2).setText("Southwest")
    buttons.push Journey.getButton(2, 2).setText("Southeast")
    buttons.push Journey.getButton(1, 1).setText("Explore")

    return buttons

  enableMovement: (buttons = @addMovementButtons()) ->
    dirs = Asc.Section.ALL_DIRECTIONS
    for d in dirs
      do (d) ->
        b = buttons[d]
        b.setEnabled(PLAYER.canMove(d))
        if b.isEnabled()
          b.addListener wwt.event.Selection, => PLAYER.move d

    explore = buttons[dirs.length]
    location = PLAYER.getLocation()
    explore.setEnabled(location.getEncounterSize() > 0)
    if explore.isEnabled()
      explore.addListener wwt.event.Selection, ->
        location.randomEncounter().run()

  addMapButton: ({x = 4, y = 2} = {}) ->
    button = Journey.getButton(x, y)
    Journey.setButtonToDefault button
    button.setEnabled()
    button.setText "Map"
    button.setTooltip "View a map of the current floor you are on"
    button.addListener wwt.event.Selection, => @MapWindow.open().selectFloor()

  updateMap: (clear = false) ->
    if clear
      MR = null
      Journey.clearMapContainer()
      return @

    if MR is null
      $canvas = $("<canvas id='preamble-minimap'></canvas>")
      Journey.getMapContainer().append $canvas
      MR = new FloorRenderer()
      MR.setCanvas $canvas[0]
      MR.setCellSize 25

    MR.setFloor PLAYER.getLocation().getFloor()
    MR.render()
    location = PLAYER.getLocation()
    MR.colorMarkerRaw location.getX(), location.getY(), "orange"

    offsetLocation = {x: Math.max(0, location.getX() - 3), y: Math.max(0, location.getY() - 3)}
    offsetLeft = MR.getOffset offsetLocation.x
    offsetTop = MR.getOffset offsetLocation.y
    Journey.getMapContainer().$__element.scrollTop offsetTop
    Journey.getMapContainer().$__element.scrollLeft offsetLeft

  getPlayer: -> PLAYER

  updatePlayer: (lookForEncounter = true) ->
    Journey.reset({map: false})
    @updateMap()
    encounter = if lookForEncounter then PLAYER.getLocation().randomEncounter() else null
    if encounter is null # Section has no encounter or disabled
      @enableMovement @addMovementButtons()
    else
      encounter.run()

    return @

module.exports = new Preamble()
