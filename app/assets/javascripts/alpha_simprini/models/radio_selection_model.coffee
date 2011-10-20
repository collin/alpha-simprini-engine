class @module("AS.Models").RadioSelectionModel extends AS.Model
  @belongs_to 'selected'
  
  initialize: ->
    super
    @select undefined
  
  select: (item) ->
    @selected(item)
