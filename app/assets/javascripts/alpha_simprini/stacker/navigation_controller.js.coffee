class Stacker.NavigationController
  constructor: (@root, @network, @stack, @history) ->
    @root.delegate "a:not([data-method])", "click", @link

    @root.delegate "a[data-method='put'][data-remote=true]", 'ajax:success', @put
    @root.delegate "a[data-method='delete'][data-remote=true]", 'ajax:success', @delete
    @root.delegate "form[data-remote=true]", 'ajax:success', @formSuccess
    @root.delegate "form[data-remote=true]", 'ajax:error', @formError

    unless @history._madeState(history)
      console.warn "Doing shit from NavigationController that should be in HistoryController"
      @history.history.pushState(@history.START, null, window.location.href)
      unless card = @history.currentCard()
        card = Stacker.alloc(Stacker.Card, link:window.location.href, stack:Stacker.alloc(Stacker.Cards))
        card.get('stack').add(card)
        @history.stack.add(card)
      @network.fetchCardData(card)

  localSearch: (event) ->
    location.pathname is event.target.pathname

  formSuccess: (event, content, status, response) =>
    location = response.getResponseHeader("Location")
    anchor = document.createElement('a')
    anchor.href = location

    if @localSearch(target:anchor)
      # noop, we're probably in an index view
      @network.fetchCardData(@history.currentCard())
    else
      # go back, the current card was probably updated
      history.back()
      # Data is stale, so reload the top card, 
      # which is probably an index view.
      $(window).one 'popstate', =>
        # defer so browser history can go back first.
        console.log "formSuccess Fetch Content", @history.currentCard()
        @network.fetchCardData(@history.currentCard())


  formError: (event, response, status, errorText) =>
    # We got error content, let's show it.
    card = @history.currentCard()
    Stacker.updateCardFromHtml(card, response.responseText)

  put: (event, content, status, response) =>
    location = response.getResponseHeader("Location")
    anchor = document.createElement('a')
    anchor.href = location

    if @localSearch(target:anchor)
      # noop, we're probably in an index view
      @network.fetchCardData( @history.currentCard() )
    else
    # Data is stale, so reload the top card, 
    # which is probably an index view.
      # go back, the current card was probably updated
      history.back()
      $(window).one 'popstate', =>
        # defer so browser history can go back first.
        @network.fetchCardData( @history.currentCard() )


  delete: (event, content, status, response) =>
    location = response.getResponseHeader("Location")
    anchor = document.createElement('a')
    anchor.href = location
    currentCard = @history.currentCard()

    if @localSearch(target:anchor)
      # noop, we're probably in an index view
    else
      # go back, the current card was probably deleted
      history.back()

    # Data is stale, so reload the top card, 
    # which is probably an index view.
    @network.fetchCardData(currentCard)

  link: (event) =>
    link = event.target
    stack = @history.currentStack() || Stacker.alloc(Stacker.Cards)
    stack = Stacker.alloc(Stacker.Cards) if $(link).is('[stacker=reset]')

    if @localSearch(event)
      event.preventDefault()
      currentCard = @history.currentCard()
      history.replaceState history.state, undefined, event.target.href
      currentCard.set('link', event.target.href)
      @network.fetchCardData(currentCard)
      return

    card = Stacker.alloc(Stacker.Card, link:link.href, stack:stack)

    currentCard = @history.currentCard()
    if (stack.include currentCard) && (stack.last() isnt currentCard)
      stack.set stack.slice 0, stack.indexOf(currentCard) + 1, silent: true
    @stack.add card
    stack.add card
    card.set('stack', stack)
    event.preventDefault()
    @network.fetchCardData(card)