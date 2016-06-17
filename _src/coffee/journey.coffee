"use strict"
((factory) ->
  wwt = if window.wwt then window.wwt else require "wwt"

  throw new Error("Journey requires WWT") if not wwt

  if typeof module is "object" and typeof module.exports is "object"
    factory wwt, module.exports, wwt.electron
  else
    factory wwt, (window.Journey = {})
)((wwt, root, electron) ->
  left = null
  mainContent = null
  buttonContainer = null
  buttons = []
  right = null
  newGame = null
  loadGame = null
  saveGame = null
  quicksaveGame = null
  mainMenu = null
  settings = null
  user = null

  placeTitle = null
  placeLine1 = null
  placeLine2 = null

  BTN_ROWS = 3
  BTN_COLS = 5

  hasBeenInit = false

  testX = (x) -> throw new Error("x (#{x}) is out of bounds (0-#{BTN_COLS - 1})") if not (typeof x is "number" and 0 <= x < BTN_COLS)
  testY = (y) -> throw new Error("y (#{y}) is out of bounds (0-#{BTN_ROWS - 1})") if not (typeof y is "number" and 0 <= y < BTN_ROWS)
  testBounds = (x, y) ->
    testX x
    testY y
    return

  getIndex = (x, y) ->
    testBounds x, y
    return (BTN_COLS * y) + x

  hideIfEmpty = (label) ->
    text = label.getText()
    condition = text is null or text is ""
    if condition
      label.$__parent.css display: "none"
    else
      label.$__parent.css display: ""

  root.init = ->
    return if hasBeenInit
    wwt.init()
    $("head").append("<link rel='stylesheet' href='./css/bootstrap-glyphicons.css'>")
    $("head").append("<link rel='stylesheet' href='./css/journey.css'/>")
    $("head").append("<link id='journey_theme' rel='stylesheet' href='./css/journey-theme-default.css'>")
    left = new wwt.Composite("", "JourneyLeft")
    mainContentContainer = new wwt.Composite("", "JourneyMainContainer")
    mainContent = new wwt.Composite(mainContentContainer, "JourneyMain")
    buttonContainer = new wwt.Composite("", "JourneyButtonContainer")
    right = new wwt.Composite("", "JourneyRight")

    # Make sure the main content container's bottom border is the correct
    # distance away from the button container
    buttonContainer.addListener wwt.event.Resize, -> mainContentContainer.css bottom: buttonContainer.height()

    # Add buttons
    for y in [0...BTN_ROWS]
      for x in [0...BTN_COLS]
        button = new wwt.Button(buttonContainer)
        buttons.push button
    @resetButtons()

    # Place Info

    placeInfo = new wwt.Composite(left, "JourneyPlaceInfo")
    placeTitle = new wwt.Label(new wwt.Composite(placeInfo, "JourneyPlaceTitleContainer"), "JourneyPlaceTitle")
    placeLine1 = new wwt.Label(new wwt.Composite(placeInfo, "JourneyPlaceLine1Container"), "JourneyPlaceLine1")
    placeLine2 = new wwt.Label(new wwt.Composite(placeInfo, "JourneyPlaceLine2Container"), "JourneyPlaceLine2")

    @setPlaceTitle ""
    @setPlaceLine1 ""
    @setPlaceLine2 ""

    mapContainer = new wwt.Composite(left, "JourneyMapContainer")
    systemControlsContainer = new wwt.Composite(left, "JourneySystemControlsContainer")

    # System Controls

    # First Row
    bg1 = new wwt.ButtonGroup(systemControlsContainer, "JourneySystemControls1")
    mainMenu = bg1.addButton("JourneySystemMainMenu").setText(@glyphicon "menu-hamburger").setTooltip("Main Menu").setEnabled(false)
    settings = bg1.addButton("JourneySystemSettings").setText(@glyphicon "cog").setTooltip("Settings").setEnabled(false)
    user = bg1.addButton("JourneySystemUser").setText(@glyphicon "user").setTooltip("User").setEnabled(false)

    # Second Row
    bg2 = new wwt.ButtonGroup(systemControlsContainer, "JourneySystemControls2")
    newGame = bg2.addButton("JourneySystemNewGame").setText(@glyphicon "edit").setTooltip("New Game").setEnabled(false)
    loadGame = bg2.addButton("JourneySystemLoadGame").setText(@glyphicon "folder-open").setTooltip("Load Game").setEnabled(false)
    saveGame = bg2.addButton("JourneySystemSaveGame").setText(@glyphicon "floppy-disk").setTooltip("Save Game").setEnabled(false).setEnabled(false)

    # Nothing is done for the right side, it is modified at the game's discretion

    hasBeenInit = true

  root.glyphicon = (g) -> "<span class='glyphicon glyphicon-#{g}'></span>"

  root.resetButtons = ->
    for x in [0...BTN_COLS]
      for y in [0...BTN_ROWS]
        root.resetButton x, y
    return @

  root.resetButton = (x, y) ->
    testBounds x, y
    root.setButtonToDefault root.getButton x, y

  root.setButtonToDefault = (b) ->
    throw new Error("b must be an instance of wwt.Button") if b not instanceof wwt.Button
    b.setText(".")
     .setTextInvisible()
     .setEnabled(false)
     .setTooltip("")
     .removeAllListeners()

  root.getButton = (x, y) ->
    testBounds x, y
    return buttons[getIndex x, y]

  root.setPlaceTitle = (text) ->
    placeTitle.setText text
    hideIfEmpty placeTitle
  root.setPlaceLine1 = (text) ->
    placeLine1.setText text
    hideIfEmpty placeLine1
  root.setPlaceLine2 = (text) ->
    placeLine2.setText text
    hideIfEmpty placeLine2

  root.getSystemControl = (control) ->
    wwt.util.validateString "control", control
    return mainMenu if control is "main-menu"
    return newGame if control is "new-game"
    return settings if control is "settings"
    return loadGame if control is "load-game"
    return saveGame if control is "save-game"
    return user if control is "user"

  root.getMainContent = -> mainContent
  root.clearContent = ->
    mainContent.clear()
    return @
  root.getRightContent = -> right
  root.clearRightContent = ->
    right.clear()
    return @
  root.reset = (rightContent = true) ->
    root.clearContent()
    root.clearRightContent() if rightContent
    root.resetButtons()
    root.setPlaceTitle ""
    root.setPlaceLine1 ""
    root.setPlaceLine2 ""
)
