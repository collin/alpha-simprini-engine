class Stacker.Card extends Backbone.Model

  constructor: ->
    super
    @get('id') or @set(id: _.uniqueId('id-') )

  _validate: -> true

  @fromJSON: (data, repository) ->
    console.log "Stacker.Card#fromJSON", data
    stackId = data.stackId
    data.stackId = undefined
    stack = data.stack = repository.get(stackId) || Stacker.alloc(Stacker.Cards, [], id:stackId)
    card = Stacker.alloc Stacker.Card, data
    Stacker.updateCardFromHtml(card, data.html)
    stack.add card
    card

  toJSON: ->
    data = _.pick @attributes, 'html', 'link', 'id'
    data.stackId = @get('stack').id
    data

  toString: ->
    "<Stacker.Card #{@cid} #{@get 'title'}>"
