NavigationTest = setup: ->
  @dom = $ """
    <section>
      <a href='#' class='basic-link'></a>
      <a href='#' stacker='reset'></a>
    </section>
  """
  @controller = new Stacker.NavigationController(
    @dom, new Stacker.NetworkController, (@stack = new Stacker.Cards), @history = new Stacker.HistoryController(@stack, new MockHistory)
  )
  @click = (target) =>
    @dom.find(target+":first").trigger("click")

module "NavigationController", NavigationTest
test "intercepts link clicks", ->
  @click ".basic-link"
  equal @stack.length, 1

test "intercepts reset link clicks, which creates a new stack", ->
  @click ".basic-link"
  starterStack = @history.currentStack()
  @click "[stacker=reset]"
  equal @stack.length, 2
  notEqual @history.currentStack().cid, starterStack.cid
