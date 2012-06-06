module AlphaSimpriniEngine
  require "inherited_resources"
  require "alpha_simprini/page"

  if Rails.env.production?
    require_relative "./../app/views"
    require_relative "./../app/views/resources"
    require_relative "./../app/views/resources/base"
    require_relative "./../app/views/resources/form"
    require_relative "./../app/views/resources/edit"
    require_relative "./../app/views/resources/index"
    require_relative "./../app/views/resources/new"
    require_relative "./../app/views/resources/show"
    require_relative "./../app/views/resources/show_has_many"
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
  end
end
