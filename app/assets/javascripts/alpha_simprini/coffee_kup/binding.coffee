module "AS.CK", ->
  @Binding =
    binding: (model, property, getter) ->
      id = AS.CK.Helpers.autoId()
      model.bind "destroy", -> id.query().remove()
      if getter
        model.bind "change:#{property}", -> id.query().text getter.call(this, model.get(property)) || ""
        span id: id.string, -> getter.call(this, model.get(property))      
      else
        model.bind "change:#{property}", -> id.query().text model.get(property) || ""
        span id: id.string, -> model.get(property)

    bound_input: (model, property, options={}) ->
      id = AS.CK.Helpers.autoId()
      model.bind "change:#{property}", -> id.query().val model.get(property)
      id.query().live 'change', ->
        data = {}
        data[property] = id.query().val()
        model.set data
      id.query().live 'keyup', -> 
        data = {}
        data[property] = id.query().val()
        model.set data
      input _.extend(options, id: id.string, value: model.get property)
    
    bind_collection: (container_tag, collection, templateName) ->
      # DONT FORGET TO COMBINE LOCALS AS NEEDED
      
      id = AS.CK.Helpers.autoId()
      
      # Unbind before you rebind, or you'll be very :(
      # As you will have a lot of templates being added EVERYWHERE
      
      collection.unbind "add.#{templateName}-bind_collection"
      collection.bind "add.#{templateName}-bind_collection", (item) =>
        not_wanted = id.query().find("[data-cid=#{item.cid}]")
        if not_wanted[0]
          debugger
          console.error "Why u add", item, "to", collection, "again?"
          return
        if _.isFunction(templateName)
          console.error "ADDING w/o named template unimplemented sucka"
        else
          content = @context.render(templateName, _.extend(data.locals, item:item))
          index = collection.indexOf(item)
          container = id.query()
          siblings = container.children()
          if siblings.get(0) is undefined or siblings.get(index) is undefined
            container.append(content)
          else
            $(siblings.get(index)).before(content)

      collection.unbind "remove.#{templateName}-bind_collection"  
      collection.bind "remove.#{templateName}-bind_collection", (item) ->
        console.log "remove", item, "from", collection
        not_wanted = id.query().find("[data-cid=#{item.cid}]")
        if not_wanted[0] is undefined
          console.error "Could not find element to remove."
        not_wanted.remove()
      
      if container_tag.constructor is String
        container_tag = [container_tag, id:id.string]
      else
        container_tag[1] ?= {}
        container_tag[1].id = id.string
      
      if _.isFunction(templateName)
        container_tag.push -> 
          for item in collection.models
            templateName(item)
      else      
        container_tag.push ->
          for item in collection.models
            # Combine locals
            text @context.render(templateName, _.extend(data.locals, item:item))
      
      tag.apply this, container_tag
    
    bound_select: (model, property, options, option_value_key, config={}) ->
      id = AS.CK.Helpers.autoId()
      model.bind "change:#{property}", ->
        id.query().val model.get(property).cid
        
      id.query().live "change", ->
        data = {}
        data[property] = options.getByCid(id.query().val())
        model.set data
      
      options.bind "change:#{option_value_key}", (_option) ->
        id.query().find("[value=#{_option.cid}]").text _option.get(option_value_key)
        
      options.bind "add", (_option) =>
        console.error "FIXME: add option at correct position"
        
        # THIS HERE IS A LITTLE :(
        template = ->
          bound_select_option(_option, option_value_key)
          
        compiled = CoffeeKup.compile template, locals: yes, hardcode: AS.TemplateHelpers
        @locals ?={}
        @locals.option_value_key = option_value_key
        @locals._option = _option
        # YES IT IS, BUT IT ALSO WORKS :)
        
        id.query().append compiled this
      
      options.bind "remove", (_option) ->
        id.query().find("[value=#{_option.cid}]").remove()
        id.query().change()
        
      selection = model.get(property)
      select id: id.string, ->
        (option -> config.blank) if config.blank
        bound_select_option(_option, option_value_key, _option == selection) for _option in options.models

    bound_select_option: (model, property, selected) ->
      id = AS.CK.Helpers.autoId()
      model.bind "change:#{property}", -> id.query().text model.get(property)
      option id: id.string, value: model.cid, selected: selected, -> model.get(property)
