# BITCHIN SWEET CoffeeScript/_ Mixin capability
module "AS", ->
  class @Mixin
    extends: (klass) ->
      _.extend klass, @class_methods if @class_methods
      _.extend klass::, @instance_methods if @instance_methods
      @mixed_in.call(klass) if @mixed_in

    constructor: (methods) ->
      _.extend this, methods
