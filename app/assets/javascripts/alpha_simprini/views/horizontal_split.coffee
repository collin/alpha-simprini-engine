module "AS.Views", ->
  class @HorizontalSplit extends AS.View

    constructor: (args) ->
      super
      @left ?= new AS.Views.Panel
      @bar ?= new AS.Views.Splitter
      @right ?= new AS.Views.Panel
      @el.append @left.el, @bar.el, @right.el
      