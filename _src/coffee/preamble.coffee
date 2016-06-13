Journey      = require "./journey.js"
{Player}     = require "../asc"
fs           = require "fs"

PreambleArena = null
PreambleRegistration = null
specialThanks = null

hasBeenInit = false

selectFile = (title) ->
  return require("electron").remote.dialog.openSaveDialog null, {
    title: "Choose Save Location"
    filters: [{name: "JSON File", extensions: ["json"]}]
  }

module.exports =

  init: ->
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
    Journey.getSystemControl("new-game").addListener wwt.event.Selection, => @newGame()
    Journey.getSystemControl("save-game").addListener wwt.event.Selection, => @save()
    Journey.getSystemControl("quicksave").addListener wwt.event.Selection, => @quicksave()
    Journey.getSystemControl("settings").addListener wwt.event.Selection, => @settings()
    Journey.getSystemControl("user").addListener wwt.event.Selection, => @user()

    hasBeenInit = true
    @mainMenu()

  newGame: ->
    PreambleRegistration.done ->
      name = PreambleRegistration.getName()
      classification = PreambleRegistration.getClassification()
      kingdom = PreambleRegistration.getKingdom()
      gender = PreambleRegistration.getGender()
      weaponType = PreambleRegistration.getWeaponType()
      @Player = new Player(name, gender, classification, kingdom)
      @Data = {}
      floor = PreambleArena.getFloor(1)
      start = floor.getStartLocation() # {x, y}
      setCharacterLocation floor, start.x, start.y

    PreambleRegistration.start()

  mainMenu: ->
    Journey.reset()
    Journey.getButton(4, 0).setEnabled().setText("Special Thanks").addListener wwt.event.Selection, =>
      Journey.reset()
      Journey.getButton(0, 0).setEnabled(true).setText("Back").addListener wwt.event.Selection, => @mainMenu()
      Journey.getMainContent().append specialThanks
    Journey.getButton(0, 0).setEnabled(true).setText("New Game").addListener wwt.event.Selection, => @newGame()

  quicksave: -> @__saveAt @__lastFile

  save: ->
    filename = selectFile()
    @__saveAt filename

  __saveAt: (file) ->
    fs.writeFileSync filename, JSON.stringify @Data
    @__lastFile = filename

  load: ->
    file = selectFile()
    @Data = JSON.parse fs.readFileSync(file, "UTF-8")
    @__lastFile = file

  setCharacterLocation: (floor, x, y) ->
    @Data.location = {floor: floor ? @Data.location.floor, x, y}
    return @
  getCharacterLocation: -> @Data.location
  getCharacterArea: -> @Data.location.floor.getArea @Data.location.x, @Data.location.y

  __move:  (deltaX, deltaY) ->
    @setCharacterLocation @Data.location.floor, @Data.location.x + deltaX, @Data.location.y + deltaY
    return @
  up: -> __move 0, -1
  down: -> __move 0, 1
  left: -> __move -1, 0
  right: -> __move 1, 0

clazzes =
  AI: ""
  Arena: "PreambleArena"
  Registration: ""

for k, v of classes
  file = "./Preamble/#{if v.length is 0 then k else v}"
  fn = (f) -> return () ->
    require f
  Object.defineProperty(Preamble, k, {enumerable: true, get: fn(file)})
