module "AS", ->
  class @View extends @HTML
    AS.Event.extends(this)
    
    tag_name: "div"
    
    _ensure_element: -> @el ?= $(@build_element())
    
    constructor: (config={}) ->
      @cid = _.uniqueId("c")
      _.extend this, config
      @_ensure_element()
      @delegateEvents()
      @initialize()
    
    initialize: ->
    
    binding: (model, field) ->
      content = $ @text -> model[field]()
      model.bind "change:#{field}", -> content.text model[field]()
    
    bind_to_collection: (collection, fn) ->
      byCid = {}
      content_fn = (item) =>
        byCid[item.cid] = $ fn.call(this, item)

      container = $ @current_node

      collection.models.each content_fn

      collection.bind "add", (item) =>
        content = @dangling_content -> content_fn(item)
        index = collection.indexOf(item).value()
        siblings = container.children()
        if siblings.get(0) is undefined or siblings.get(index) is undefined
          container.append(content)
        else
          $(siblings.get(index)).before(content)

      collection.bind "remove", (item) =>
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

    event_splitter: /^([\w:]+)(\{.*\})?\s*(.*)$/
  
    delegateEvents: (events) ->
      events ?= @events
      events = events.call(this) if _.isFunction(events)
      for key, method of events
        throw new Error("Event \"#{events[key]}\" does not exist") unless method = @[method]
        match = key.match @event_splitter
        [__, event_name, guard, selector] = match
        event_name += ".delegateEvents#{@cid}"
        guard ?= "{}"
        guard = guard.replace(/(\w+):/g, (__, match) -> "\"#{match}\":")
        guard = JSON.parse(guard)
        
        do (event_name, guard, key, method, selector) =>
          _method = (event) =>
            for key, value of guard 
              return unless event[key] is value
            method.apply(this, arguments)
          if selector is ''
            @el.unbind event_name
            @el.bind event_name, _method
          else if selector[0] is '@'
            @[selector.slice(1)]?.unbind event_name
            @[selector.slice(1)]?.bind event_name, _method
          else
            $(selector, @el[0]).die event_name
            $(selector, @el[0]).live event_name, _method
    
    
    
    # template: ->
    #   h1 class: "TemplateNotFound", => """
    #     Template Not Found for view '#{@klass_string()}'
    #   """
    # 
    # appendTo: (object) ->
    #   if object.hasOwnProperty "el"
    #     @el.appendTo object.el
    #   else
    #     @el.appendTo object
