@module "AS.CK.Binding"
render = (locals, template) ->
  locals.hardcode = AS.TemplateHelpers
  jQuery CoffeeKup.render template, locals

add_remove_do = (elements..., fn) ->
  element.appendTo(document.body) for element in elements
  fn.call()
  element.remove() for element in elements

test "bind", ->
  model = new AS.Model
  model.set property:"value"
  
  bound = render model:model, ->
    div -> bind @model, "property"
    
  bound_get = render model:model, ->
    div -> bind @model, "property", -> "#{this}-GOT"
    
  add_remove_do bound, bound_get, =>
    equal bound.find("span").text(), "value", "binds initial value to a span"
    equal bound_get.find("span").text(), "value-GOT", "processes value through getter"
    model.set property:"new"
    equal bound.find("span").text(), "new", "updates value in place when bound property changes"
    equal bound_get.find("span").text(), "new-GOT", "processes updated value in place through getter"
    model.destroy()
    ok bound.find("span").get(0) is undefined, "remove binding from dom when model is destroyed"
    ok bound_get.find("span").get(0) is undefined, "removes binding from dom when model is destroyed"

test "bound_input", ->
  model = new AS.Model
  model.set property:"value"
  
  bound = render model:model, ->
    div -> bound_input @model, "property"
  
  add_remove_do bound, =>
    input = bound.find("input")
    equal input.val(), "value", "binds initial value to input"
    
    model.set property:"new"
    equal input.val(), "new", "updates input when model changes"
    
    input.val("keyup")
    input.trigger("keyup")
    equal model.get("property"), "keyup", "updates model on keyup of input"
    
    input.val("change")
    input.trigger("change")
    equal model.get("property"), "change", "updates model on change of input"

test "bound_select", ->
  model = new AS.Model
  options = new AS.Collection
  option = new AS.Model value:"option1"
  added_option = new AS.Model value:"option2"
  options.add option
  
  bound = render model:model, options:options, ->
    div -> bound_select @model, "property", @options, "value"
  
  add_remove_do bound, =>
    select = bound.find("select")
    equal select.find("[value=#{option.cid}]option").text(), "option1", "renders given options from collection"
    
    options.add added_option
    added_option_node = select.find("[value=#{added_option.cid}]option")
    equal added_option_node.text(), "option2", "adds option to select when item added to collection"
    
    select.val(added_option.cid)
    select.trigger("change")
    equal model.get("property"), added_option, "sets value on model when property chosen"
    
    model.set property:option
    equal select.val(), option.cid, "changes value of select when property set on model"
    
    option.set value:"changed option"
    equal select.find("[value=#{option.cid}]option").text(), "changed option", "changes select text when option model value changes"
    
    options.remove option
    equal select.find("[value=#{option.cid}]option").get(0), undefined, "removes option from select when item added to collection"
    equal model.get("property"), added_option, "reselects another option when option removed"
  
test "bound_select with blank", ->
  model = new AS.Model
  options = new AS.Collection
  option = new AS.Model value:"option1"
  options.add option

  with_blank = render model:model, options:options, ->
    div -> bound_select @model, "property", @options, "value", blank:"blank"

  add_remove_do with_blank, =>
    select = with_blank.find("select")
    equal select.find("option:first").text(), "blank", "includes blank option"
    equal select.val(), "blank", "starts out without selection selected"
    equal model.get("property"), undefined, "leaves model property clear"
  
test "bound_select with preselect", ->
  model = new AS.Model
  options = new AS.Collection
  option = new AS.Model value:"option1"
  options.add option
  model.set property:option
  
  with_preselect = render model:model, options:options, ->
    div -> bound_select @model, "property", @options, "value", blank:"blank"
  
  add_remove_do with_preselect, =>
    select = with_preselect.find("select")
    equal select.find("option:first").text(), "blank", "includes blank option"
    equal select.val(), option.cid, "starts out with selection selected"
    
    
    
  
  