AS.Delegate = new AS.Mixin
  class_methods:
    delegate: () ->
      options = Array::pop.apply(arguments)
      for method in arguments
        @::[method] = ->
          delegatee = @[options.to]
          delegatee[method].apply delegatee, arguments
