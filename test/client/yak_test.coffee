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

# class YakTest.Runner

# class YakTest.Test
#   constructor: (@name, @implementation, @module) ->

#   run: ->
#     @module.setup()
#     CoffeeScript.run @implementation
#     @module.teardown()

# class YakTest.Module
#   constructor: (@tests=[], @setup, @teardown) ->

#   setup: ->
#     return unless @setup
#     CoffeeScript.run @setup

#   teardown: ->
#     return unless @teardown
#     CoffeeScript.run @teardown

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
  $(element).text listener.get('source') || ''
  editor = ace.edit element
  editor.setTheme "ace/theme/textmate"
  session = editor.getSession()
  session.setMode("ace/mode/coffee")

  $(element).css minHeight: 60, width: "100%"

  setTimeout (-> heightUpdateFunction(editor, session, element)), 50
  
  session.on 'change', -> heightUpdateFunction(editor, session, element)
  session.on 'change', -> listener.trigger 'editor:change', listener, editor.getValue()    
  return editor

class YakTest.Suite extends Backbone.Model
  constructor: ->
    super
    @set modules: modules = new Backbone.Collection
    @listenTo this, "editor:change", (self, source) =>
      try
        @set source:source
        @set helpers:CoffeeScript.compile(source)
      catch e
        console.error(e)

    @listenTo modules, "editor:change", (module, source) =>
      try
        module.set source:source
        module.set setup:CoffeeScript.compile(source)
      catch e
        console.error(e)
      
    @listenTo modules, "test:change", (test, source) =>
      test.exec(@get('helpers'), YakTest.WORLD, source)

  toJSON: ->
    {
      name: @get('name'),
      helpers: @get('source'),
      modules: @get('modules').invoke('toJSON')
    }

  @fromJSON: (data) ->
    suite = new this
      source:data.helpers
      name:data.name

    suite.get('modules').set _.map(data.modules, (moduleData) ->
      YakTest.Module.fromJSON(moduleData)
    )

    suite

class YakTest.Module extends Backbone.Model
  constructor: ->
    super
    @set 
      tests: new Backbone.Collection
      classMethods: new Backbone.Collection
      instanceMethods: new Backbone.Collection
      classMembers: new Backbone.Collection
      instanceMembers: new Backbone.Collection

    # @listenTo tests, 'editor:change', (test, source) => 
    #   @trigger "test:change", test, source

  toJSON: ->
    {
      name: @get('name'),
      setup: @get('source'),
      tests: @get('tests').invoke('toJSON')
    }

  @fromJSON: (data) ->
    module = new this
      name:data.name, 
      source:data.setup
    module.get('tests').set _.map(data.tests, (testData) -> 
      YakTest.Test.fromJSON testData
    )
    module

class YakTest.Method extends Backbone.Model
class YakTest.ClassMethod extends YakTest.Method
class YakTest.InstanceMethod extends YakTest.Method

class YakTest.Member extends Backbone.Model
class YakTest.ClassMember extends YakTest.Member
class YakTest.InstanceMember extends YakTest.Member

class YakTest.Test extends Backbone.Model
  exec: (helpers, world, source) ->
    try
      @set source:source
      console.clear()
      console.log CoffeeScript.run  """
      `#{world}`
      `#{helpers}`
      `#{@get('module')?.get('setup')}`
      #{source}
      """
    catch e
      console.error(e)

  toJSON: ->
    {
      name: @get('name'),
      source: @get('source')
    }

  @fromJSON: (data) ->
    new this name:data.name, source:data.source

class YakTest.View extends Backbone.View
  tagName: 'section'
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

  collection: (collection, ViewClass, options={}) ->
    node = @_currentNode || @el
    views = {}

    @listenTo collection, 'add', (item) ->
      index = collection.indexOf(item)
      view = new ViewClass _.extend {}, options, model:item
      views[item.cid] = view
      if index is 0
        node.prepend view.el
      else if sibling = node.children().at(index)
        $(sibling).before(view.el)
      else
        $(node).append(view.el)

    @listenTo collection, 'remove', (item) ->
      views[item.cid]?.destroy()
      views[item.cid] = undefined

    collection.each (item) ->
      view = new ViewClass _.extend {}, options, model:item
      views[item.cid] = view
      view.$el.appendTo node

  view: (ViewClass, options={}) ->
    @children ||= []
    view = new ViewClass(options)
    view.$el.appendTo @_currentNode || @el
    @children.push view

  destroy: ->
    child.destroy for child in (@children || [])
    super

  text: (content="") ->
    (@_currentNode || @el).appendChild document.createTextNode(content)

class YakTest.SuiteView extends YakTest.View
  className:'yak-suite'

  events:
    'click .create-module': 'createModule'
    'change .suite-name': 'nameModule'

  constructor: ->
    super
    @view YakTest.BrowserView, model:@model
    @view YakTest.EditorView
    @view YakTest.ConsoleView
  #   super
  #   @makeContent()

  # makeContent: ->
  #   @view 
  # @tag 'input', class:'suite-name', value:@model.get('name') || ''
  # @tag 'h1', 'Helpers'
  # @tag 'h1', 'Modules'
  # @tag 'button', class:'create-module', 'Create Module'
  # @tag 'ol', ->
  #   @collection @model.get('modules'), YakTest.ModuleView

  createModule: ->
    @model.get('modules').add new YakTest.Module, suite:@model

  nameModule: (event) ->
    @model.set name:$(event.target).val()

class YakTest.BrowserView extends YakTest.View
  className:'yak-browser'
  constructor: ->
    super
    @view YakTest.HelpersView
    @view YakTest.ModulesView, model:@model.get('modules')
    @view YakTest.MethodsView, model:@model.get('modules').last()
    @view YakTest.TestsView

class YakTest.MethodsView extends YakTest.View
  className:'yak-methods'

  constructor: ->
    super
    @tag 'header', "Class Members"
    @tag "ol", ->
      @collection @model.get("classMembers"), YakTest.MemberView
    @tag 'header', "Instance Members"
    @tag "ol", ->
      @collection @model.get("instanceMembers"), YakTest.MemberView
    @tag 'header', "Class Methods"
    @tag "ol", ->
      @collection @model.get("classMethods"), YakTest.MemberView
    @tag 'header', "Instance Methods"
    @tag "ol", ->
      @collection @model.get("instanceMethods"), YakTest.MemberView

class YakTest.MemberView extends YakTest.View
  tagName: 'li'
  className: 'yak-member'

  constructor: ->
    super
    @text @model.get('name')

class YakTest.HelpersView extends YakTest.View
  className:'yak-helpers'

  constructor: ->
    super
    @tag 'header', "Helper Classes"
    @tag 'header', "Helper Functions"

class YakTest.ConsoleView extends YakTest.View
  className:'yak-console'

  constructor: ->
    super
    @$el.attr 'contenteditable', true

class YakTest.EditorView extends YakTest.View
  className:'yak-editor'

class YakTest.ModulesView extends YakTest.View
  className:'yak-modules'

  constructor: ->
    super
    @tag 'header', "Modules"
    @tag 'ol', ->
      @collection @model, YakTest.ModuleView

class YakTest.ModuleView extends YakTest.View
  tagName:'li'
  className:'yak-module'

  events:
    'click .create-test': 'createTest'
    'change .module-name': 'nameModule'

  constructor: ->
    super
    @makeContent()

  makeContent: ->
    @tag 'label', @model.get('name')
    # @tag 'label', "Setup:"
    # @tag 'h1', "Tests"
    # @tag 'button', class:'create-test', 'Create Test'
    # @tag 'ol', ->
    #   @collection @model.get('tests'), YakTest.TestView

  createTest: ->
    @model.get('tests').add new YakTest.Test(module:@model)

  nameModule: (event) ->
    @model.set name:$(event.target).val()

class YakTest.TestsView extends YakTest.View
  className:'yak-tests'

  constructor: ->
    super
    @tag 'header', "Tests"
class YakTest.TestView extends YakTest.View
  tagName: 'li'

  events:
    'change .test-name': 'nameTest'

  constructor: ->
    super
    @makeContent()

  makeContent: ->
    @tag 'input', class:'test-name', value:@model.get('name') || ''

  nameTest: (event) ->
    @model.set name:$(event.target).val()

class YakTest.App
  constructor: ->
    if URI(location.href).query(true).bootstrap?
      makeModule = (object, module) ->
        for spec in [[object, '', 'class', 'Class'], [object::, 'prototype.', 'instance', 'Instance']]
          [source, place, collection, type] = spec
          for key, value of source
            continue unless value?
            continue if value.__super__?
            if _.isFunction(value)
              source = value.toString().replace(/^function/, "#{module.get('name')}.#{place}#{key} = function")
              module.get(collection+"Methods").add new YakTest[type+"Method"]
                name: key
                source: Js2coffee.build( source )
            else
              module.get(collection+"Members").add new YakTest[type+"Member"]
                name: key
                value: value

      suite = new YakTest.Suite
      suite.get('modules').add new YakTest.Module name:"YakTest"
      for key, value of YakTest
        continue unless YakTest[key].__super__
        module = new YakTest.Module name:"YakTest.#{key}"
        makeModule YakTest[key], module
        suite.get('modules').add module
      @init(suite)
      
    else if suite = URI(location.href).query(true).suite
      $.get("/suites?suite_name=#{suite}").then (raw) =>
        @init YakTest.Suite.fromJSON JSON.parse(raw)
    else
      @init(new YakTest.Suite)

  init: (@suite) ->
    @suiteView = new YakTest.SuiteView(el:document.body, model:@suite)

    jwerty.key "meta + s", (event) => 
      event.preventDefault()
      source = JSON.stringify(@suite.toJSON())
      $.ajax
        url: '/suites'
        type:'post'
        data:
          suite_name: @suite.get('name')
          dump: source
