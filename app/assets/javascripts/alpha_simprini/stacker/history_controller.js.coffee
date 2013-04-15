class Stacker.HistoryController
  @START: {start:true}
  START: @START
  constructor: (@stack, @history, @storage) ->
    console.log "Starting State", @history.state

    @forwardStack = Stacker.alloc(Stacker.Cards)

    if @_madeState(@history.state)
      @loadStash() 

    @stack.on 'add', => @clearForwardStack()
    @stack.on 'add', (item) => @pushState(item)
    @stack.on 'jump', (count) => history.go(count)

    @stack.on 'add remove change', @stash

    $(window).on 'popstate', (event) => @popstate(event.originalEvent)

    if @_madeState(@history.state)
      @popstate @history
    # else
    #   @history.replaceState @START, null, location.href

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
