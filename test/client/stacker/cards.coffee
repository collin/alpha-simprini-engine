CardsTest = setup: ->
  @cards = new Stacker.Cards
  @cards.add makeCard()
  @cards.add makeCard()
  @cards.add makeCard()
  @cards.add makeCard()

module "Stacker.Cards", CardsTest
test "Is a Backbone Collection", ->
  ok new Stacker.Cards instanceof Backbone.Collection

test "#model is Stacker.Card", ->
  ok (new Stacker.Cards).model is Stacker.Card

test "toJSON", ->
  json = @cards.toJSON()
  equal json.length, 4
  deepEqual json, @cards.invoke('toJSON')

test "fromJSON", ->
  json = @cards.toJSON()
  cards = Stacker.Cards.fromJSON(json)
  equal cards.length, 4
