module AlphaSimpriniEngine
  module ::AlphaSimprini; end

  require "rails/all"
  require "inherited_resources"
  require "kaminari"
  require "alpha_simprini/widget"
  require "alpha_simprini/page"
  require "alpha_simprini/admin"
  require "alpha_simprini/admin/path_helpers"
  require "alpha_simprini/admin/page"
  require "alpha_simprini/admin/action_items"
  require "alpha_simprini/admin/component"
  require "alpha_simprini/admin/filter"
  require "alpha_simprini/admin/date_filter"
  require "alpha_simprini/admin/scope"
  require "alpha_simprini/admin/sorting"
  require "alpha_simprini/admin/resource"
  require "alpha_simprini/admin/scoped_resource"
  require "alpha_simprini/admin_view_resolver"
  require "alpha_simprini/template_handler"

  begin
    require 'paperclip'
    require 'alpha_simprini/inputs/paperclip_image_input'
  rescue LoadError
    # No paperclip? No paperclip inputs.
  end

  # All scopes will know their own names.
  class ::ActiveRecord::Base
    def self.scope(name, options={}, &block)
      super(name, options) do
        class_eval(&block) if block_given?
        define_method(:scope_name) { name }

        def chained?
          to_sql != klass.send(scope_name).to_sql
        end
      end
    end
  end

  class Engine < Rails::Engine
    config.autoload_paths += %w(#{config.root}/app)

    initializer "alpha-simprini-engine.erector", before: :set_autoload_paths do |app|
      app.config.autoload_paths += %W(#{app.root}/app #{AlphaSimpriniEngine::Engine.root}/app)
    end
    
    initializer "alpha-simprini-engine.extras", before: :set_autoload_paths do |app|
      app.config.autoload_paths += %W(#{app.root}/extras #{AlphaSimpriniEngine::Engine.root}/extras)
    end

    # Set things up for erector
    initializer "alpha-simprini-engine.controller" do |app|
      # Layout nil required for erector integration`
      ApplicationController.send :layout, nil
    end

    config.to_prepare do
      # Rails.logger.info "AS::Engines: #{AlphaSimprini::Admin.descendants}"
      # AlphaSimprini::Admin.descendants.each do |subclass|
      #   subclass.reset!
      # end

      Dir[Rails.root.join("app", "{admin,engines}", "**", "*.rb")].each do |file|
        next if File.directory?(file)
        Rails.logger.info "loading #{file}!"
        Kernel.load file
      end

      # Routes must be reloaded and re-mounted every time this engine is
      #  prepared. mount prefixes get screwed up when they arent reloaded.
      Rails.application.routes_reloader.reload!
      # AlphaSimprini::Admin.descendants.each do |subclass|
      #   subclass.routes.finalize!
      # end
    end

    config.watchable_files += Dir.glob\
      File.join(File.dirname(__FILE__), '**', '*.rb')
  end
end
