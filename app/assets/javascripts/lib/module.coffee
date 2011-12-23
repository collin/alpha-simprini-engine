# Extended to allow "Nested.Modules"
exports.module = (name, fn) ->
  if _.isString(name)
    [name, more...] = name.split "."
    if not @[name]?
      this[name] = {}
    if not @[name].module?
      @[name].module = global.module
  
    if more[0] is undefined
      if fn is undefined
        @[name]
      else
        fn.call(@[name])
    else
      @[name].module more.join("."), fn
  else
    fn?.call(name)
    name