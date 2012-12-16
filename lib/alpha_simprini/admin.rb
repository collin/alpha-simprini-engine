module Views
  module Admin
  end
end

module AlphaSimprini
  class Admin
    module Page
      extend ActiveSupport::Concern
      included do
        script 'alpha_simprini/admin'        
      end

      def header_content
        label :application_title
        nav do
          names = ApplicationAdmin.sections.map do |subclass|
            next unless subclass.name
            subclass.name.gsub /Admin/, ''
          end
          names.uniq!
          names.compact!
          names.each do |name|
            url = send(:"admin_#{name}_path".downcase)
            attrs = {}
            attrs[:class] = 'current' if current_page?(url)
            link_to name, url, attrs
          end        
        end
      end
    end

    class_attribute :sections
    self.sections = []

    def self.register_resource(model, &block)
      Rails.logger.info "AlphaSimprini::Admin.inherited #{model}"
      name = model.name.pluralize
      subclass = Class.new AdminResource
      Object.const_set "#{name.pluralize}Admin", subclass
      subclass.instance_eval do
        @view_module = Views::Admin.const_set(name, Module.new)
        @base_view_module = Module.new do
          extend ActiveSupport::Concern
          include ::AlphaSimprini::Admin::Page

          def action_items
            self.class.admin.action_items
          end
        end

        @view_module.const_set "Base", @base_view_module

        @controller = ::Admin.const_set(
          "#{name}Controller", 
          Class.new(ApplicationController)
        ) 

        @controller.class_eval do
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

      def subclass.action_items
        @action_items ||= []
      end
      subclass.instance_eval(&block)

      append_routes do
        resources name.downcase.pluralize
      end

      subclass
    end

    def self.register_string(name, &block)
      name = name.pluralize
      subclass = Class.new AdminSection
      Object.const_set "#{name.camelcase}Admin", subclass

      subclass.instance_eval do
        @view_module = Views::Admin.const_set(name, Module.new)
        @base_view_module = Module.new do
          extend ActiveSupport::Concern
        end

        @view_module.const_set "Base", @base_view_module

        @controller = ::Admin.const_set(
          "#{name}Controller", 
          Class.new(ApplicationController)
        ) 

        @controller.class_eval do
          append_view_path AlphaSimprini::AdminViewResolver.new

          def index
            render
          end
        end
      end

      subclass.instance_eval(&block)

      append_routes do
        get name.underscore => "#{name.underscore}#index"
      end

      subclass
    end

    def self.register model, &block
      if model.is_a?(Class) && model < ActiveRecord::Base
        name = "resource"
      else
        name = model.class.name.underscore.gsub('/', '_')
      end
      sections.push send "register_#{name}", model, &block
    end

    def self.append_routes(&block)
      Rails.application.routes.append do
        namespace(:admin) do
          instance_exec(&block)
        end
      end
    end

    def self.base_view
      @base_view_module
    end

    def self.view_module    
      @view_module
    end

    def self.controller
      @controller
    end

    def self.view(&config)
      base_view.class_eval(&config)
    end
  end

  class AdminSection < Admin
    def self.index(&config)
      index = Class.new(AlphaSimprini::Admin::Page)
      index.send :include, base_view
      view_module.const_set :Index, index
    end
  end

  class AdminResource < Admin 
    def self.action_item(name, action, &block)
      action_items << [name, action, block]
      if block_given?
        controller.send :custom_actions, resource: action
        controller.send :define_method, action, &block
      end
      the_action = controller.action(action)
      the_resources = self.name.underscore.gsub(/_admin/, '')
      Rails.application.routes.append do
        namespace :admin do
          resources the_resources, only: [] do
            member do
              post action
            end
          end
        end
      end
    end

    def self.index(&config)
      index = Class.new(Views::Resources::Index, &config)
      index.send :include, base_view
      index.admin = self
      view_module.const_set :Index, index
    end

    def self.show(&config)
      show = Class.new(Views::Resources::Show, &config)
      show.send :include, base_view
      view_module.const_set :Show, show
    end

    def self.new_form(&config)
      new_form = Class.new(Views::Resources::New) do
        @form_block = config
      end
      new_form.send :include, base_view
      view_module.const_set :New, new_form
    end

    def self.edit_form(&config)
      edit_form = Class.new(Views::Resources::Edit) do
        @form_block = config
      end
      edit_form.send :include, base_view
      view_module.const_set :Edit, edit_form
    end
  end
end