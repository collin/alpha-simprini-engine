module "Stacker.View"
test "creates markup with #tag", ->
  view = new Stacker.View
  view.tag 'section'
  ok view.$el.find('section').is('section')

test "creates nested markup with #tag", ->
  view = new Stacker.View
  view.tag 'section', -> @tag 'section'
  ok view.$el.find('section section').is('section')

test "sets tag attributes with #tag", ->
  view = new Stacker.View
  view.tag 'section', someAttr: true
  ok view.$el.find('[someAttr=true]').is('section')

test "text content in views", ->
  view = new Stacker.View
  view.tag 'p', -> @text "Hello World"
  ok view.$el.find('p').text() is "Hello World"