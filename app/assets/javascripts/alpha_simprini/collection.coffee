module "AS", ->
  class @Collection extends Backbone.Collection
    AS.Event.extends(this)
    
    _add: ->
      model = super
      # This little feature used by RelationalModel to do two-way inference on associations
      if @inverse and @source
        inverse = {}
        inverse[@inverse] = @source
        model.set(inverse)
      model
    
