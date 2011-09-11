class @module("AS.Models").RadioSelectionModel extends AS.Model
  @belongs_to 'selected'
  
  initialize: ->
    @select undefined
  
  select: (item) ->
    @selected(item)
