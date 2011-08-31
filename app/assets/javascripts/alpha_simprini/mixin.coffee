# BITCHIN SWEET CoffeeScript/_ Mixin capability
module "AS", ->
  class @Mixin
    extends: (klass) ->
      _.extend klass, @class_methods if @class_methods
      _.extend klass::, @instance_methods if @instance_methods
      @mixed_in.call(klass) if @mixed_in

    constructor: (methods) ->
      _.extend this, methods

# ROUGHLY LIKE SO (Delegate implementation broken and not planned well, but its this sort of shit for Mixin)
# Delegate = new AS.Mixin
#   class_methods:
#     delegate: (delegated_methods..., delegatee) ->
#       callOrReturn = (object, rest...) ->
#         if object.constructor is Function
#           object.apply(this, rest)
#         else
#           object
#           
#       for method in delegated_methods
#         if delegatee.constructor is String
#           @::[method] = -> callOrReturn @[delegatee][method], arguments
#         else if delegatee.constructor is Function
#           @::[method] = -> callOrReturn delegatee()[method], arguments
#         else if delegatee.constructor is Object
#           @::[method] = -> callOrReturn delegatee[method], arguments
# 
# class MyBitchinClass
#   Delegate.extends(this)
#   @delegate "toString", "THIS IS MY TO STRING OBJECT"
#   @delegate "toObject", toObject: {}
#   @delegate "toWhizBang", (theWhizBang) -> {toWhizBang: theWhizBang}
