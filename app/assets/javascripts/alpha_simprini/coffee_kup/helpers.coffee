module "AS.CK", ->
  @Helpers =
    shy: (string="") ->
      string.replace(/([a-z])([A-Z])/g, (a, b, c) -> b + "&shy;" + c)
    
    incr: 0
    
    autoId: ->
      id = "CoffeeKup-#{@incr++}"
      query_function = -> @node = jQuery "##{id}"
      return string: id, query: _.bind(query_function, {})
    
    _cycles: {}
    
    reset_cycle: (args...) ->
      delete AS.CK.Helpers._cycles[args.join()]
    
    cycle: (args...) ->
      AS.CK.Helpers._cycles[args.join()] ?= 0
      count = AS.CK.Helpers._cycles[args.join()] += 1
      args[count % args.length]

    toggle: ->
      button class:"toggle expand"
      button class:"toggle collapse"
    field: (_label, fn) ->
      div ->
        label _label
        input()
        fn?.call(this)
    dimension: (_label) ->
      field _label, -> select -> option "px"
      
    choice: (_label) ->
      div ->
        label _label
        input type:"checkbox"
        
    linked: (fn) ->
      div class:'linked', ->
        fn?.call(this)
        label ->
          input type:"checkbox"

    
      