module "AS", ->
  @error = (msg) -> 
    console.trace
    console.error msg