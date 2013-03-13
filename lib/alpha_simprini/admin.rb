class AlphaSimprini::Admin < Rails::Engine
  require "alpha_simprini/admin/controller_module"
  include AlphaSimprini::Admin::ControllerModule

  # When the admin engine is inerited we isolate the namespace and
  # give ourselves reflection on the sections
  def self.inherited(subclass)
    subclass.instance_eval do
      self.called_from = Rails.root
      class_attribute :sections
      self.sections = []
      isolate_namespace self

      const_set(:IndexController, index_controller)
      const_set(:Index, Module.new)
      const_get(:Index).send(:const_set, :Views, views)
      views.send(:const_set, :Dashboard, dashboard)

      append_routes do
        root to: "index#dashboard"
      end
    end
  end

  def self.action_items
    []
  end

  def self.append_routes(&block)
    routes.eval_block(block)
  end

  def self.dashboard
    @dashboard ||= generate_view
  end

  def self.view_module
    @view_module ||= Module.new
  end

  def self.views
    @views ||= Module.new
  end

  def self.view(&block)
    view_module.class_eval(&block)
  end

  def self.generate_controller(superclass=base_controller, &config)
    controller = Class.new(superclass) do
      append_view_path AlphaSimprini::AdminViewResolver.new
      class_attribute :engine
      instance_eval(&config) if block_given?
    end
    controller.engine = self
    controller
  end

  def self.generate_view(superclass=AlphaSimprini::Page)
    _view_module = view_module
    _url_helpers = routes.url_helpers

    view = Class.new(superclass) do
      include AlphaSimprini::Admin::Page
      include _view_module
      include _url_helpers
    end

    view.engine = self
    view  
  end

  def self.index_controller
    @index_controller ||= generate_controller do
      define_method(:dashboard) { render }
    end
  end

  def self.register model, &config
    if model.is_a?(Class) && model < ActiveRecord::Base
      name = model.name.demodulize
      section = const_set(name.pluralize, Resource.generate(self, model))
      section.setup!(&config)
      self.sections << section
    end
  end

end

  # def self.register_resource(model, &block)
  #   Rails.logger.info "AlphaSimprini::Admin.inherited #{model}"
  #   name = model.name.pluralize
  #   subclass = Class.new AdminResource
  #   self.const_set "#{name.pluralize}Admin", subclass
  #   subclass.instance_eval do
  #     @view_module = Views::Admin.const_set(name, Module.new)
  #     @base_view_module = Module.new do
  #       extend ActiveSupport::Concern
  #       include ::AlphaSimprini::Admin::Page

  #       def action_items
  #         self.class.admin.action_items
  #       end
  #     end

  #     @view_module.const_set "Base", @base_view_module

  #   end

  #   def subclass.action_items
  #     @action_items ||= []
  #   end
  #   subclass.instance_eval(&block)

  #   append_routes do
  #     resources name.underscore.gsub('/', '_').downcase.pluralize
  #   end

  #   subclass
  # end

  # def self.register_string(name, &block)
  #   name = name.pluralize
  #   subclass = Class.new AdminSection
  #   self.const_set "#{name.camelcase}Admin", subclass

  #   subclass.instance_eval do
  #     @view_module = Views::Admin.const_set(name, Module.new)
  #     @base_view_module = Module.new do
  #       extend ActiveSupport::Concern
  #     end

  #     @view_module.const_set "Base", @base_view_module

  #     @controller = ::Admin.const_set(
  #       "#{name}Controller", 
  #       Class.new(ApplicationController)
  #     ) 

  #     @controller.class_eval do
  #       append_view_path AlphaSimprini::AdminViewResolver.new

  #       def index
  #         render
  #       end
  #     end
  #   end

  #   subclass.instance_eval(&block)

  #   append_routes do
  #     get name.underscore.gsub('/', '_') => "#{name.underscore}#index"
  #   end

  #   subclass
  # end


  # def self.append_routes(&block)
  #   Rails.application.routes.append do
  #     namespace(:admin) do
  #       instance_exec(&block)
  #     end
  #   end
  # end

# end

# class AdminSection < Admin
#   def self.index(&config)
#     index = Class.new(AlphaSimprini::Page)
#     index.send :include, AlphaSimprini::Admin::Page
#     index.send :include, base_view
#     view_module.const_set :Index, index
#   end
# end

# class AdminResource < Admin 
#   def self.action_item(name, action, &block)
#     action_items << [name, action, block]
#     if block_given?
#       controller.send :custom_actions, resource: action
#       controller.send :define_method, action, &block
#     end
#     the_action = controller.action(action)
#     the_resources = self.name.underscore.sub('/', '_').gsub(/_admin/, '')
#     Rails.application.routes.append do
#       namespace :admin do
#         resources the_resources, only: [] do
#           member do
#             post action
#           end
#         end
#       end
#     end
#   end


# end