module AlphaSimpriniEngine
  require "alpha_simprini/page"
  
  class Engine < Rails::Engine
    config.autoload_paths += %w(#{config.root}/app)
    # Does coool things like give us
    initializer "alpha-simprini-engine.erector", before: :set_autoload_paths do |app|
      app.config.autoload_paths += %W(#{app.root}/app #{AlphaSimpriniEngine::Engine.root}/app)
    end
    
    # Set things up for erector
    initializer "alpha-simprini-engine.controller" do |app|
      # Layout nil required for erector integration`
      ApplicationController.send :layout, nil
    end
  end
end
