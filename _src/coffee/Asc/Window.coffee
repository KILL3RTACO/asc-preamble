Journey = require "../journey"

windowContainer = new wwt.Composite("", "AscWindowBackground")

module.exports = class Window

  constructor: (id) ->
    @__contentsCreated = false
    @__container = new wwt.Composite("", id).addClass("AscWindow")

  # @OverrideMe
  createContents: ->

  getContainer: -> @__container

  addCloseButton: ->
    $closeButton = $(Journey.glyphicon("remove"))
    $topBar = $("<div class='AscWindow-TopBar'></div>")
    $closeButton.appendTo $topBar
    @__container.append $topBar
    $closeButton.click => @close()
    return @

  open: ->
    return if @isOpen()
    @createContents() unless @__contentsCreated
    windowContainer.$__element.show()
    @__container.$__element.show()
    @__open = true
    return @

  isOpen: -> @__open is true

  close: ->
    return unless @isOpen()
    windowContainer.$__element.hide()
    @__container.$__element.hide()
    @__open = false
    return @
