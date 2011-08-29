#= require_tree ./coffee_kup
module "AS", ->
  @TemplateHelpers = {}
  
  _.extend @TemplateHelpers, @CK.Helpers
  _.extend @TemplateHelpers, @CK.Tags
  _.extend @TemplateHelpers, @CK.Binding
  