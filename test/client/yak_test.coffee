window.YakTest = {}

YakTest.API = 
  # module: (name, config={}) ->
  # test: (name, implementation) ->
  helper: (name, fn) -> window[name] = fn

YakTest.Assert = 
  ok: (result, message) ->
    if result
      console.log "%cy " + message, "color:green;"
    else
      console.error "%cn " + message, "color:red;"

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
 
api = for name, implementation of YakTest.API
  "var #{name} = #{implementation}"

YakTest.WORLD = assertions.concat(api).join("\n")

heightUpdateFunction = (editor, session, element) ->
  # http://stackoverflow.com/questions/11584061/
  newHeight  = session.getScreenLength() 
  newHeight *= editor.renderer.lineHeight 
  newHeight += editor.renderer.scrollBar.getWidth()

  $(element).height newHeight.toString() + "px"
  editor.resize()

YakTest.console = (element) ->

YakTest.editor = (element, listener) ->
  editor = ace.edit element
  editor.setTheme "ace/theme/textmate"
  session = editor.getSession()
  session.setMode("ace/mode/coffee")

  $(element).css minHeight: 60, width: 500

  heightUpdateFunction(editor, session, element)
  session.on 'change', -> heightUpdateFunction(editor, session, element)
  session.on 'change', -> listener.trigger 'editor:change', listener, editor.getValue()    
  return editor

class YakTest.Suite extends Backbone.Model
  constructor: ->
    super
    @set modules: modules = new Backbone.Collection
    @listenTo this, "editor:change", (self, source) =>
      try
        @set helpers:CoffeeScript.compile(source)
      catch e
        console.error(e)

    @listenTo modules, "editor:change", (module, source) =>
      try
        module.set setup:CoffeeScript.compile(source)
      catch e
        console.error(e)
      
    @listenTo modules, "test:change", (test, source) =>
      test.exec(@get('helpers'), YakTest.WORLD, source)

class YakTest.Module extends Backbone.Model
  constructor: ->
    super
    @set tests: tests = new Backbone.Collection
    @listenTo tests, 'editor:change', (test, source) => 
      @trigger "test:change", test, source

class YakTest.Test extends Backbone.Model
  exec: (helpers, world, source) ->
    try
      console.clear()
      console.log CoffeeScript.run  """
      `#{world}`
      `#{helpers}`
      `#{@get('module')?.get('setup')}`
      #{source}
      """
    catch e
      console.error(e)

class YakTest.View extends Backbone.View
  find: (args...) -> @$el.find(args...)

  tag: (name, attrs={}, contentFn=(->)) ->
    if _.isFunction(attrs)
      contentFn = attrs
      attrs = {}

    if _.isString(attrs)
      content = attrs
      contentFn = -> @text(content)
      attrs = {}

    if _.isString(contentFn)
      content = contentFn
      contentFn = -> @text(content)

    element = document.createElement(name)
    element.setAttribute(k,v) for k,v of attrs
    (@_currentNode || @el).appendChild(element)
    [@_currentNode, lastNode] = [element, @_currentNode]
    contentFn.call(this)
    @_currentNode = lastNode
    element

  text: (content="") ->
    (@_currentNode || @el).appendChild document.createTextNode(content)

class YakTest.SuiteView extends YakTest.View
  tagName:'section'
  className:'yaktest-suite'

  events:
    'click .create-module': 'createModule'

  constructor: ->
    super
    @makeContent()
    @listenTo @model.get('modules'), 'add', @addModule

  makeContent: ->
    @tag 'h1', 'Helpers'
    @editor = YakTest.editor @tag('section'), @model
    @tag 'h1', 'Modules'
    @tag 'button', class:'create-module', 'Create Module'
    @modules = $ @tag 'ol', ->

  createModule: ->
    @model.get('modules').add new YakTest.Module, suite:@model

  addModule: (module) ->
    @modules.append (new YakTest.ModuleView(model:module)).el

  remove: ->
    @editor.destory()
    super

class YakTest.ReportView extends YakTest.View
  className:'yaktest-report'
  tagName:'section'

class YakTest.ModuleView extends YakTest.View
  tagName:'li'
  className:'yaktest-module'

  events:
    'click .create-test': 'createTest'

  constructor: ->
    super
    @makeContent()
    @listenTo @model.get('tests'), 'add', @addTest

  makeContent: ->
    @tag 'input'
    @tag 'label', "Setup:"
    @editor = YakTest.editor @tag('section'), @model
    @tag 'h1', "Tests"
    @tag 'button', class:'create-test', 'Create Test'
    @tests = $ @tag 'ol', ->

  createTest: ->
    @model.get('tests').add new YakTest.Test(module:@model)

  addTest: (module) ->
    @tests.append (new YakTest.TestView(model:module)).el

  remove: ->
    @editor.destroy()
    super

class YakTest.TestView extends YakTest.View
  tagName: 'li'
  className: 'yaktest-test'

  constructor: ->
    super
    @makeContent()

  makeContent: ->
    @tag 'input'
    @editor = YakTest.editor @tag('section'), @model

  remove: ->
    @editor.destroy()
    super

class YakTest.App
  constructor: ->
    @suite = new YakTest.Suite
    @suiteView = new YakTest.SuiteView(el:document.body, model:@suite)
