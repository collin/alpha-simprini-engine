module "AS", ->
  @error = () -> 
    console.trace()
    console.error.apply(console, arguments)