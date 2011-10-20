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

  s.add_dependency "rails", "~> 3.1.0"
  s.add_dependency "erector", "~> 0.9.0.pre1"
  s.add_dependency "inherited_resources", "~> 1.2.2"
  s.add_dependency 'sass-rails', "  ~> 3.1.0"
  s.add_dependency 'coffee-rails', "~> 3.1.0"
  s.add_dependency 'msgpack'
  s.add_dependency 'compass', "~> 0.12.alpha"

  s.add_development_dependency "sqlite3"
end
