NavigationTest = setup: ->
  @dom = $ """
    <section>
      <a href='#' class='basic-link'></a>
      <a href='#' class='other-link'></a>
      <a href='#' class='third-link'></a>
      <a href='#' class='fourth-link'></a>
      <a href='#' stacker='reset'></a>
    </section>
  """
  @controller = new Stacker.NavigationController(
    @dom, new Stacker.NetworkController, (@stack = new Stacker.Cards), @history = new Stacker.HistoryController(@stack, new MockHistory, new MockStorage)
  )
  @click = (target) =>
    @dom.find(target+":first").trigger("click")

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
