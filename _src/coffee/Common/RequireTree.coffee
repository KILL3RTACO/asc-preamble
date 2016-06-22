module.exports = class RequireTree

  constructor: (mod, classes, requirePrefix) ->
    for k, v of classes
      do (k, v) =>
        path = "#{requirePrefix}/#{if v is null or v.length is 0 then k else v}"
        Object.defineProperty @, k, 
          enumerable: true
          get: -> mod.require path
