#= require bundle
#= require ./lib/string
#= require ./lib/module
#= require ./alpha_simprini/mixin
#= require ./alpha_simprini/state_machine
#= require ./alpha_simprini/delegate
#= require ./alpha_simprini/instance_methods
#= require ./alpha_simprini/event
#= require ./alpha_simprini/dom
#= require ./alpha_simprini/view
#= require ./alpha_simprini/views/panel
#= require_tree ./alpha_simprini/views
#= require_tree ./alpha_simprini
#= require_tree ./lib/ot
#= require_tree ./lib/css

# ## Some little utility functions. 

module("AS").ConstructorIdentity = (constructor) -> (object) -> object.constructor is constructor
module("AS").Identity = (object) -> (other) -> object is other

module("AS").deep_clone = (it) ->
  if _.isArray(it)
    clone = _.clone(it)
  else if _.isObject(it)
    clone = {}
    for key, value of it
      if _.isArray(value) or _.isObject(value)
        clone[key] = AS.deep_clone(value)
      else
        clone[key] = value
  else
    clone = it
  
  clone
# `uniq` generates a probably unique identifier.
# large random numbers are base32 encoded and combined with the current time base32 encoded
module("AS").uniq = ->
  (Math.floor Math.random() * 100000000000000000).toString(32) + "-" + (Math.floor Math.random() * 100000000000000000).toString(32) + "-" + (new Date).getTime().toString(32)


module("AS").open_shared_object = (id, callback) ->
  console.log "opening shared object #{id}"
  sharejs.open id, "json", @sharejs_url, (error, handle) ->
    if error then console.error(error) else callback(handle)
