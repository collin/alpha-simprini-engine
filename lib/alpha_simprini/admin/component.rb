class AlphaSimprini::Admin::Component
  def self.setup!(&config)
    controller
    const_set :Views, view_module
    instance_eval(&config)  
    model_name = model.name.underscore.gsub('/', '_').downcase.pluralize
    engine.append_routes do
      resources model_name
    end
  end

  def self.generate_view(superclass, &config)
    view = engine.generate_view(superclass)
    view.send :include, base_view_module
    view.instance_eval(&config)
    view.admin = engine
    view
  end

  def self._view(name, superclass, &config)
    view_module.const_set name, generate_view(superclass, &config)
  end

  def self.view_module
    @view_module ||= Module.new
  end

  def self.controller_name
    @controller_name ||= "#{namespace.pluralize}Controller"
  end

  def self.controller
    @controller ||= begin
      controller = engine.const_set(
        controller_name, 
        Class.new(ApplicationController)
      ) 

      controller.class_eval do
        append_view_path AlphaSimprini::AdminViewResolver.new
        inherit_resources

        def resource_name
          resource_class.name
        end
        helper_method :resource_name
      
        def collection
          get_collection_ivar || begin
            c = end_of_association_chain
            paged = apply_pagination(c)
            set_collection_ivar(paged.respond_to?(:scoped) ? paged.scoped : paged.all)
          end
        end

        def apply_pagination(query)
          query.page(params[:page])
        end
      end
    end
  end

  def self.base_view_module
    @base_view_module ||= begin
      Module.new do
        def action_items
          self.class.admin.action_items
        end
      end
    end
  end

  def self.view(&config)
    base_view_module.class_eval(&config)
  end
end
