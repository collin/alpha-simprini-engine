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
      @initialize_belongs_to(name, config) for name, config of @constructor.belongs_tos
        
    initialize_has_many: (name, config) ->
      data = {}
      data[name] = new AS.Collection(@[name]?())
      @set data
    
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
      @attributes[name]
  
    destroy: () ->
      @trigger("destroy")
  
    trigger: () ->
      AS.Event.instance_methods.trigger.apply this, _(arguments).splice(1, 0, this)