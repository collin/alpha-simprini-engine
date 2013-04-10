#= require underscore
#= require backbone
window.Stacker = {}

Stacker.Repo = new Backbone.Collection
Stacker.alloc = (klass, attrs) -> @Repo.add item = new klass(attrs); item
Stacker.get = (id) -> @Repo.get(id)
Stacker.flush = -> @Repo.set [], silent:true

Stacker.fromJSON = (klass, json) ->
  klass.fromJSON(json, Stacker.Repo)

class Stacker.Card extends Backbone.Model

  constructor: ->
    super
    @get('id') or @set(id: _.uniqueId('id-') )

  _validate: -> true

  @fromJSON: (data, repository) ->
    console.log "Stacker.Card#fromJSON", data
    stackId = data.stackId
    data.stackId = undefined
    data.stack = repository.get(stackId)
    card = Stacker.alloc Stacker.Card, data
    Stacker.updateCardFromHtml(card, data.html)
    card

  toJSON: ->
    data = _.pick @attributes, 'html', 'link', 'id'
    data.stackId = @get('stack').id
    data

  toString: ->
    "<Stacker.Card #{@cid} #{@get 'title'}>"

class Stacker.Cards extends Backbone.Collection
  model: Stacker.Card

  constructor: ->
    super
    @cid = _.uniqueId('c')
    @id ||= _.uniqueId('id-')

  @fromJSON: (data) ->
    cards = Stacker.alloc(this)
    for item in data
      cards.add Stacker.fromJSON(Stacker.Card, item)
    cards

class Stacker.View extends Backbone.View
  find: (args...) -> @$el.find(args...)

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

    @listenTo @model, 'add', => @render()
    @listenTo @model, 'remove', => @render()
    @listenTo @model, 'change', => @render()

  replaceHeader: (replacement) ->
    return false unless replacement?
    return false if replacement[0] is @options.header[0]
    @options.header.replaceWith replacement
    @options.header = replacement

  popStack: ->
    @model.pop()

  jumpStack: (event) ->
    top = @model.last()
    cid = $(event.target).closest('.stack-item-under').data('stack-item-cid')
    item = @model.get(cid)
    count = 0
    for _item in @model.slice(@model.indexOf(item) + 1).reverse()
      # @model.remove(_item, silent:true)
      count -= 1
    @model.trigger('jump', count)
    @render()

  render: =>
    stack = if last = @model.last()
      last.get('stack')

    stack ||= Stacker.alloc(Stacker.Cards)

    lastIndex = stack.indexOf( last )

    @$el.empty()
    @tag 'ol', class:'stack-item-container', ->
      for card, index in stack.slice(0, lastIndex)
        item = @tag 'li', class:'stack-item stack-item-under', 'data-stack-item-cid':card.cid, ->
          @tag 'label', class:'stack-item-title', ->
            @text card.get('title')

        $(item).css
          top: index*@distance
          left: (index*@distance)/2

      title = null
      if last
        item = $ @tag 'li', class:'stack-item stack-item-top', 'data-stack-item-cid':last.cid, ->
          title = $ @tag 'label', class:'stack-item-title', ->
            @text last.get('link')

        @replaceHeader last.get('header')

        item.css
          top: lastIndex  * @distance
          left: (lastIndex * @distance)/2

        item.append content if content = last.get('content')
        title.text titleText if titleText = last.get('title')
        $('html').attr(htmlAttrs) if htmlAttrs = last.get('htmlAttrs')


        @find(".stack-item-under").css height: item.height()
        @find(".stack-item").css width: @$el.width()

    this

Math.floor(Math.random() * 10000000000).toString(36)

class Stacker.HistoryController
  @START: {start:true}
  START: @START
  constructor: (@stack, @history, @storage) ->
    console.log "Starting State", @history.state

    @forwardStack = Stacker.alloc(Stacker.Cards)

    @loadStash() if @_madeState(@history.state)

    @stack.on 'add', => @clearForwardStack()
    @stack.on 'add', (item) => @pushState(item)
    @stack.on 'jump', (count) => history.go(count)

    for stack in [@stack, @forwardStack]
      do (stack) =>
        stack.on 'add', (model) -> model?.set('stack', stack)

    @stack.on 'add remove change', @stash

    $(window).on 'popstate', (event) => @popstate(event.originalEvent)

    if @_madeState(@history.state)
      @popstate @history
    else
      @history.replaceState @START, null, location.href

  currentCard: -> @stack.last()

  currentStack: -> @currentCard()?.get('stack')

  loadStash: ->
    return unless raw = @storage.getItem "Stacker-stash"
    data = JSON.parse(raw)

    @stack.set Stacker.Cards.fromJSON(data.stack).models, silent:true
    @forwardStack.set Stacker.Cards.fromJSON(data.forwardStack).models, silent:true

  stash: =>
    @storage.setItem "Stacker-stash", JSON.stringify(
      stack: @stack.toJSON(),
      forwardStack: @forwardStack.toJSON()
    )

  popstate: ({state}) ->
    console.log "POPSTATE", state
    return false unless state?.id? or state?.start is true

    if state.id and item = @stack.get(state)
      list = @stack.slice @stack.indexOf(item) + 1, @stack.length
      @stack.remove(item, silent:true) for item in list
      @forwardStack.add(item, at:0) for item in list.reverse()

    else if state.id and item = @forwardStack.get(state)
      list = @forwardStack.slice 0, @forwardStack.indexOf(item) + 1
      @forwardStack.remove(item) for item in list
      @stack.add(item, silent:true) for item in list

    else if state.start is true
      for item in @stack.slice().reverse()
        @forwardStack.add(item, at:0)
      @stack.set([], silent: true)

    @stack.trigger('change')

  pushState: (item) ->
    return unless item
    state = id:item.get('id'), namespace:"Stacker.HistoryController"
    @history.pushState(state, null, item.get('link'))

  clearForwardStack: ->
    @forwardStack.set [], silent:true

  _madeState: (state) ->
    state?.namespace is "Stacker.HistoryController"

class Stacker.NavigationController
  constructor: (@root, @network, @stack, @history) ->
    @root.delegate "a", "click", @link

  link: (event) =>
    link = event.target
    stack = @history.currentStack() || Stacker.alloc(Stacker.Cards)
    stack = Stacker.alloc(Stacker.Cards) if $(link).is('[stacker=reset]')
    card = Stacker.alloc(Stacker.Card, link:link.href, stack:stack)

    currentCard = @history.currentCard()
    if (stack.include currentCard) && (stack.last() isnt currentCard)
      stack.set stack.slice 0, stack.indexOf(currentCard) + 1, silent: true
    @stack.add card
    stack.add card
    card.set('stack', stack)
    event.preventDefault()
    @network.fetchCardData(card)

Stacker.updateCardFromHtml = (card, html) ->
  _doc = document.createElement('html')
  _doc.innerHTML = html
  doc = $ _doc
  htmlAttrs = {}
  htmlTag = html.match(/<html(.+?)>/)
  pairs = htmlTag?[1].match(/\w+="\w+"|\w+='\w+'/g) || []

  for pair in pairs
    [X, key, value] = pair.match(/(\w+)=(?:"|')(\w+)(:?"|')/)
    htmlAttrs[key] = value

  card.set
    header: doc.find("header:first")
    content: doc.find("#content")
    title: doc.find("title").text()
    html: html
    htmlAttrs: htmlAttrs

class Stacker.NetworkController
  fetchCardData: (card) ->
    request = @get url: card.get('link')
    request.then _.bind Stacker.updateCardFromHtml, null, card

  get: (config) ->
    $.get(config.url)

class Stacker.App
  constructor: (@root, options={}) ->
    options.history ||= window.history
    options.storage ||= window.sessionStorage
    
    @networkController = Stacker.NetworkController
    @historyStack = Stacker.alloc(Stacker.Cards)
    @historyController = new Stacker.HistoryController(
      @historyStack, options.history, options.storage
    )
    @navigationController = new Stacker.NavigationController(
      @root, @networkController, @historyStack, @historyController
    )
    @stackView = new Stacker.StackView 
      model:@historyStack, 
      el:options.container, 
      header:options.header
