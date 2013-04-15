class Stacker.Cards extends Backbone.Collection
  model: Stacker.Card

  constructor: (models=[], options={}) ->
    super
    @cid = _.uniqueId('c')
    @id ||= options.id || _.uniqueId('id-')

  @fromJSON: (data) ->
    cards = Stacker.alloc(this)
    for item in data
      cards.add Stacker.fromJSON(Stacker.Card, item)
    cards
