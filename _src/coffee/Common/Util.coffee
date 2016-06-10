module.exports =
  validateInstance: (name, variable, type) ->
    throwe new TypeError("Invalid instance: #{name}") if not variable instanceof type
