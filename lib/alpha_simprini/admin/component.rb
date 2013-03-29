class AlphaSimprini::Admin::Component
  include AlphaSimprini::Admin::ControllerModule

  class_attribute :engine
  class_attribute :model

  def self.inherited(subclass)
    super
    
    subclass.class_attribute :scopes
    subclass.scopes = []

    subclass.class_attribute :sortings
    subclass.sortings = []

    subclass.class_attribute :search_fields
    subclass.search_fields = []

    subclass.class_attribute :filters
    subclass.filters = []

    subclass.class_attribute :date_filters
    subclass.date_filters = []    
  end

  class << self
    delegate :append_routes, to: 'engine'
  end

  def self.tab_text(text=nil)
    text and @_tab_text = text
    @_tab_text || name.demodulize.underscore.gsub(/Admin/, '').titlecase
  end

  def self.setup!(&config)
    _controller
    const_set :Views, view_module
    instance_eval(&config)  
    route_component
  end

  def self.route_component
    _route_name = route_name
    _target = "#{_route_name}#index"
    engine.append_routes do
      get _route_name => _target
    end
  end

  def self.namespace
    model.to_s.demodulize
  end

  def self.singular_model_name
    model.to_s.underscore.gsub('/', '_').downcase
  end

  def self.model_name
    singular_model_name.pluralize
  end

  def self.route_name
    model_name.gsub(/[^a-zA-Z]/, ' ').squeeze(' ').gsub(/ /, "_")
  end

  def self.has_many(relation_name, &config)
    _route_name = route_name
    _relation_name = relation_name

    klass = model.reflect_on_association(relation_name).klass
    child_resource = const_set(
      klass.name.demodulize.pluralize,
      AlphaSimprini::Admin::Resource.generate(engine, klass)
    )
    child_resource.setup!(&config) if block_given?

    _singular_model_name = singular_model_name
    child_resource.controller do
      optional_belongs_to _singular_model_name
    end

    engine.append_routes do
      resources _route_name do
        resources _relation_name
      end
    end
  end

  def self.generate_view(superclass=AlphaSimprini::Page, &config)
    view = engine.generate_view(superclass)
    view.send :include, base_view_module
    view.engine = engine
    view.component = self
    view.class_eval(&config)
    view
  end

  def self._view(name, superclass=AlphaSimprini::Page, &config)
    view_module.const_set name, generate_view(superclass, &config)
  end

  def self.view_module
    @view_module ||= Module.new
  end

  def self.controller_name
    @controller_name ||= "#{namespace.pluralize.gsub(/[^a-zA-Z]/, '')}Controller"
  end

  def self.generate(engine, model)
    subclass = Class.new(self)
    subclass.engine = engine
    subclass.model = model
    subclass
  end

  def self.generate_controller
    controller = engine.generate_controller(base_controller(engine.base_controller)) do
      class_attribute :component
    end
    controller.component = self
    controller
  end

  def self.index(&config)
    _view :Index, Views::Resources::Index, &config
  end

  def self.show(&config)
    _view :Show, Views::Resources::Show, &config
  end

  def self.new_form(&config)
    _view :New, Views::Resources::New do
      @form_block = config
    end
  end

  def self.edit_form(&config)
    _view :Edit, Class.new(Views::Resources::Edit) do
      @form_block = config
    end
  end

  def self.forms(&config)
    new_form(&config)
    edit_form(&config)
  end

  def self._controller
    @controller ||= begin
      # Have to do this here so the constant will have a name.
      controller = engine.const_set(
        controller_name, 
        generate_controller
      ) 
      controller.class_eval do
        include AlphaSimprini::Admin::PathHelpers
      end
      controller
    end
  end

  def self.base_view_module
    @base_view_module ||= begin
      Module.new do
        def action_items
          self.class.engine.action_items
        end
      end
    end
  end

  def self.controller(&config)
    if block_given?
      _controller.class_eval(&config)
    else
      _controller
    end
  end


  def self.view(&config)
    if block_given?
      base_view_module.class_eval(&config)
    else
      base_view_module
    end
  end

  def self.collection(&block)
    _controller.send :define_method, :collection, &block
  end

  def self.relation(&block)
    _controller.send :define_method, :end_of_association_chain, &block    
  end
end
