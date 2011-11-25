class AS.Binding  
  constructor: (@context, @model, @field, @options={}, @fn=undefined) ->
    if _.isFunction(@options)
      [@fn, @options] = [@options, {}]
    
    @container = $ @context.current_node
    @binding_group = @context.binding_group
    
    @content = $ []

    if @constructor.will_group_bindings?
      @context.group_bindings (binding_group) => 
        @binding_group = binding_group
        @initialize()
    else
      @initialize()
  
  field_value: -> @model[@field]()
  
class AS.Binding.Model
  constructor: (@context, @model, @content=$([])) ->
    @styles = {}
    @attrs = {}
  
  css: (properties) ->
    for property, options of properties
      do (property, options) =>
        @styles[property] = => 
          options.fn(@model)
        
        painter = -> @content.css property, @styles[property]()
        
        @context.binds @model, "change:#{options.field}", painter, this
  
  attr: (attrs) ->
     for property, options of attrs
       do (property, options) =>
          @attrs[property] = =>
            if options.fn
              options.fn(@model)
            else
              if @model[options.field]() then "yes" else "no"
        
          painter = -> @content.attr property, @attrs[property]()
          
          @context.binds @model, "change:#{options.field}", painter, this
  
  width: (fn) ->
    @width_fn = =>
      fn(@model)
  
  height: (fn) ->
    @height_fn = =>
      fn(@model)
  
  paint: =>
    attrs = {}
    attrs[key] = fn() for key, fn of @attrs
    
    styles = {}
    styles[property] = fn() for property, fn of @styles
    
    @content.attr attrs
    @content.css styles
    @content.width @width_fn() if @width_fn
    @content.height @height_fn() if @height_fn

class AS.Binding.Field extends AS.Binding

  initialize: ->
    @content = @make_content()
    @set_content()
    @context.binds @model, "change:#{@field}", @set_content, this

  set_content: =>
    @content.text @field_value()

  make_content: ->
    $ @context.span()
    
class AS.Binding.Input extends AS.Binding.Field

  make_content: ->
    input = $ @context.input(@options)
    @context.binds input, "change", @set_field, this
    input
    
  set_content: ->
    @content.val @model[@field]()
  
  set_field: =>
    @model[@field] @content.val()

class AS.Binding.HasMany extends AS.Binding
  @will_group_bindings = true
  
  initialize: ->
    @collection = @field_value()
    
    @contents = {}
    @bindings = {}
        
    @collection.each @make_content
    
    @context.binds @collection, "add", @insert_item, this
    @context.binds @collection, "remove", @remove_item, this

  skip_item: (item) ->
    return false unless @options.filter
    
    for key, value of @options.filter
      value = _([value]).flatten()
      return true unless _(value).include(item[key]())
    
    false
    
  insert_item: (item) =>
    return if @skip_item(item)
    content = @context.dangling_content => @make_content(item)
    index = @collection.indexOf(item).value?()
    index ?= 0
    siblings = @container.children()
    if siblings.get(0) is undefined or siblings.get(index) is undefined
      @container.append(content)
    else
      $(siblings.get(index)).before(content)
    
  remove_item: (item) =>
    return if @skip_item(item)
    @contents[item.cid].remove()
    delete @contents[item.cid]
    
    @bindings[item.cid].unbind()
    delete @bindings[item.cid]

  make_content: (item) =>
    return if @skip_item(item)
    content = $ []
    @context.within_binding_group @binding_group, =>
      @context.group_bindings =>
        @bindings[item.cid] = @context.binding_group
        binding = new AS.Binding.Model(@context, item, content)
        made = @fn.call(@context, AS.ViewModel.build(@context, item), binding)
        if made?.jquery
          content.push made[0]
        else
          content.push made
        
        binding.paint()

    @contents[item.cid] = content
    return content

class AS.Binding.Collection extends AS.Binding.HasMany
  field_value: -> @model

# use case: RadioSelectionModel
# ala-BAM-a
# @element_focus.binding "selected", (element) ->
#   new Author.Views.ElementBoxAS.Binding(this, @div class:"Focus", element)
# 
# @element_selection.binding "selected", (element) ->
#   new Author.Views.ElementBoxBinding(this, @div class:"Selection", element)
  
class AS.Binding.BelongsTo extends AS.Binding
  @will_group_bindings = true
  
  initialize: ->
    @make_content()
    @context.within_binding_group @binding_group, =>
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
          if made?.jquery
            @content.push made[0]
          else
            @content.push made
          binding.paint()
          @content
    else
      @content = $ []
