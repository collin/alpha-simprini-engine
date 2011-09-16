class Backbone::Model
  def initialize(namespace, model, parent=nil)
    @model = model
    @namespace = namespace
    if parent
      @parent = [namespace, parent].join(".").gsub(/\.$/, '')
    else
      @parent = "AS.Model"
    end
  end
  
  def coffee_path
    "#{@namespace}.#{@model.name.demodulize}"
  end
  
  def content_fields
    @model.fields.reject do |name, config|
      config.options[:identity] || name.ends_with?("_ids")
    end
  end
  
  def spool_boilerplate
    bp = []
    bp << %|module "#{@namespace}", ->|
    bp << %|class #{coffee_path} extends #{@parent}|
    # bp << %|  AS.Heap.Classes["Packed#{@model.name}"] = this|
    content_fields.each do |name, config|
      bp << %|  @field "#{name}"|
    end
    @model.relations.each do |name, config|
      case config.macro
         when :embeds_many, :references_many
        bp << %|  @has_many "#{name}"|
        bp << %|     model: -> #{@namespace}.#{config.class_name}|
      when :embedded_in, :referenced_in
        bp << %|  @belongs_to "#{name}"|
      end
    end
    bp
  end
  
  
  def boilerplate
    bp = spool_boilerplate
    bp << %||
    bp << %||
    bp.join("\n")
  end
end