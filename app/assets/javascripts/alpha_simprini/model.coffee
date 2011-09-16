module "AS", ->
  @All =
    byId: {}
    byCid: {}
  
  class @Model
    AS.Event.extends(this)
  
    @has_many: (name, config) ->
      @relation(name)
      (@has_manys ?= {})[name] = config
      @field(name)
    
    @has_one: (name, config) ->
      @relation(name)
      (@has_ones ?= {})[name] = config
      
      @::[name] = (value) ->
        if value is undefined
          AS.All.byCid[@get_attribute(name)]
        else
          if value.cid
            @set_attribute(name, value.cid)
          else if _.isString(value)
            @set_attribute(name, value)
          else
            if value._type
              model = module(value._type)
            else
              model = AS.Model
            @set_attribute name, (new model value).cid
  
    @belongs_to: (name, config) ->
      @relation(name)
      (@belongs_tos ?= {})[name] = config
    
      @::[name] = (value) ->
        if value is undefined
          AS.All.byCid[@get_attribute(name)]
        else
          if value.cid
            @set_attribute(name, value.cid)
          else if _.isString(value)
            @set_attribute(name, value)
          else
            throw new Error(["Cannot set #{name} to unexpected value. Try passing a cid, or an object with a cid. Value was: ", value])
  
    @relation: (name) ->
      (@relations ?= []).push name
  
    @field: (name, options={}) ->
      # Reflection
      @fields ?= {}
      @fields[name] = options
    
      # options.type ?= String
      # options.type = Model.FieldTypes[option.type.name]
      @::[name] = (value) ->
        if value is undefined
          @get_attribute(name)
        else
          @set_attribute(name, value)
    
    @initialize_relations: (model)  ->
  
    constructor: (@attributes = {}) ->
      @initialize()
  
    initialize: () ->
      @previous_attributes = @attributes
      @id = @attributes.id
      @cid = @id or _.uniqueId("c")
    
      AS.All.byCid[@cid] = AS.All.byId[@id] = this
    
      @initialize_has_many(name, config) for name, config of @constructor.has_manys
      @initialize_has_one(name, config) for name, config of @constructor.has_ones
      @initialize_belongs_to(name, config) for name, config of @constructor.belongs_tos
    
    last: (attr) -> 
      [@attributes, @previous_attributes] = [@previous_attributes, @attributes]
      last = @[attr]()
      [@attributes, @previous_attributes] = [@previous_attributes, @attributes]
      last
      
    
    initialize_has_many: (name, config) ->
      data = {}
      class this["#{name}_collection_klass"] extends AS.Collection
      this["#{name}_collection_klass"].model = -> config.model() if config.model
      data[name] = new this["#{name}_collection_klass"](@[name]?())
      @set data
    
    initialize_has_one: (name, config) ->
      @[name](@attributes[name])
    
    initialize_belongs_to: (name, config) ->
      # pass; not sure you have to do anything, this should be properly set already.
  
    save: () ->
      return false unless @changed()
      @persist()
      true

    # Persisted is a callback here.
    # Actual persistance will be handled by an observer. DEAL WITH IT IF YOU WANT IT.
    persisted: ->
      @previous_attributes = @attributes
  
    changes: () ->
      changed = {}
      for key, value of @attributes
        changed[key] = value unless @previous_attributes[value] is value
      changed
  
    # Blessed be backbone
    changed: () -> _(@changes).chain().keys().any().value()
  
    get: (attr) -> @[attr]()
  
    set: (attrs) ->
      @[key](value) for key, value of attrs
      @trigger("change")
    
    set_attribute: (name, value) ->
      @attributes[name] = value
      @trigger("change:#{name}")
      value
    
    get_attribute: (name) ->
      @attributes?[name]
  
    destroy: () ->
      @trigger("destroy")
  
    trigger: () ->
      AS.Event.instance_methods.trigger.apply this, _(arguments).splice(1, 0, this)