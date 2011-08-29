@module "AS.CK.Tags"
render = (locals, template) ->
  locals.hardcode = AS.TemplateHelpers
  jQuery CoffeeKup.render template, locals

test "model tag", ->
  model = new AS.Model
  defaults = render model:model, -> model_tag @model
  tagnamed = render model:model, -> model_tag @model, tagname: "ul"
  content = render model:model, -> 
    model_tag @model, -> p "content"
  optioned = render model:model, ->
    model_tag @model, key:"value"
  
  ok defaults.is("div##{model.cid}"), "renders div with model cid by default"
  ok tagnamed.is("ul##{model.cid}"), "renders tagname when given as an option"
  equal content.find("p").text(), "content", "renders nested content when given as a function"
  ok optioned.is("[key=value]"), "renders other options passed"