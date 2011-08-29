module "AS.CK", ->
  @Tags =
    model_tag: (model, options={}, fn) ->
      [options, fn] = [{}, options] if options.constructor is Function
      tagname = options.tagname or "div"
      delete options.tagname
      tag tagname, _.extend(options, id: model.cid), fn
