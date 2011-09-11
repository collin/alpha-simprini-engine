class module("AS").HTML
  @elements: _('a abbr address article aside audio b bdi bdo blockquote body button
    canvas caption cite code colgroup datalist dd del details dfn div dl dt em
    fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup
    html i iframe ins kbd label legend li map mark menu meter nav noscript object
    ol optgroup option output p pre progress q rp rt ruby s samp script section
    select small span strong style sub summary sup table tbody td textarea tfoot
    th thead time title tr u ul video area base br col command embed hr img input keygen link meta param
    source track wbr'.split(" ")).chain().compact()
  
  constructor: (args) ->
    # body...

  text: (text_content) ->
    @span text_content

  tag: (name, attrs, content) ->
    @current_node ?= document.createDocumentFragment()

    if _.isFunction(attrs)
      content = attrs
      attrs = undefined
    if _.isString(attrs)
      text_content = attrs
      attrs = undefined
    
    # TODO: use jQuery for better compatibility / less performance
    node = document.createElement(name)
    node.setAttribute(key, value) for key, value of attrs unless attrs is undefined
    @current_node.appendChild node
    
    
    if text_content
      $(node).text text_content
    else if content
      @within_node node, ->
        last = content.call(this)
        if _.isString(last)
          @text(last)

    node
  
  within_node: (node, fn) ->
    prior_node = @current_node
    @current_node = node
    content = fn.call(this)
    @current_node = prior_node
    content
  
  dangling_content: (fn) -> @within_node(null, fn)
  
AS.HTML.elements.each (element) ->
  AS.HTML::[element] = -> @tag.apply this, _(arguments).unshift(element)
