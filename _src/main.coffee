"use strict"

electron      = require "electron"
app           = electron.app
BrowserWindow = electron.BrowserWindow

app.on "window-all-closed", -> app.quit() if process.platform isnt "darwin"

app.on "ready", ->
  app.setAppPath "#{__dirname}"
  WIDTH = 750
  HEIGHT = 350
  win = new BrowserWindow
    width: WIDTH
    height: HEIGHT
    title: "Ascension: Preamble"
  # electron.Menu.setApplicationMenu null
  atomScreen = electron.screen
  monitor = atomScreen.getDisplayNearestPoint atomScreen.getCursorScreenPoint()
  win.setPosition monitor.bounds.x + ((monitor.bounds.width - WIDTH) / 2), monitor.bounds.y + ((monitor.bounds.height - HEIGHT) / 2)
  win.maximize()
  win.loadURL "file://#{__dirname}/index.html"
  win.on "closed", -> window = null
