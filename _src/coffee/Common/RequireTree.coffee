module.exports = class RequireTree

  constructor: (mod, classes, requirePrefix) ->
    for c in classes
      do (c) =>
        path = "#{requirePrefix}/#{c}"
        if typeof c is "string"
          Object.defineProperty @, c,
            enumerable: true
            get: -> mod.require path
        else if typeof c is "object"
          return if not c.name
          if Array.isArray c.classes
            Object.defineProperty @, c.name,
              enumerable: true
              value: new RequireTree(mod, c.classes, path)
          else
            Object.defineProperty @, c.name,
              enumerable: c.enumerable ? true
              get: -> mod.require path
