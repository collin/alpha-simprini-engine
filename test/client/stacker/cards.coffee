module "Stacker.Cards"
test "Is a Backbone Collection", ->
  ok new Stacker.Cards instanceof Backbone.Collection

test "#model is Stacker.Card", ->
  ok (new Stacker.Cards).model is Stacker.Card