NetworkTest = setup: ->
  @net = new Stacker.NetworkController

module "Stacker.NetworkController#fetchCardData", NetworkTest

test "performs an ajax call for card url", ->
  card = new Stacker.Card link:"URL"
  @net.get = (config) -> 
    equal config.url, "URL"
    $.Deferred() # Fake a promise

  @net.fetchCardData(card)


test "when ajax returns, sets data from response html", ->
  card = new Stacker.Card link:"URL"
  @net.get = (config) -> 
    $.Deferred().resolve """
      <html attr='value'>
        <head>
          <title>TITLE</title>
        </head>
        <body>
          <header>HEADER</header>
          <section id="content">CONTENT</section>
        </body>
      </html>
    """

  @net.fetchCardData(card)

  equal card.get('title'), "TITLE"
  equal card.get('header').text(), "HEADER"
  equal card.get('content').text(), "CONTENT"
  deepEqual card.get('htmlAttrs'), {attr:'value'}
