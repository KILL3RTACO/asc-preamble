Journey      = require "./journey.js"
Asc          = require "./asc"
{Player}     = Asc
fs           = require "fs"

PreambleArena = null
PreambleRegistration = null
specialThanks = null

hasBeenInit = false

FILE = null
PLAYER = null

SAVE_CACHE = {}
SAVE_CACHE_FILE = "#{__dirname}/Preamble/.save-cache.json"
SAVE_CACHE_KEY = ""

keyFromFilename = (filename) ->
  return filename.substring filename.lastIndexOf("/") + 1, filename.lastIndexOf(".")

module.exports = class Preamble

  @init: =>
    return if hasBeenInit
    Journey.init()
    $("head").append "<link rel='stylesheet' href='./css/preamble.css'>"

    # Show a loading screen until most of the loading that needs to be done is finished
    loadingLabel = new wwt.Label(Journey.getMainContent(), "loadingLabel").setText("Loading...");
    loadingProgress = new wwt.ProgressBar(Journey.getMainContent(), "loadingBar").setIndeterminate();

    #Initialize the Arena
    PreambleArena = require "./Preamble/PreambleArena.js"
    PreambleRegistration = require "./Preamble/Registration.js"

    specialThanks = fs.readFileSync("#{__dirname}/../special-thanks.html", "UTF-8")

    Journey.getSystemControl("main-menu").addListener wwt.event.Selection, => @mainMenu()
    Journey.getSystemControl("settings").addListener wwt.event.Selection, => @settings()
    Journey.getSystemControl("user").addListener wwt.event.Selection, => @user()
    Journey.getSystemControl("new-game").addListener wwt.event.Selection, => @newGame()
    Journey.getSystemControl("save-game").addListener wwt.event.Selection, => @save()
    Journey.getSystemControl("load-game").addListener wwt.event.Selection, => @loadScreen()

    hasBeenInit = true
    @reloadSaveCache()
    @loadScreen()

  @checkSaveCache: ->
    try
      fs.accessSync SAVE_CACHE_FILE
      return false
    catch
      fs.writeFileSync SAVE_CACHE_FILE, "{}"
      return true
  @reloadSaveCache: =>
    created = @checkSaveCache()
    SAVE_CACHE = if created then {} else JSON.parse(fs.readFileSync SAVE_CACHE_FILE, "UTF-8")
  @updateSaveCacheFile: -> fs.writeFile SAVE_CACHE_FILE, JSON.stringify(SAVE_CACHE)
  @updateSaveCache: ->
    SAVE_CACHE[SAVE_CACHE_KEY] = PLAYER.toJson()
    @updateSaveCacheFile()

  @newGame: =>
    PreambleRegistration.done =>
      name = PreambleRegistration.getName()
      classification = PreambleRegistration.getClassification()
      kingdom = PreambleRegistration.getKingdom()
      gender = PreambleRegistration.getGender()
      weaponType = PreambleRegistration.getWeaponType()
      PLAYER = new Player(name, gender, classification, kingdom)
      playerFileName = name.toLowerCase().replace(/[\s+_]/, "-")
      FILE = @getSaveFile playerFileName
      PLAYER.setLocation(PreambleArena.get(1).getStartLocation())
      SAVE_CACHE_KEY = keyFromFilename FILE
      @save()
      @updatePlayer()

    PreambleRegistration.start()

  @mainMenu: =>
    Journey.reset()
    Journey.getButton(4, 0).setEnabled().setText("Special Thanks").addListener wwt.event.Selection, ->
      Journey.reset()
      Journey.getButton(0, 0).setEnabled(true).setText("Back").addListener wwt.event.Selection, -> @mainMenu()
      Journey.getMainContent().append specialThanks
    Journey.getButton(0, 0).setEnabled(true).setText("New Game").addListener wwt.event.Selection, -> @newGame()

  @load: (file) =>
    FILE = file
    SAVE_CACHE_KEY = keyFromFilename FILE
    json = JSON.parse(fs.readFileSync file)
    PLAYER = Player.fromJson json.player, PreambleArena
    @updatePlayer()

  @loadScreen: =>
    selected = null
    selectedContainer = null

    updateButtons = ->
      Journey.getButton(0, 0).setEnabled(selected isnt null)
      Journey.getButton(1, 0).setEnabled(selected isnt null)

    Journey.reset()
    keys = (k for k of SAVE_CACHE)
    keys.sort (a, b) -> return a.localeCompare(b)
    for key in keys
      playerInfo = SAVE_CACHE[key]
      location = playerInfo.location
      gender = Asc.Player.Gender.valueOf(playerInfo.gender).getName()
      classification = Asc.Player.ClassificationType.valueOf(playerInfo.classification).getName()
      kingdom = Asc.Player.Kingdom.valueOf(playerInfo.kingdom).getName()
      container = new wwt.Composite(Journey.getMainContent(), "").addClass("load-screen-save")
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
      container.$__element.click -> do (key) ->
        selectedContainer.removeClass("selected") if selectedContainer isnt null
        container.addClass("selected")
        selected = key
        selectedContainer = container
        updateButtons()

    Journey.getButton(0, 0).setText("Load").addListener wwt.event.Selection, => @load @getSaveFileName selected
    Journey.getButton(1, 0).setText("Delete").addListener wwt.event.Selection, =>
      SAVE_CACHE[selected] = undefined
      @updateSaveCacheFile()
      fs.unlink @getSaveFileName(selected)
      selectedContainer.dispose()
      selectedContainer = null
      selected = null
      updateButtons()

  @getSaveFileName: (name) => "#{__dirname}/Preamble/Saves/#{name}.json"

  @getSaveFile: (name) =>
    num = ""
    while true
      fullname = @getSaveFileName(name + num)
      try
        fs.accessSync fullname
        num = if num.length is 0 then 1 else num + 1
      catch
        return fullname

  @save: (file = FILE) =>
    json = {}
    json.player = PLAYER.toJson()
    fs.writeFile FILE, JSON.stringify(json)
    @updateSaveCache()

  @addMovementButtons: (resetButtons = false) =>
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

  @enableMovement: (buttons = @addMovementButtons()) =>
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

  @updatePlayer: (lookForEncounter = true) =>
    Journey.reset()
    encounter = if lookForEncounter then PLAYER.getLocation().randomEncounter() else null
    if encounter is null # Section has no encounter or disabled
      @enableMovement @addMovementButtons()
    else
      encounter.run()

    return @

classes =
  AI: ""
  Arena: "PreambleArena"
  Registration: ""

for k, v of classes
  file = "./Preamble/#{if v.length is 0 then k else v}"
  fn = (f) -> return () ->
    require f
  Object.defineProperty(Preamble, k, {enumerable: true, get: fn(file)})
