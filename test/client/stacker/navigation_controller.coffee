NavigationTest = setup: ->
  @dom = $ """
    <section>
      <a href='#' class='basic-link'></a>
      <a href='#' stacker='reset'></a>
    </section>
  """
  @controller = new Stacker.NavigationController(
    @dom, new Stacker.NetworkController, (@stack = new Stacker.Cards), new Stacker.HistoryController(@stack, new MockHistory)
  )
  @click = (target) =>
    @dom.find(target+":first").trigger("click")

module "NavigationController", NavigationTest
test "intercepts link clicks", ->
  @click ".basic-link"
  equal @stack.length, 1

# test "intercepts reset link clicks", ->
#   @click ".basic-link"
#   @click "[stacker=reset]"
#   # equal @stack.length, 0
#   ok true
