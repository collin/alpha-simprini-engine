module "AS.CK", ->
  @Helpers =
    shy: (string="") ->
      string.replace(/([a-z])([A-Z])/g, (a, b, c) -> b + "&shy;" + c)
    
    incr: 0
    
    autoId: ->
      id = "CoffeeKup-#{@incr++}"
      query_function = -> @node = jQuery "##{id}"
      return string: id, query: _.bind(query_function, {})
    