Journey              = require "../journey"
{Section, Encounter} = require "../asc"
Preamble             = require "../preamble"

module.exports = class Town

  constructor: (@__floor, @__name) ->
    @__sections = []
    @__environment = @__floor.getEnvironment().getTownEnvironment()
    @__encounter = new Encounter("Floor #{@__floor.getId()}: #{@__floor.getName()}", "#{@__name}", "", 1, =>
      Preamble.enableMovement Preamble.addMovementButtons()
      Journey.getButton(4, 0).setEnabled().setText("Town Center").addListener wwt.event.Selection, => @enterTownCenter()
      Journey.getMainContent().append(@getDescription() ? "")
    )

  getFloor: -> @__floor
  getName: -> @__name
  getEnvironment: -> @__environment

  setDescription: (@__description) ->
  getDescription: -> @__description

  push: ->
    return if arguments.length is 0

    # push(section: Section | array | {x, y})
    if arguments.length is 1
      section = arguments[0]
      if section instanceof Section
        throw new Error("Cannot add a section that is not on the same floor") if section.getFloor().getId() != @__floor.getId()
        @__sections.push section
        s.clearEncounters()
        s.addEncounter @__encounter
      else if Array.isArray section
        @push(s) for s in section
      else # asumed to be a plain object
        s = @__floor.get(section.x, section.y)
        throw new Error("Section not found: (#{section.x}, #{section.y})") if s is null
        @__sections.push s
        s.clearEncounters()
        s.addEncounter @__encounter

      return @

    # push(x, y)
    else
      @addSection({x: arguments[0], y: arguments[1]})

  getSections: -> @__sections.slice 0

  enterTownCenter: ->
    Journey.resetButtons()
    Journey.clearContent() # Remove ?
    #TODO: append description of town center (or keep town description)
    #TODO: Add buttons for the town center

  # Market getMarket()
  # Blacksmith getBlacksmith()
  # Tavern getTavern
  # Hotel getHotel
