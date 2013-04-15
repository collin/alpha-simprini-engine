class Stacker.StackView extends Stacker.View
  className: "stack-item-container container"
  events:
    "click .stack-item-top .stack-item-title": "popStack"
    "click .stack-item-under": "jumpStack"

  distance: 30

  constructor: (options) ->
    super

    @listenTo @model, 'add', => @render()
    @listenTo @model, 'remove', => @render()
    @listenTo @model, 'change', => @render()

  replaceHeader: (replacement) ->
    return false unless replacement?
    return false if replacement[0] is @options.header[0]
    @options.header.replaceWith replacement
    @options.header = replacement

  popStack: ->
    @model.pop()

  jumpStack: (event) ->
    top = @model.last()
    cid = $(event.target).closest('.stack-item-under').data('stack-item-cid')
    item = @model.get(cid)
    count = 0
    for _item in @model.slice(@model.indexOf(item) + 1).reverse()
      # @model.remove(_item, silent:true)
      count -= 1
    @model.trigger('jump', count)
    @render()

  render: =>
    stack = if last = @model.last()
      last.get('stack')

    stack ||= Stacker.alloc(Stacker.Cards)

    lastIndex = stack.indexOf( last )

    @$el.empty()
    @tag 'ol', class:'stack-item-container', ->
      for card, index in stack.slice(0, lastIndex)
        item = @tag 'li', class:'stack-item stack-item-under', 'data-stack-item-cid':card.cid, ->
          @tag 'label', class:'stack-item-title', ->
            @text card.get('title')

        $(item).css
          top: index*@distance
          left: (index*@distance)/2

      title = null
      if last
        item = $ @tag 'li', class:'stack-item stack-item-top', 'data-stack-item-cid':last.cid, ->
          title = $ @tag 'label', class:'stack-item-title', ->
            @text last.get('link')

        @replaceHeader last.get('header')

        item.css
          top: lastIndex  * @distance
          left: (lastIndex * @distance)/2

        item.append content if content = last.get('content')
        title.text titleText if titleText = last.get('title')
        $('html').attr(htmlAttrs) if htmlAttrs = last.get('htmlAttrs')


        @find(".stack-item-under").css height: item.height()
        console.log @el
        @find(".stack-item").css width: @$el.width()

    this