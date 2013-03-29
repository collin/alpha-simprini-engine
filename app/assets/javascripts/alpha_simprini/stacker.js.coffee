#= require underscore
#= require backbone
window.Stacker = {}

class Stacker.Stack extends Backbone.Collection
  model: -> Stacker.StackItem

class Stacker.StackItem extends Backbone.Model
  _validate: -> true

class Stacker.View extends Backbone.View
  tag: (name, attrs={}, contentFn=(->)) ->
    if _.isFunction(attrs)
      contentFn = attrs
      attrs = {}

    if _.isString(attrs)
      content = attrs
      contentFn = -> @text(content)
      attrs = {}

    element = document.createElement(name)
    element.setAttribute(k,v) for k,v of attrs
    (@_currentNode || @el).appendChild(element)
    [@_currentNode, lastNode] = [element, @_currentNode]
    contentFn.call(this)
    @_currentNode = lastNode
    element

  text: (content="") ->
    (@_currentNode || @el).appendChild document.createTextNode(content)

class Stacker.StackView extends Stacker.View
  className: "stack-item-container container"
  events:
    "click .stack-item-top .stack-item-title": "popStack"
    "click .stack-item-under": "jumpStack"

  distance: 30

  constructor: (options) ->
    super
    @$el.addClass('stack-item-container')
    @listenTo @model, 'add', @render
    @listenTo @model, 'remove', @render
    @listenTo @model, 'reset', @render
    @listenTo @model, 'change', @render

  popStack: ->
    @model.pop()

  jumpStack: (event) ->
    cid = $(event.target).closest('.stack-item-under').data('stack-item-cid')
    item = @model.get(cid)
    for _item in @model.slice(@model.indexOf(item) + 1, @model.length).reverse()
      @model.remove(_item)

  render: =>
    @$el.empty()
    for stackItem, index in @model.slice(0, @model.length - 1)
      item = @tag 'li', class:'stack-item stack-item-under', 'data-stack-item-cid':stackItem.cid, ->
        @tag 'label', class:'stack-item-title', ->
          @text stackItem.get('title')
      $(item).css
        top: index*@distance
        left: (index*@distance)/2

    if top = @model.last()
      item = @tag 'li', class:'stack-item stack-item-top', ->
        @tag 'label', class:'stack-item-title', ->
          @text top.get('link')

      if top.get('header')
        newHeader = top.get('header')
        oldHeader = $("header:first")
        oldHeader.replaceWith newHeader unless newHeader is oldHeader[0]

      if top.get('content')
        $(item).append top.get('content')

      if title = top.get('title')
        $('.stack-item-top .stack-item-title').text(title)

      if htmlAttrs = top.get('htmlAttrs')
        $('html').attr(htmlAttrs)

      $(item).css
        top: (@model.length - 1) * @distance
        left: ((@model.length - 1) * @distance)/2

      $(".stack-item-under").css
        height: $(item).height()
      $(".stack-item").css 'width', $("#content").width()


$.rails.linkClickSelector = ""
class Stacker.App
  constructor: ->
    content = $("#content")
    content.after stackContainer = $("<section id='content'></section>")

    @stack = new Stacker.Stack
    @forwardStack = new Stacker.Stack
    @stackView = new Stacker.StackView model:@stack, el:stackContainer

    $(document).delegate "a", "click", (event) =>
      console.log "Stacker intercepted a click", event.target, event

      target = $ event.target
      link = target.closest('a')[0]

      # reset the whole stack, maybe clicked a tab link
      if target.is("[stacker=reset]")
        @stack.set([])
        @forwardStack.set([])
        @stackView.render()
        @addStack(event)
      # refresh the top stack item content, maybe set a filter
      else if link.pathname is location.pathname
        @refreshStackContent(link.href)
        event.preventDefault()
        history.replaceState history.state, null, link.href
      else if target.is "[data-method]" # Rails ajax input
        alert "THWHATSS"
        $.rails.handleRemote(link).then =>
          alert("STFTAT")
        event.preventDefault()
      else
        @addStack(event)
        
    history.replaceState {start:true}, null, location.href
    stackItem = new Stacker.StackItem
      header: $("header:first")[0]
      content: content[0]
      title: $("title").text()
      htmlAttrs: {}
    @stack.add stackItem

    @stackView.render()

    @stack.on 'add', (item) =>
      console.log "pushState", {cid:item.cid}, null, item.get('link')
      history.pushState({cid:item.cid}, null, item.get('link'))

    @stack.on 'remove', (item) =>

    window.addEventListener 'popstate', ({state}) => 
      console.log "Stacker intercepted a popstate event", "state:", state
      return unless state
      if state.cid
        if item = @stack.get(state)
          toRemove = @stack.slice @stack.indexOf(item) + 1, @stack.length
          @stack.remove(item, silent:true) for item in toRemove
          @forwardStack.add(item) for item in toRemove
        else if item = @forwardStack.get(state)
          toAdd = @forwardStack.slice @forwardStack.indexOf(item), @forwardStack.length
          @forwardStack.remove(item) for item in toAdd
          @stack.add(item, silent:true) for item in toAdd

      else if state.start is true
        for item in @stack.models
          @stack.remove(item, silent:true)
          @forwardStack.add(item)

      @stackView.render()

  refreshStackContent: (href) ->
    stackItem = @stack.last()
    $.get(href).then (html) ->
      _doc = document.createElement('html')
      _doc.innerHTML = html
      doc = $ _doc
      
      stackItem.set {content: null}, silent:true
      stackItem.set content: doc.find("#content")[0]

  addStack: (event) ->
    event.preventDefault()
    link = event.target
    stackItem = new Stacker.StackItem
    stackItem.set link: link.href
    @stack.add stackItem
    $.get(link.href).then (html) =>
      _doc = document.createElement('html')
      _doc.innerHTML = html
      doc = $ _doc
      htmlAttrs = {}
      htmlTag = html.match(/<html(.+?)>/)
      pairs = htmlTag[1].match(/\w+="\w+"/g)
      for pair in pairs
        [X, key, value] = pair.match(/(\w+)="(\w+)"/)
        htmlAttrs[key] = value

      stackItem.set
        header: doc.find("header:first")[0]
        content: doc.find("#content")[0]
        title: doc.find("title").text()
        htmlAttrs: htmlAttrs

  popStack: ->
    @stack.pop()

jQuery ->
  Stacker.app = new Stacker.App el: $("#content")