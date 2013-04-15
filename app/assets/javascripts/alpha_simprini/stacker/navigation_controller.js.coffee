class Stacker.NavigationController
  constructor: (@root, @network, @stack, @history) ->
    @root.delegate "a", "click", @link
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