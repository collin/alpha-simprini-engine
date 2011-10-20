module "AS", ->
  class @Application
    AS.Event.extends(this)

    constructor: (args) ->
      @template_source = @template_source()
      for name, template of @template_source
        @template_source[name] = CoffeeKup.compile(template, locals:yes, hardcode:AS.TemplateHelpers)
      
      $ => @initialize?()

    template_source: -> @Templates

    view: (constructor, options={}) ->
      options.application = this
      new constructor options

    render: (template_name, locals={}) ->
      data = {context: this, locals:locals}
      @template_source[template_name](data)
    
    