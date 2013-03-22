class AlphaSimprini::Admin::Resource < AlphaSimprini::Admin::Component
  # def self.inherited(subclass); end

  def self.route_component(&block)
    _route_name = route_name
    engine.append_routes do
      resources _route_name
    end
  end

  def self.member_action(name, options={}, &block)
    controller.send :custom_actions, resource: name
    controller.send :define_method, name, &block
    _route_name = "/#{route_name}/:id/#{name}"
    _handler = "#{namespace.underscore.pluralize}##{name}"
    _helper = "#{name}_#{route_name.singularize}"
    engine.append_routes do
      put _route_name => _handler, as: _helper
    end
  end

  def self._controller
    @controller ||= begin

      # Have to do this here so the constant will have a name.
      controller = engine.const_set(
        controller_name, 
        generate_controller
      ) 

      controller.class_eval do
        inherit_resources
        include AlphaSimprini::Admin::PathHelpers

        def resource_path(_resource=resource, options={})
          polymorphic_path _resource, options
        end

        def new_resource_path(options={})
          polymorphic_path resource_class, {action:'new'}.reverse_merge(options)
        end

        def edit_resource_path(_resource=resource, options={})
          polymorphic_path _resource, {action:'edit'}.reverse_merge(options)
        end

        def collection_path(options={})
          if _uncountable_name
            send :"#{resource_class.name.demodulize.underscore}_index_path", options
          else
            polymorphic_path resource_class, options
          end
        end
        helper_method :resource_path, :new_resource_path, :edit_resource_path, :collection_path

        def create
          create! { collection_path }
        end

        def update
          update! { collection_path }
        end

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
            filtered = apply_filters(sorted)
            scoped = apply_scoping(filtered)
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

        def apply_filters(query)
          filters = self.class.component.get_filters params.keys.grep(/^filter_/)
          return query if filters.none?
          filters.each do |filter|
            query = filter.apply_to(query, params[filter.param_name])
          end
          query
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

  def self.search(*fields)
    self.search_fields += fields
  end

  def self.apply_search(query, search_string)
    clause = model.arel_table[search_fields.first].matches("%#{search_string}%")
    search_fields.each_with_index do |field, index|
      next if index.zero?
      clause = clause.or(model.arel_table[field].matches("%#{search_string}%"))
    end
    query.where(clause)
  end

  def self.filter(filter_name, display_name=nil, options)
    display_name ||= filter_name.to_s.titlecase
    self.filters << AlphaSimprini::Admin::Filter.new(self, filter_name, display_name, options)
  end

  def self.sort(sort_name, display_name=nil, options={})
    display_name ||= sort_name.to_s.titlecase
    self.sortings << AlphaSimprini::Admin::Sorting.new(self, sort_name, display_name, options)
  end

  def self.scope(scope_name, display_name=nil, options={})
    display_name ||= scope_name.to_s.titlecase
    self.scopes << AlphaSimprini::Admin::Scope.new(self, scope_name, display_name, options)
  end

  def self.get_scope(scope_name)
    scopes.detect{|scope| scope.matches scope_name }
  end

  def self.get_filters(filter_keys)
    filters.find_all{|filter| filter_keys.include? filter.param_name.to_s }
  end

  def self.get_sorting(sorting_name)
    if sorting = sortings.detect{|sorting| sorting.sorting_name.to_s == sorting_name }
      sorting
    else
      sortings.detect{|sorting| sorting.default? }
    end
  end
end