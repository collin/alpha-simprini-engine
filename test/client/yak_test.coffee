window.YakTest = {}

YakTest.API = 
  module: (name, config={}) ->
  test: (name, implementation) ->

YakTest.Assert = 
  ok: (result, message) ->
    if result
      console.log "y " + message
    else
      console.error "n " + message

  equal: (actual, expected, message) ->

  notEqual: (actual, expected, message) ->

  deepEqual: (actual, expected, message) ->

  notDeepEqual: (actual, expected, message) ->

class YakTest.Runner

class YakTest.Test
  constructor: (@name, @implementation, @module) ->

  run: ->
    @module.setup()
    CoffeeScript.run @implementation
    @module.teardown()

class YakTest.Module
  constructor: (@tests=[], @setup, @teardown) ->

  setup: ->
    return unless @setup
    CoffeeScript.run @setup

  teardown: ->
    return unless @teardown
    CoffeeScript.run @teardown

$ -> 
  ACE_EDITOR = "/javascripts/ace.js"
  script = document.createElement("script")
  script.type = "text/javascript"
  script.charset = "utf-8"
  script.src = ACE_EDITOR
  $(script).appendTo document.head

assertions = for name, implementation of YakTest.Assert
  "var #{name} = #{implementation}"
 
YakTest.ASSERTIONS = assertions.join("\n")

YakTest.editor = (element) ->
  editor = ace.edit element
  editor.setTheme "ace/theme/textmate"
  session = editor.getSession()
  session.setMode("ace/mode/coffee")


  heightUpdateFunction = ->
    # http://stackoverflow.com/questions/11584061/
    newHeight  = session.getScreenLength() 
    newHeight *= editor.renderer.lineHeight 
    newHeight += editor.renderer.scrollBar.getWidth()

    $(element).height newHeight.toString() + "px"
    editor.resize()

  $(element).css
    minHeight: 60
    width: 500

  heightUpdateFunction()
  session.on 'change', heightUpdateFunction
  session.on 'change', ->
    try
      console.clear()
      CoffeeScript.run """
      `#{YakTest.ASSERTIONS}`
      #{editor.getValue()}
      """
    catch e
      console.error(e)
    

  return editor



