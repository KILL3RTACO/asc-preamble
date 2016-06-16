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

module.exports = class Preamble

  @init: ->
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
    Preamble.mainMenu()
    Preamble.newGame()

  @newGame: ->
    PreambleRegistration.done ->
      PreambleArena.loadIfUnloaded 1
      name = PreambleRegistration.getName()
      classification = PreambleRegistration.getClassification()
      kingdom = PreambleRegistration.getKingdom()
      gender = PreambleRegistration.getGender()
      weaponType = PreambleRegistration.getWeaponType()
      PLAYER = new Player(name, gender, classification, kingdom)
      FILE = Preamble.getSaveFile name.toLowerCase().replace(/[\s+_]/, "-")
      PLAYER.setLocation(PreambleArena.get(1).getStartLocation())
      Preamble.updatePlayer()

    PreambleRegistration.start()

  @mainMenu: ->
    Journey.reset()
    Journey.getButton(4, 0).setEnabled().setText("Special Thanks").addListener wwt.event.Selection, ->
      Journey.reset()
      Journey.getButton(0, 0).setEnabled(true).setText("Back").addListener wwt.event.Selection, -> Preamble.mainMenu()
      Journey.getMainContent().append specialThanks
    Journey.getButton(0, 0).setEnabled(true).setText("New Game").addListener wwt.event.Selection, -> Preamble.newGame()

  @load: (file) ->
    PFILE = file
    json = JSON.parse(fs.readFileSync file)
    PLAYER = Player.fromJson json.player

  @loadScreen: ->

  @getSaveFileName: (name) -> "#{__dirname}/Preamble/Saves/#{name}.json"

  @getSaveFile: (name) ->
    num = ""
    while true
      fullname = Preamble.getSaveFileName(name + num)
      try
        fs.accessSync fullname
        num = if num.length is 0 then 1 else num + 1
      catch
        return Preamble.getSaveFileName fullname

  @save: (file = @__file) ->
    json = {}
    json.player = PLAYER.toJson()
    fs.writeFileSync FILE, JSON.stringify(json)

  @addMovementButtons: (resetButtons = false) ->
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

  @enableMovement: (buttons) ->
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

  @updatePlayer: (lookForEncounter = true) ->
    Journey.reset()
    encounter = if lookForEncounter then PLAYER.getLocation().randomEncounter() else null
    if encounter is null # Section has no encounter or disabled
      Preamble.enableMovement Preamble.addMovementButtons()
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
