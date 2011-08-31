class Backbone::Model
  def initialize(namespace, model, parent="AS.Model")
    @model = model
    @namespace = namespace
    @parent = parent
  end
  
  def boilerplate
    bp = []
    bp << %|module "#{@namespace}", ->|
    bp << %|class #{@namespace}.#{@model.name} extends #{@parent}|
    @model.relations.each do |name, config|
      case config.macro
         when :embeds_many, :references_many
        bp << %|  @has_many "#{name}"|
        bp << %|     model_name: "#{@namespace}.#{config.class_name}"|
      when :embedded_in, :referenced_in
        bp << %|  @belongs_to "#{name}"|
      end
    end
    bp << ""
    bp.join("\n")
  end
end