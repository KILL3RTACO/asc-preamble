Journey = require "../journey"

windowBackground = new wwt.Composite("", "AscWindowBackground").css({display: "none"})

module.exports = class Window

  constructor: (id) ->
    @__contentsCreated = false
    @__windowContainer = new wwt.Composite("", id).addClass("AscWindow").css({display: "none"})
    @__container = new wwt.Composite(@__windowContainer, "").addClass("AscWindowContent")

  # @OverrideMe
  createContents: ->

  getContainer: -> @__container

  addCloseButton: ->
    $closeButton = $(Journey.glyphicon("remove"))
    $topBar = $("<div class='AscWindow-TopBar'></div>")
    $closeButton.appendTo $topBar
    @__windowContainer.append $topBar
    @__windowContainer.addClass "hasCloseButton"
    $closeButton.click => @close()
    return @

  open: ->
    return if @isOpen()
    unless @__contentsCreated
      @createContents()
      @__contentsCreated = true
    @__onOpen()
    windowBackground.$__element.show()
    @__windowContainer.$__element.show()
    @__open = true
    return @

  __onOpen: ->
  __onClose: ->

  isOpen: -> @__open is true

  close: ->
    return unless @isOpen()
    @__onClose()
    windowBackground.$__element.hide()
    @__windowContainer.$__element.hide()
    @__open = false
    return @
