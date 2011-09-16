class module("AS").Collection
  AS.Delegate.extends(this)
  AS.Event.extends(this)
  
  @delegate "first", "rest", "last", "compact", "flatten", "without", "union", 
            "intersection", "difference", "uniq", "zip", "indexOf", "find", "detect", "at",
            "lastIndexOf", "range", "include",  "each", "map", "reject","all", "toArray", to: "models"
  
  @model: -> AS.Model

  constructor: (@models=[]) ->
    @initialize()

  initialize: () ->
    given_models = @models
    @length = 0
    @byId = {}
    @byCid = {}
    @models = _([]).chain()
    @add(model) for model in given_models
  
  add: (model, options={}) ->
    throw new Error("Cannot add model to collection twice.") if @models.include(model).value()
    
    unless model instanceof AS.Model
      model = @build(model)
    
    @_add(model, options)
    
    model
  
  _add: (model, options={}) ->
    options.at ?= this.length
    index = options.at
    @byCid[model.cid] = @byId[model.id] = model
    @models.splice index, 0, model
    @length++
    model.bind("all", @_on_model_event, this)
    model.trigger "add", this, options
  
  remove: (model, options) -> @_remove(model, options)
    
  _remove: (model, options) ->
    @length--
    delete @byId[model.id]
    delete @byCid[model.cid]
    @models = @models.chain().without(model)
    model.trigger("remove", this, options)
    model.unbind("all", @_on_model_event)
  
  build: (model) ->
    if model._type
      ctor = module(model._type)
    else
      ctor = @constructor.model()
    new ctor(model)
  
  # When an event is triggered from a model, it is bubbled up through the collection.
  _on_model_event: (event, model, collection, options) ->
    return if (event is "add" or event is "remove") and (this isnt collection)
    @_remove(model, options) if event is "destroy"
    @trigger.apply(this, arguments)
