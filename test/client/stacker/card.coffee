CardTest = setup: ->
  @card = makeCard()
  @html = @card.get('html')

module "Stacker.Card", CardTest

test "toJSON", ->
  json = @card.toJSON()
  equal json.html, @html
  equal json.link, "URL"

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
  deepEqual card.get('htmlAttrs'), attr:'value'
