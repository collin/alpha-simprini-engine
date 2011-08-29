module "AS", ->
  class @View extends Backbone.View
    AS.Event.extends(this)
    
    _ensureElement: -> @el ?= @build_element()
    
    constructor: (config) ->
      _.extend this, config
      super
    
    klass_string: (parts=[]) ->
      if @constructor is AS.View
        parts.push "APView"
        parts.reverse().join "."
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
    
    build_element: ->
      jQuery.satisfy @element_string()
    
    event_splitter: /^([\w:]+)(\{.*\})?\s*(.*)$/
  
    delegateEvents: (events) ->
      events ?= @events
      events = events.call(this) if _.isFunction(events)
      for key, method of events
        throw new Error('Event "#{events[key]}" does not exist') unless method = @[method]
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
            method.call(this, event)
        
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
