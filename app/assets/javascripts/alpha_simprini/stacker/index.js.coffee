#= require underscore
#= require backbone

#= require_self

#= require alpha_simprini/stacker/card
#= require alpha_simprini/stacker/cards
#= require alpha_simprini/stacker/view
#= require alpha_simprini/stacker/stack_view
#= require alpha_simprini/stacker/history_controller
#= require alpha_simprini/stacker/network_controller
#= require alpha_simprini/stacker/navigation_controller
#= require alpha_simprini/stacker/app

window.Stacker = {}

Stacker.Repo = new Backbone.Collection
# Hack to let us stick collections into this collection
Stacker.Repo._prepareModel = (model) -> model
Stacker.alloc = (klass, args...) -> @Repo.add item = new klass(args...); item
Stacker.get = (id) -> @Repo.get(id)
Stacker.flush = -> @Repo.set [], silent:true

Stacker.fromJSON = (klass, json) ->
  klass.fromJSON(json, Stacker.Repo)
