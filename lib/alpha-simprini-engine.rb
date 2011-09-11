module AlphaSimpriniEngine
  require "inherited_resources"
  require "alpha_simprini/page"
  require "alpha_simprini/packer"
  
  class Engine < Rails::Engine
    config.autoload_paths += %w(#{config.root}/app)
    # Does coool things like give us
    initializer "alpha-simprini-engine.erector", before: :set_autoload_paths do |app|
      app.config.autoload_paths += %W(#{app.root}/app #{AlphaSimpriniEngine::Engine.root}/app)
    end
    
    initializer "alpha-simprini-engine.extras", before: :set_autoload_paths do |app|
      app.config.autoload_paths += %W(#{app.root}/extras #{AlphaSimpriniEngine::Engine.root}/extras)
    end
    
    initializer "alpha-simprini-engine.sprockets.engine_processor" do |app|
      require "alpha_simprini/directive_processor"
      
      app.assets.unregister_processor("text/javascript", Sprockets::DirectiveProcessor)
      app.assets.register_processor("text/javascript", AlphaSimprini::DirectiveProcessor)

      app.assets.unregister_processor("application/javascript", Sprockets::DirectiveProcessor)
      app.assets.register_processor("application/javascript", AlphaSimprini::DirectiveProcessor)
    end
    
    # Set things up for erector
    initializer "alpha-simprini-engine.controller" do |app|
      # Layout nil required for erector integration`
      ApplicationController.send :layout, nil
    end
  end
end
