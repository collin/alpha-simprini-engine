# Extended to allow "Nested.Modules"
window.module = (name, fn) ->
  [name, more...] = name.split "."
  if not @[name]?
    this[name] = {}
  if not @[name].module?
    @[name].module = window.module
  
  if more[0] is undefined
    if fn is undefined
      @[name]
    else
      fn.call(@[name])
  else
    @[name].module more.join("."), fn