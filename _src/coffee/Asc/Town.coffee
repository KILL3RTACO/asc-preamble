Journey = require "../journey"

Asc       = require "../asc"
Player    = Asc.require "player"
Section   = Asc.require "section"
Encounter = Asc.require "encounter"

module.exports = class Town

  constructor: (@__floor, @__name) ->
    @__sections = []
    @__environment = @__floor.getEnvironment().getTownEnvironment()

  getFloor: -> @__floor
  getName: -> @__name
  getEnvironment: -> @__environment

  setDescription: (@__description) ->
  getDescription: -> @__description

  setEncounter: (@__encounter) ->
    for section in @__sections
      section.clearEncounters()
      section.addEncounter @__encounter
  getEncounter: @__encounter

  push: ->
    return if arguments.length is 0

    # push(section: Section | array | {x, y})
    if arguments.length is 1
      section = arguments[0]
      if section instanceof Section
        throw new Error("Cannot add a section that is not on the same floor") if section.getFloor().getId() != @__floor.getId()
        @__push s
      else if Array.isArray section
        @push(s) for s in section
      else # asumed to be a plain object
        s = @__floor.get(section.x, section.y)
        throw new Error("Section not found: (#{section.x}, #{section.y})") if s is null
        @__push s
      return @

    # push(x, y)
    else
      @addSection({x: arguments[0], y: arguments[1]})

  __push: (section) ->
    @__sections.push section
    section.setAreaName @__name

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
