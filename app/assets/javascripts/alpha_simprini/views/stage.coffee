@module "AS.Views", ->
  class @Stage extends @Panel
    canvas_class: AS.Views.Canvas
    initialize: (config) ->
      super
      @canvas ?= new @canvas_class
      @el.append @canvas.el