module AlphaSimprini::Admin
  extend ActiveSupport::Concern
  Kernel.require "alpha_simprini/admin/controller_module"
  include AlphaSimprini::Admin::ControllerModule

  # When the admin engine is inerited we isolate the namespace and
  # give ourselves reflection on the sections

  included do
    ActiveSupport::Dependencies.autoloaded_constants << name
    ActiveSupport::Dependencies.mark_for_unload(self)

    self.called_from = Rails.root
    class_attribute :sections
    reset!
    append_routes do
      root to: "index#dashboard"
    end
  end

  module ClassMethods
    def reset!
      self.sections = []
      isolate_namespace self

      const_set(:IndexController, index_controller)
      const_set(:Index, Module.new)
      const_get(:Index).send(:const_set, :Views, views)
      views.send(:const_set, :Dashboard, dashboard)
    end

    def action_items
      []
    end

    def append_routes(&block)
      self.routes.eval_block(block)
    end

    def dashboard
      @dashboard ||= generate_view
    end

    def view_module
      @view_module ||= Module.new
    end

    def controller_module
      @controller_module ||= Module.new
    end

    def views
      @views ||= Module.new
    end

    def view(&block)
      view_module.class_eval(&block)
    end

    def controller(&block)
      controller_module.class_eval(&block)
    end

    def generate_controller(superclass=base_controller, &config)
      _url_helpers = routes.url_helpers
      _controller_module = controller_module

      controller = Class.new(superclass) do
        append_view_path AlphaSimprini::AdminViewResolver.new
        class_attribute :engine
        include _url_helpers
        helper _url_helpers
        include _controller_module
        instance_eval(&config) if block_given?
      end
      controller.send(:remove_instance_variable, :@parent_name)
      controller.engine = self
      controller
    end

    def generate_view(superclass=AlphaSimprini::Page)
      _view_module = view_module

      view = Class.new(superclass) do
        include AlphaSimprini::Admin::Page
        include _view_module
      end

      view.engine = self
      view  
    end

    def index_controller
      @index_controller ||= generate_controller do
        define_method(:dashboard) { render }
      end
    end

    def register model, &config
      if model.is_a?(Class) && model < ActiveRecord::Base
        name = model.name.demodulize
        section = const_set(name.pluralize, Resource.generate(self, model))
        section.setup!(&config)
        self.sections << section
      else
        name = model.to_s.demodulize
        section = const_set(name.pluralize, Component.generate(self, model))
        section.setup!(&config)
        self.sections << section
      end
    end
  end

end
