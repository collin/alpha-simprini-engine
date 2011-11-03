class AS.Binding
  @group_bindings: -> @will_group_bindings = true
  
  constructor: (@context, @model, @field, @fn=undefined) ->
    @container = $ @context.current_node
    @binding_group = @context.binding_group
    
    @content = $ []

    if @will_group_bindings?
      @context.group_bindings (binding_group) => 
        @binding_group = binding_group
        @initialize()
    else
      @initialize()
  
  field_value: -> @model[@field]()
  
class AS.Binding.Model
  constructor: (@context, @model, @content=$([])) ->
    @styles = {}
  
  css: (properties) ->
    for property, options of properties
      do (property, options) =>
        @styles[property] = => 
          options.fn(@model)
        
        painter = -> @content.css property, @styles[property]()
        
        @context.binds @model, "change:#{options.field}", painter, this
  
  width: (fn) ->
    @width_fn = =>
      fn(@model)
       
  
  height: (fn) ->
    @height_fn = =>
      fn(@model)
  
  paint: =>
    styles = {}
    styles[property] = fn() for property, fn of @styles
    @content.css styles
    @content.width @width_fn() if @width_fn
    @content.height @height_fn() if @height_fn

class AS.Binding.Field extends AS.Binding

  initialize: ->
    @content = $ @context.span()
    @set_content()
    @context.binds @model, "change:#{@field}", @set_content, this

  set_content: =>
    @content.text @field_value()
  
class AS.Binding.HasMany extends AS.Binding
  @group_bindings()
  
  initialize: ->
    @collection = @field_value()
    
    @contents = {}
    @bindings = {}
        
    @collection.each @make_content
    
    @context.binds @collection, "add", @insert_item, this
    @context.binds @collection, "remove", @remove_item, this

  insert_item: (item) =>
    content = @context.dangling_content => @make_content(item)
    index = @collection.indexOf(item).value?()
    index ?= 0
    siblings = @container.children()
    if siblings.get(0) is undefined or siblings.get(index) is undefined
      @container.append(content)
    else
      $(siblings.get(index)).before(content)
    
  remove_item: (item) =>
    @contents[item.cid].remove()
    delete @contents[item.cid]
    
    @bindings[item.cid].unbind()
    delete @bindings[item.cid]

  make_content: (item) =>
    content = $ []
    @context.within_binding_group @binding_group, =>
      @context.group_bindings =>
        @bindings[item.cid] = @context.binding_group
        binding = new AS.Binding.Model(@context, item, content)
        made = @fn.call(@context, AS.ViewModel.build(@context, item), binding)
        if made.jquery
          content.push made[0]
        else
          content.push made
        
        binding.paint()

    @contents[item.cid] = content
    return content

# use case: RadioSelectionModel
# ala-BAM-a
# @element_focus.binding "selected", (element) ->
#   new Author.Views.ElementBoxAS.Binding(this, @div class:"Focus", element)
# 
# @element_selection.binding "selected", (element) ->
#   new Author.Views.ElementBoxBinding(this, @div class:"Selection", element)
  
class AS.Binding.BelongsTo extends AS.Binding
  @group_bindings()
  
  initialize: ->
    @make_content()
    @context.binds @model, "change:selected", @selection_changed, this

  selection_changed: =>
    @content.remove()
    @binding_group.unbind()
    @initialize()
    
  make_content: ->
    item = @field_value()
    if item
      @context.within_binding_group @binding_group, =>
        @context.within_node @container, =>
          @content = $ []
          binding = new AS.Binding.Model(@context, item, @content)
          made = @fn.call(@context, AS.ViewModel.build(@context, item), binding)
          if made.jquery
            @content.push made[0]
          else
            @content.push made
          binding.paint()
          @content
    else
      @content = $ []
