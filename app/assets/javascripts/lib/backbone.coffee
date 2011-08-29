extentions = 
  delegate: () ->
    options = Array::pop.apply(arguments)
    for method in arguments
      @::[method] = ->
        delegatee = @[options.to]
        delegatee[method].apply delegatee, arguments

_.extend Backbone.Model, extentions
_.extend Backbone.View, extentions
_.extend Backbone.Collection, extentions
