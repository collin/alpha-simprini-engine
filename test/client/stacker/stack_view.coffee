module "Stacker.CardsView"
test "adds container classes to container", ->
  view = makeStackView()
  ok view.$el.attr('class') is "stack-item-container container"

module "Stacker.CardsView#render", setup: -> 
  @view = makeStackView()

test "has a list of stack items", ->
  ok @view.find('> .stack-item-container').is('ol')

test "clears old list when re-rendering", ->
  @view.render()
  equal @view.find('> .stack-item-container').length, 1

test "has no stackItems", ->
  ok not @view.find('.stack-item').is("li")

module "Stacker.CardsView#render with one item", setup: ->
  stack = new Stacker.Cards
  stack.add {link:"HREF"}
  @view = makeStackView(stack)

test "renders a top stackItem", ->
  topItem = @view.find('.stack-item-top')
  ok topItem.is('li')
  ok topItem.find('.stack-item-title').is('*')
  equal topItem.find('.stack-item-title').text(), "HREF"

test "has no stack items underneath top item", ->
  ok not @view.find('.stack-item-under').is("li")

module "Stacker.CardsView#render with multiple items", setup: ->
  stack = new Stacker.Cards
  stack.add link:"Item1", title:"Item1"
  stack.add link:"Item1.2"
  stack.add link:"Item2"
  @view = makeStackView(stack)

test "renders items underneath top item", ->
  underItem = @view.find('.stack-item-under')
  ok underItem.is('li')
  equal underItem.length, 2
  equal underItem.data('stack-item-cid'), @view.model.at(0).cid
  ok underItem.find('.stack-item-title').is('*')
  equal underItem.find('.stack-item-title:first').text(), "Item1"

test "restricts underneath size to top item size", ->
  $(@view.el).appendTo(document.body)

  content = $('<section>').css(width: 500, height: 200)
  @view.model.last().set(content: content)
  @view.render()
  underItem = @view.find('.stack-item-under')
  topItem = @view.find('.stack-item-top')

  notEqual underItem.height(), 0
  notEqual underItem.width(), 0

  equal underItem.height(), topItem.height()
  equal underItem.width(), topItem.width()

  $(@view.el).remove()

test "renders under items at index-appropriate css positions", ->
  underItem = @view.find('.stack-item-under')

  equal $(underItem.get(0)).css('top'), '0px'
  equal $(underItem.get(0)).css('left'), '0px'

  equal $(underItem.get(1)).css('top'), '30px'
  equal $(underItem.get(1)).css('left'), '15px'

test "renders top item at index-appropriate css position", ->
  topItem = @view.find('.stack-item-top')
  equal topItem.css('top'), '60px'
  equal topItem.css('left'), '30px'

module "Stacker.CardsView#replaceHeader", setup: ->
  @view = makeStackView()

test "replaces header element", ->
  replacement = $("<header>")
  @view.replaceHeader replacement
  equal @view.options.header[0], replacement[0]

test "doesn't replace header element if it is the same element", ->
  replacement = @view.options.header
  equal @view.replaceHeader(replacement), false

module "Stacker.CardsView#render with content attributes", setup: ->
  @view = makeStackView()
  @view.model.add
    content: @content = $("<section>")
    header: @header = $("<header>")
    title: @title = "The Title"
    htmlAttrs: {'data-testattr':"HTML"}
  @view.render()

test "'header' replaces the header", ->
  equal @view.options.header[0], @header[0]

test "'content' appends content into topItem", ->
  equal @view.find(".stack-item-top > :last")[0], @content[0]

test "'title' changes the stack item title", ->
  equal @view.find(".stack-item-top .stack-item-title").text(), @title

test "'htmlAttrs' sets attrubutes on the <html> element", ->
  equal $("html").data('testattr'), "HTML"

module "Stacker.CardsView#popStack", setup: ->
  stack = new Stacker.Cards
  stack.add @item1 = new Stacker.Card link:"Item1"
  @view = makeStackView(stack)

test "pops the stack", ->
  equal @view.popStack().cid, @item1.cid

module "Stacker.CardsView#jumpStack", setup: ->
  stack = new Stacker.Cards
  stack.add @item1 = new Stacker.Card link:"Item1"
  stack.add new Stacker.Card link:"Item2"
  stack.add new Stacker.Card link:"Item3"
  @view = makeStackView(stack)

test "jumps down to the targeted element", ->
  @view.jumpStack target: @view.find('.stack-item')[0]
  equal @view.model.length, 1
  deepEqual @view.model.models, [@item1]

module "Stacker.CardsView listeners", setup: ->
  @view = makeStackView()
  @view.render = -> ok true

test "renders when model fires 'add' event", ->
  @view.model.trigger 'add'

test "renders when model fires 'remove' event", ->
  @view.model.trigger('remove')

test "renders when model fires 'change' event", ->
  @view.model.trigger('change')
