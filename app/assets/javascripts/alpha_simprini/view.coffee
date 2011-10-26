# module "AS", ->
#   class: (value) ->
#     @el.removeClass(@prior)
#     @el.addClass(value)
#     @prior = value
#     
#   default: (value) ->
#     @el.attr(value)
#     
#   class BindableElement
# 
#     constructor: (args) ->
#       # body...
# 
module "AS", ->
  class @View extends @HTML
    AS.Event.extends(this)
    
    tag_name: "div"
    
    _ensure_element: -> @el ?= $(@build_element())
    
    constructor: (config={}) ->
      @cid = _.uniqueId("c")
      for key, value in config
        @[key] = new ViewModel(this, value)
      @_ensure_element()
      @delegateEvents()
      @initialize()
    
    initialize: ->
    
    binding: (model, field, fn) ->
      if fn
        model.bind "change:#{field}.#{@cid}", fn
        fn() # call in place so data rendered now
      else
        content = $ @text -> model[field]()
        model.bind "change:#{field}.#{@cid}", -> content.text model[field]()
        content 
    
    # bind_style: () ->
    #   
    # 
    # bind_attribute: (emitter, event, ) ->
    #   
    
    unbind_from_collection: (collection) ->
      $(@current_node).empty()
      collection.unbind(".#{@cid}")
    
    bind_to_selection_collection: (selection_model, collection, fn) ->
      container = @current_node

      selection_model.bind "change:selected", =>
        selection = selection_model.selected()
        previous_selection = selection_model.last('selected')

        if previous_selection
          @within_node container, ->
            @unbind_from_collection previous_selection[collection]()

        if selection
          @within_node container, ->
            @bind_to_collection selection[collection](), fn
    
    bind_to_collection: (collection, fn) ->
      byCid = {}
      content_fn = (item) =>
        byCid[item.cid] = $ fn.call(this, item)
      
      container = $ @current_node

      collection.models.each content_fn

      collection.bind "add.#{@cid}", (item) =>
        content = @dangling_content -> content_fn(item)
        index = collection.indexOf(item).value?()
        index ?= 0
        siblings = container.children()
        if siblings.get(0) is undefined or siblings.get(index) is undefined
          container.append(content)
        else
          $(siblings.get(index)).before(content)

      collection.bind "remove.#{@cid}", (item) =>
        byCid[item.cid].remove()
        delete byCid[item.cid]
    
    klass_string: (parts=[]) ->
      if @constructor is AS.View
        parts.push "ASView"
        parts.reverse().join " "
      else
        parts.push @constructor.name
        @constructor.__super__.klass_string.call @constructor.__super__, parts

    element_string: ->
      base = "#{@tagName}.#{@klass_string()}"
    
      if @model and @model.cid
        base += "##{@model.cid}"
    
      if @model and @model.constructor.name
        base += ".#{@model.constructor.name}"
    
      base
    
    base_attributes: ->
      attrs =
        class: @klass_string()
        id: @cid
      
    build_element: ->
      @current_node = @[@tag_name](@base_attributes())
  
    delegateEvents: () ->
      if @events
        @standard_events = new AS.ViewEvents(this, @events)
        @standard_events.apply_bindings()
      
      state_events = _(@constructor::).chain().keys().filter (key) -> 
        _(key).endsWith("_events")
      @state_events = {}
      for key in state_events.value()
        state = key.replace(/_events$/, '')
        do (key, state) =>
          @state_events[state] = new AS.ViewEvents(this, @[key])
          
          @["exit_#{state}"] = ->
            @trigger("exitstate:#{state}")
            @state_events[state].revoke_bindings()
          
          @["enter_#{state}"] = -> 
            @trigger("enterstate:#{state}")
            @state_events[state].apply_bindings()


    reset_cycle: (args...) ->
      delete @_cycles[args.join()] if @_cycles

    cycle: (args...) ->
      @_cycles ?= {}
      @_cycles[args.join()] ?= 0
      count = @_cycles[args.join()] += 1
      args[count % args.length]

    toggle: ->
      @button class:"toggle expand"
      @button class:"toggle collapse"
        
    field: (_label, options = {}, fn = ->) ->
      if _.isFunction options
        fn = options
        options = {}
        
      @div ->
        @label _label
        @input(options)
        fn?.call(this)
        
    choice: (_label, options = {}, fn = ->) ->
      if _.isFunction options
        fn = options
        options = {}
      options.type = "checkbox"
      
      @field _label, options, fn

