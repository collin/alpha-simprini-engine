module "Stacker.App"
test "it does some shit", ->
  root = $ """
    <section>
      <header></header>
      <section id="content"></section>
    </section>
  """
  app = new Stacker.App(root, new MockHistory)
  console.log root.html()