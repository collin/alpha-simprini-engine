$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "alpha-simprini-engine/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "alpha-simprini-engine"
  s.version     = AlphaSimpriniEngine::VERSION
  s.authors     = ["Collin Miller"]
  s.email       = ["collintmiller@gmail.com"]
  s.homepage    = "http://alpha-simprini.com"
  s.summary     = "A Rails Engine full of Joy used for ALPHA SIMPRINI applications"
  s.description = "Comes with some plugins configured and some coffeescript/css/assets preloaded for JOY"

  s.files = Dir["{app,config,db,lib,extras}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.3"
  s.add_dependency "jquery-rails", "~> 2.1.3"
  s.add_dependency "erector", "~> 0.9.0.pre1"
  s.add_dependency "html_package", "~> 0.0.6"
  s.add_dependency "kaminari", "~> 0.14.1"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "websocket-rack"
  s.add_development_dependency "listen"  
end
