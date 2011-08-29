@module "AS.Views", ->
  class @Stage extends Backbone.View
    canvas_class: AS.Views.Canvas
      
    constructor: ->
      @canvas = @canvas_class