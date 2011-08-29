module "AS.CK", ->
  @Binding =
    bind: (model, property, getter) ->
      id = AS.CK.Helpers.autoId()
      model.bind "destroy", -> id.query().remove()
      if getter
        model.bind "change:#{property}", -> id.query().text getter.call(model.get(property)) || ""
        span id: id.string, -> getter.call(model.get(property))      
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
    
    bind_collection: (container_tagname, collection, templateName) ->
      id = AS.CK.Helpers.autoId()
      
      collection.bind "add", (item) =>
        console.error "FIXME: add item at correct position"
        id.query().append CoffeeKup.renderTemplate(templateName, this, item: item)
  
      collection.bind "remove", (item) ->
        id.query().find("[id=#{item.cid}]").remove()
      
      tag container_tagname, id: id.string, ->
        for item in collection.models
          text CoffeeKup.renderTemplate(templateName, this, item: item)
    
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
