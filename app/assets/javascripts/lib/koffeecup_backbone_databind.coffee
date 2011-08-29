#   create_button: (klass, fn) ->
#     id = AS.CK.Helpers.autoId()
#     id.query().live "click", -> 
#       if klass instanceof Collection
#         klass.add({})
#       else
#         new klass()
#     button id: id.string, fn
#   
#   delete_button: (model, fn) ->
#     id = AS.CK.Helpers.autoId()
#     id.query().live "click", -> model.destroy()
#     button id: id.string, fn

# # THIS IS WHY I WANT TO PUT DOM RIGHT IN COFFEESCRIPT
# 
# CoffeeKup.templates = {}
# # CoffeeKup.templateCache = {}
# # CoffeeKup.getTemplate = (templateName) ->
# #   CoffeeKup.templateCache[templateName] ?= do ->
# #     CoffeeKup.compile CoffeeKup.templates[templateName], locals: yes, hardcode: CoffeeKup.helpers
#     
# CoffeeKup.renderTemplate = (templateName, data, options = {}) ->
#   console.info "renderTemplate", arguments
#   CoffeeKup.render CoffeeKup.templates[templateName], data, locals: options, hardcode: CoffeeKup.helpers
