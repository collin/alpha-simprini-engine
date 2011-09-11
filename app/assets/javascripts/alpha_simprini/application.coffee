module "AS", ->
  class @Application

    constructor: (args) ->
      @template_source = @template_source()
      for name, template of @template_source
        @template_source[name] = CoffeeKup.compile(template, locals:yes, hardcode:AS.TemplateHelpers)
    
    render: (template_name, locals={}) ->
      console.log "Render #{template_name}", locals
      data = {context: this, locals:locals}
      @template_source[template_name](data)
    