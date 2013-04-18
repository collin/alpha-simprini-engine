NavigationTest = setup: ->
  @dom = $ """
    <section>
      <!-- Bunch of Links -->
      <a href='#' class='basic-link'></a>
      <a href='#' class='other-link'></a>
      <a href='#' class='third-link'></a>
      <a href='#' class='fourth-link'></a>
      <a href='#' stacker='reset'></a>


      <!-- Bunch of Query Links -->
      <a href='?search=query#' class='local-query'></a>
      <a href='somewhere?search=query#' class='navigating-query'></a>


      <!-- Rails style ujs links -->
      <a href="#" data-method='delete' data-confirm='Oh Really?'></a>      
      <a href="#" data-method='put' data-confirm='Oh Really?'></a>
    </section>
  """
  @controller = new Stacker.NavigationController(
    @dom, new Stacker.NetworkController, (@stack = new Stacker.Cards), @history = new Stacker.HistoryController(@stack, @mockHistory = new MockHistory, new MockStorage)
  )
  @click = (target) =>
    @dom.find(target+":first").trigger("click")

  # neuter network access
  @controller.network.fetchCardData = ->

module "NavigationController", NavigationTest
test "intercepts link clicks", ->
  @click ".basic-link"
  equal @stack.length, 1

test "adds items to stack after the current item, remove items ahead of that position", ->
  @click ".basic-link"
  @click ".other-link"
  @click ".third-link"
  @history.popstate(state:@stack.at(1))
  @click ".fourth-link"
  equal @stack.length, 3
  equal @history.currentStack().length, 3

test "intercepts reset link clicks, which creates a new stack", ->
  @click ".basic-link"
  starterStack = @history.currentStack()
  @click "[stacker=reset]"
  equal @stack.length, 2, "HistoryStack extends by one."
  equal starterStack.length, 1, "The previous stack doesn't grow."
  notEqual @history.currentStack().cid, starterStack.cid, "We're working in a new stack."
  equal @history.currentStack().length, 1, "And that stack isn't empty."

test """
  Uses replaceState on get requests with query strings.
  But only when the pathname matches the current state.
""", ->
  @click ".basic-link"
  @click ".local-query"
  equal @history.stack.length, 1, "Replaced state, so history stack doesn't change."
  @click ".navigating-query"
  equal @history.stack.length, 2, "Searched on a different pathname, so history stack changes."

test """
  Updates currentCard link.
  Fetches replacement content for local searches.
""", ->
  @click ".basic-link"
  @controller.network.fetchCardData = (card) => 
    equal card.id, @history.currentCard().id, "Mocked out method."
  @click ".local-query"
  # equal @history.currentCard().get('link'), "/index.html?search=query#"
