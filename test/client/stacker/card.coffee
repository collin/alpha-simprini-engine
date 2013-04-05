CardTest = setup: ->
  @card = makeCard()
  @html = @card.get('html')

module "Stacker.Card", CardTest

test "sets an id", ->
  notEqual @card.id, undefined

test "toJSON", ->
  json = @card.toJSON()
  equal json.html, @html
  equal json.link, "URL"
  equal json.id, @card.get('id')

  equal json.header, undefined
  equal json.title, undefined
  equal json.content, undefined
  equal json.htmlAttrs, undefined

test "fromJSON", ->
  json = @card.toJSON()
  card = Stacker.Card.fromJSON(json)

  equal card.get('header').text(), "HEADER"
  equal card.get('title'), "TITLE"
  equal card.get('content').text(), "CONTENT"
  equal card.get('id'), @card.get('id')
  deepEqual card.get('htmlAttrs'), attr:'value'
