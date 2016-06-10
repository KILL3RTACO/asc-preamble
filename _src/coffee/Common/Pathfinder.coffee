# I try to explain as much as I can about everything. A* is typically a difficult topic for someone
# new to game programming. Everything I've found is pretty much "this is the algorithm, implement
# it in your favorite language", with no real explanation as to what the algorithm is actually doing
# Wikipedia has an article on it, but the pseudocode provided is a little confusing to me

# Hopefully, my explanation about the algorithim and what it requires is better than most.

# Borrow some Math functions
{abs, min, max, sqrt} = Math

# I don't really like working with multi-dimensional arrays. It gets confusing on which order you
# should iterate and where to properly insert. What I instead prefer to do is use a simple
# (one dimensional) array, and transform the x, y location into an index for the array.

# To help with this, I use the the two functions below
# By the way, // is an integer division operator in CofeeScript (for those who don't know):
# a // b transpiles to Math.floor(a / b)

getIndex = (x, y, width) -> return (y * width) + x
fromIndex = (index, width) -> return {x: index % width, y: index // width}

D = 1
D2_CHEBYSHEV = 1
D2_OCTILE = 1.4

# A* uses a heuristic function to determine the movement cost of one node (a) to another (b)
# To make the heuristic configurable, I've added a way to decide how to determine to the cost (formula)
# I also added some links if you want to know a little more
heuristic = (a, b, formula) ->
  return formula.call(null, a, b) if typeof formula is "function"

  if formula is Pathfinder.OCTILE or formula is Pathfinder.CHEBYSHEV
    #http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html#diagonal-distance
    D2 = if formula is Pathfinder.OCTILE then D2_OCTILE else D2_CHEBYSHEV
    dx = abs(a.x - b.x)
    dy = abs(a.y - b.y)
    return D * (dx + dy) + (D2 - 2 * D) * min(dx, dy)
  else #Pathfinder.MANHATTAN
    #http://theory.stanford.edu/~amitp/GameProgramming/Heuristics.html#manhattan-distance
    return abs(a.x - b.x) + abs(a.y - b.y) # D = 1

# Alias for the heuristic function, which is sometimes simply called 'h'
h = heuristic

# This a class to add and sort data by priority (a number). The lower the priority the higher in the list it is stored
# (assuming the list is displayed top-down and ordered from the 0th index onwards)
#
# Code adapted from http://blog.mgechev.com/2012/11/24/javascript-sorting-performance-quicksort-v8/
# (scroll to near the bottom of the page, above comments section)
class PriorityList

  constructor: (list = []) ->
    @__list = list
    @sort() if @size() > 0

  put: (data, priority) ->
    @__list.push({data, priority})
    return

  get: -> @__list.shift().data

  sort: -> @__list.sort (a, b) -> return a.priority - b.priority

  size: -> return @__list.length
  isEmpty: -> return @size() is 0


# Get the reconstructed path, from start to goal
getPath = (cameFrom, start, goal, grid) ->
  current = goal
  path = [current]
  while current isnt start
    current = cameFrom[current]
    path.push current

  # The path is backwards because cameFrom is backwards. It represents the path from
  # goal to start
  path.reverse()

  # 'path' is now an array of the nodes in order from start to goal.
  # However, each entry is an index (see below, near findPath())
  # It can be turned into an (x, y) pair as long as we know the width of the containing grid,
  # which must be supplied to this method (hence it is private)

  realPath = []
  for index in path
    pair = fromIndex index, grid.getWidth()
    realPath.push grid.get(pair.x, pair.y)

  return realPath

class Pathfinder

  @MANHATTAN: 0
  @OCTILE:    1
  @CHEBYSHEV: 2

  #TODO: Implement tie breakers?

  constructor: ({grid: @__grid, distanceFormula = @constructor.MANHATTAN, impossibleCost}) ->
    throw new Error("Pathfinder needs a grid") if @__grid is undefined or @__grid is null
    throw new Error("options.grid must be an instance of Pathfinder.Grid") if @__grid not instanceof Pathfinder.Grid
    @__dFormula = if Number.isInteger(distanceFormula) or typeof distanceFormula is "function" then distanceFormula else @constructor.MANHATTAN
    @__impossibleCost = if Number.isInteger(impossibleCost) then impossibleCost else 10000

  getGrid: -> @__grid

  # A* pathfinding
  # Note that instead of using a Map I opted to use arrays with indexes as keys and values
  # This speeds up performance when searching, but requires that I then turn the indexes into Nodes afterwards
  # The two functions I use to determine the index/location of a node are found near the top of this file
  #
  # This is adapted from http://www.redblobgames.com/pathfinding/a-star/implementation.html#orgheadline8
  findPath: (start, goal) ->
    # The list of discovered nodes (data), and the cost it takes to get there (priority)
    # (hence start is 0)
    # When implementing this list, data simply needs to be sorted by ascending priority. Exactly how it is sorted
    # is entirely up to you. For simplicity, I use the built-in sort function of arrays.
    frontier = new PriorityList([{data: start, priority: 0}])

    # The list of nodes that have been traversed. The index represents the 'to' node and the
    # value of that index represents the 'from' node.
    # For example, on a 10x10 grid, 'cameFrom[11] = 0' would mean (0, 0) -> (1, 1)
    cameFrom = []

    # The total cost of movement from the start node. The index represents the node (as above), and the value
    # represents the total cost it takes to move to that node from the start node
    # For example, on a 10x10 grid, 'totalCost[11] = 5' means that it costs 5 to move from the start node to (1, 1)
    totalCost = []

    # As stated above, I use indexes to represent nodes
    startIndex = getIndex start.x, start.y, @__grid.getWidth()

    # The start node has no 'from' value, because it is the beginning
    cameFrom[startIndex] = null

    # The cost to go to the start node from the start node is 0 (because we aren't moving anywhere)
    totalCost[startIndex] = 0

    # 'until' = 'while not'
    # Run the loop while we still have nodes that have been discovered (but not tested)
    until frontier.isEmpty()

      # Get the node with the lowest movement cost (top of the list)
      current = frontier.get()
      currentIndex = getIndex current.x, current.y, @__grid.getWidth() # The index of that node

      # We found our path, reconstruct the path and return it
      # The returned path is an array of nodes, the first entry being the start node, and the
      # last entry being the goal node
      # Pssst - the getPath() function is above the Pathfinder class definition (around line 70-80)
      # You're welcome ;D
      if current == goal
        return getPath cameFrom, startIndex, getIndex(goal.x, goal.y, @__grid.getWidth()), @__grid

      # Was the frontier changed (were any nodes added to it)?
      frontierChanged = false

      # More configuration options here. A* allows you to define which ways you can move.
      # The Node class offers  enough flexibility for this. (see below, class Node)
      for next in @__grid.getAllowedNeighbors current.x, current.y
        nextIndex = getIndex next.x, next.y, @__grid.getWidth()

        # This line allows node to have their own separate movement cost.
        # For instance, it may be easier to move on grass than it is to move through sand.
        newCost = totalCost[currentIndex] + next.getMovementCost()

        # Nodes are skipped if they're considered impossible to tread. This happens in one of two ways:
        # 1) The node is a wall
        #      * A node is considered a 'wall' if:
        #        * It is null or undefined
        #        * It has no allowed neighbors
        # 2) The cost to get to that node is too high (configurable). This can be done by manually setting the movement
        #    cost of the node
        continue if next is null or next is undefined or next.isWall() or newCost >= @__impossibleCost

        # Get the movement cost for this neighbor node (if it was already determined)
        nextCost = totalCost[nextIndex]

        # If the movement cost of this neighbor node either :
        #  * Hasn't been determined or
        #  * HAS been determined, but the cost to move to it is less than it was before
        if nextCost is null or nextCost is undefined or newCost < nextCost

          # The cost to move from the start node to this neghboring node is 'newCost' defined above
          totalCost[nextIndex] = newCost

          # Set the priority of this node to its movement cost + its heuristic value,
          # then add it to the list of discovered nodes
          priority = newCost + h(next, goal, @__dFormula)
          frontier.put next, priority

          # We went from the current node to this neighbor, so set it in the array to keep track of it
          cameFrom[nextIndex] = currentIndex

          # Set 'frontierChanged' to true because we added something to it.
          # For performance opmtimization, the array of discovered nodes is sorted only
          # AFTER all potential neighbors have been stepped through. If we were to instead sort the array
          # immediately after it was added, we would be sorting more times than needed. 
          frontierChanged = true

      # Only sort the list if anything was added to it, otherwise there isnt a need to
      frontier.sort() if frontierChanged

    # We failed to find a path, return null
    return null

# Represents a square in a grid
Pathfinder.Node = class Node

  @WALL:          -1
  @UP:             0
  @DOWN:           1
  @LEFT:           2
  @RIGHT:          3
  @TOP_LEFT:       4
  @TOP_RIGHT:      5
  @BOTTOM_LEFT:    6
  @BOTTOM_RIGHT:   7
  @ALL_DIRECTIONS: [@UP..@BOTTOM_RIGHT]

  @defaultOptions: ->
    options = {
      x: 0
      y: 0
    }
    options[k] = true for k in ["up", "down", "left", "right", "topLeft", "topRight", "bottomLeft", "bottomRight"]
    return options

  @fromObject: (object) ->
    return null if object is null
    return new @(object.x, object.y, null, object.movementCost) if object.wall
    directions = []
    keys =
      up: @UP
      down: @DOWN
      left: @LEFT
      right: @RIGHT
      topLeft: @TOP_LEFT
      topRight: @TOP_RIGHT
      bottomLeft: @BOTTOM_LEFT
      bottomRight: @BOTTOM_RIGHT
    (
      val = object[k]
      directions[v] = if val is null or val is undefined then true else val
    ) for k, v of keys
    return new @(object.x, object.y, directions)

  @getDeltas: (dir) ->
    return {x: 0, y: 1} if dir is @DOWN
    return {x: 0, y: -1} if dir is @UP
    return {x: -1, y: 0} if dir is @LEFT
    return {x: -1, y: 1} if dir is @BOTTOM_LEFT
    return {x: -1, y: -1} if dir is @TOP_LEFT
    return {x: 1, y: 0} if dir is @RIGHT
    return {x: 1, y: 1} if dir is @BOTTOM_RIGHT
    return {x: 1, y: -1} if dir is @TOP_RIGHT

  constructor: (@x, @y, @__directions = [false, false, false, false, false, false, false, false], @__movementCost = 1) ->

  setDirectionAllowed: (direction, allowed = true) -> @__directions[direction] = allowed is true
  canGo: (direction) -> return @__directions[direction]

  setMovementCost: (@__movementCost) ->
  getMovementCost: -> @__movementCost

  getAllowedNeighbors: ->
    allowed = []
    allowed.push {x: @x - 1, y: @y - 1} if @canGo @constructor.TOP_LEFT
    allowed.push {x: @x, y: @y - 1} if @canGo @constructor.UP
    allowed.push {x: @x + 1, y: @y - 1} if @canGo @constructor.TOP_RIGHT
    allowed.push {x: @x - 1, y: @y} if @canGo @constructor.LEFT
    allowed.push {x: @x + 1, y: @y} if @canGo @constructor.RIGHT
    allowed.push {x: @x - 1, y: @y + 1} if @canGo @constructor.BOTTOM_LEFT
    allowed.push {x: @x, y: @y + 1} if @canGo @constructor.DOWN
    allowed.push {x: @x + 1, y: @y + 1} if @canGo @constructor.BOTTOM_RIGHT
    return allowed

  isWall: -> return @getAllowedNeighbors().length is 0

Pathfinder.Grid = class Grid

  constructor: (@__grid, @__width = 10, @__height = 10) ->

  getHeight: -> @__height
  getWidth: -> @__width

  getNodes: (list) ->
    throw new Error("list must be an array") if not Array.isArray(list)
    found = []
    for {x, y} in list
      n = @get x, y
      continue if n is null or n is undefined
      found.push n
    return found

  getAllowedNeighbors: (x, y) ->
    node = @get(x, y)
    return null if node is null or node is undefined
    return @getNodes node.getAllowedNeighbors()

  get: (x, y) ->
    return null if x < 0 or x >= @__width or y < 0 or y >= @__height
    return @__grid[getIndex x, y, @__width]
  set: (x, y, node) ->
    @__grid[getIndex x, y, @__width] = node
    return @

# CommonJS/Node.js and Browser support
if typeof module is "object" and typeof module.exports is "object"
  module.exports = Pathfinder
else
  window.Pathfinder = Pathfinder
