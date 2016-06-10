(function() {
  "use strict";
  var BrowserWindow, app, electron;

  electron = require("electron");

  app = electron.app;

  BrowserWindow = electron.BrowserWindow;

  app.on("window-all-closed", function() {
    if (process.platform !== "darwin") {
      return app.quit();
    }
  });

  app.on("ready", function() {
    var HEIGHT, WIDTH, atomScreen, monitor, win;
    app.setAppPath("" + __dirname);
    WIDTH = 750;
    HEIGHT = 350;
    win = new BrowserWindow({
      width: WIDTH,
      height: HEIGHT,
      title: "Ascension: Preamble"
    });
    atomScreen = electron.screen;
    monitor = atomScreen.getDisplayNearestPoint(atomScreen.getCursorScreenPoint());
    win.setPosition(monitor.bounds.x + ((monitor.bounds.width - WIDTH) / 2), monitor.bounds.y + ((monitor.bounds.height - HEIGHT) / 2));
    win.maximize();
    win.loadURL("file://" + __dirname + "/index.html");
    return win.on("closed", function() {
      var window;
      return window = null;
    });
  });

}).call(this);
