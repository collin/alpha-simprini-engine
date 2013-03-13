class AlphaSimprini::Admin::Component
  include AlphaSimprini::Admin::ControllerModule

  def self.tab_text(text=nil)
    text and @_tab_text = text
    @_tab_text || name.demodulize.underscore.gsub(/Admin/, '').titlecase
  end

  def self.setup!(&config)
    _controller
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
    view.engine = engine
    view.component = self
    view.instance_eval(&config)
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

  def self.generate_controller
    controller = engine.generate_controller(base_controller(engine.base_controller)) do
      class_attribute :component
    end
    controller.component = self
    controller
  end

  def self._controller
    @controller ||= begin
      # Have to do this here so the constant will have a name.
      controller = engine.const_set(
        controller_name, 
        generate_controller
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
            chain = end_of_association_chain
            searched = apply_search(chain)
            paged = apply_pagination(searched)
            sorted = apply_sorting(paged)
            scoped = apply_scoping(sorted)
            set_collection_ivar(scoped.respond_to?(:scoped) ? scoped.scoped : scoped.all)
          end
        end

        def apply_search(query)
          if params[:search].present?
            self.class.component.apply_search(query, params[:search])
          else
            query
          end
        end

        def apply_pagination(query)
          query.page(params[:page])
        end

        def apply_scoping(query)
          if scope = get_scope(params[:scope])
            scope.apply_to(query)
          else
            query
          end
        end

        def apply_sorting(query)
          if sort = get_sorting(params[:sort])
            sort.apply_to(query, params[:direction] || "desc")
          else
            query
          end
        end

        def get_sorting(sorting_name=nil)
          self.class.get_sorting(sorting_name)
        end

        def self.get_sorting(sorting_name)
          self.component.get_sorting(sorting_name)
        end

        def get_scope(scope_name=nil)
          self.class.get_scope(scope_name)
        end
  
        def self.get_scope(scope_name)
          self.component.get_scope(scope_name)
        end
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
    _controller.class_eval(&config)
  end

  def self.view(&config)
    base_view_module.class_eval(&config)
  end

  def self.collection(&block)
    _controller.send :define_method, :collection, &block
  end
end
