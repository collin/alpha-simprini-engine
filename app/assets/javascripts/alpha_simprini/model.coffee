module "AS", ->
  @All = new AS.Collection
  @HasManyCollection = AS.Collection.extend()
  
  class @Model extends Backbone.Model
    AS.Event.extends(this)
    
    @associated: (name) ->
      @associations ?= []
      @associations.push name
  
    console.error "FIXME: eval? really???"
    @has_many: (name, options) ->
      @associated name
      @has_manys ?= {}
      options.collection_factory = ->
        options.model = eval(options.model_name)
        new (AS.HasManyCollection.extend options)
      @has_manys[name] = options
      # This is code for some sort of nested event triggering. which is useful
      # @::["write_#{name}"] = (now, object) ->
      #   change_listener = @["#{name}_change_listener"] ?= => @trigger("change:#{name}", @[name])
      #   @[name]?.unbind("change", change_listener)
      #   object.bind("change", change_listener)
      #   @attributes[name] = object

    @belongs_to: (name) ->
      @associated name
      @belongs_to ?= {}
      @belongs_to[name] = {}
      @::["write_#{name}"] = (now, object) ->
        object = AS.All.get(object) if object.constructor is String
        change_listener = @["#{name}_change_listener"] ?= => @trigger("change:#{name}", @[name])
        @[name]?.unbind("change", change_listener)
        object.bind("change", change_listener)
        @attributes[name] = object

    set: (attrs) ->
      for key, value of attrs
        if writer = @["write_#{key}"]
          writer.call(this, attrs, value)
          delete attrs[key]

      super

    initialize: () ->
      AS.All.add(this)
      super
      for association, config of @constructor.has_manys
        attrs = {}
        do (association, config, attrs) =>
          raw_data = @attributes[association] if @attributes[association]
          collection = attrs[association] = config.collection_factory()
          collection.source = this
          collection.add raw_data if raw_data
          @set attrs

