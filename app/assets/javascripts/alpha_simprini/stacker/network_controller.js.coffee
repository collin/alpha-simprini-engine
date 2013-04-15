Stacker.updateCardFromHtml = (card, html="") ->
  _doc = document.createElement('html')
  _doc.innerHTML = html
  doc = $ _doc
  htmlAttrs = {}
  htmlTag = html.match(/<html(.+?)>/)
  pairs = htmlTag?[1].match(/\w+="\w+"|\w+='\w+'/g) || []

  for pair in pairs
    [X, key, value] = pair.match(/(\w+)=(?:"|')(\w+)(:?"|')/)
    htmlAttrs[key] = value

  _.extend card.attributes,
    header: doc.find("header:first")
    content: doc.find("#content")
    title: doc.find("title").text()
    html: html
    htmlAttrs: htmlAttrs

  card.trigger 'change'

class Stacker.NetworkController
  fetchCardData: (card) ->
    return unless card
    request = @get url: card.get('link')
    request.then _.bind Stacker.updateCardFromHtml, null, card

  get: (config) ->
    $.get(config.url)
