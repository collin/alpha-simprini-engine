String::underscore = ->
  @replace(/([A-Z])/g, (match) -> "_#{match}").slice(1).toLowerCase()