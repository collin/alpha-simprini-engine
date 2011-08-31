@module "AS.Views", ->
  class @Stage extends @Panel
      
    constructor: ->
      super
      @canvas ?= new AS.Views.Canvas
      @el.append @canvas.el