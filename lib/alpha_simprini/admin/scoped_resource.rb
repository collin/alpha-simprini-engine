class AlphaSimprini::Admin::ScopedResource < AlphaSimprini::Admin::Resource
  def self.setup!(&config)
    _model = model
    relation { _model }
    controller do
      define_method(:resource_class) { _model.klass }
    end
    super
  end

  def self.route_name
    model.scope_name.to_s.pluralize
  end

  def self.model_name
    model.klass.to_s.underscore.gsub('/', '_').downcase
  end

  def self.namespace
    model.scope_name.to_s.demodulize.classify
  end
end