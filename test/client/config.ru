require 'rack/websocket'
require 'logger'
require 'json'
require 'listen'

QUNIT = File.join(__FILE__, '../../../vendor/qunit')
SCRIPTS = File.join(__FILE__, '../../../vendor/assets/javascripts')
TESTS = File.dirname(__FILE__)
LIBS = File.join __FILE__, '../../../app/assets/javascripts/alpha_simprini/stacker'

class TestApp < Rack::WebSocket::Application
  attr_accessor :logger

  def initialize
    @logger = Logger.new($stdout)
    super
  end

  def on_open(env)
    logger.info "Connected to client."
    start_listening
  end

  def on_close(env)
    logger.info "Client disconnected."
    stop_listening
  end

  def on_error(env, error)
    logger.error "ERROR! #{error}"
    stop_listening
  end

  def start_listening
    @listener = Listen.to(TESTS, LIBS)
    @listener.change(&method(:on_modification))
    @listener.start(false)
    logger.info "Listening..."
  end

  def stop_listening
    logger.info "Stopped listening."    
    @listener and @listener.stop
  end

  def any(items) items.first end

  def on_modification(modified, added, removed)
    return unless any modified + added + removed
    logger.info "modified: #{modified}"
    send_data JSON.dump(name: 'restart')
  end
end

class NeverCache
  def initialize(app); @app = app end

  def call(env)
    status, headers, body = @app.call(env)
    headers["Cache-Control"] = 'no-cache'
    [status, headers, body]
  end
end

module YakTest
  require 'sinatra'
  class Application < Sinatra::Base
    post '/' do
      suite_name = params[:suite_name]
      puts "Writing '#{suite_name}.yak'..."
      raise "Missing parameter suite_name" unless suite_name
      File.open "./#{suite_name}.yak", "w+" do |f|
        f.write params[:dump]
      end
      puts "Done!"
    end

    get '/' do
      suite_name = params[:suite_name]
      puts "Loading '#{suite_name}.yak'"
      open("./#{suite_name}.yak").read
    end
  end
end

use NeverCache

map '/control' do
  run TestApp.new
end

map '/suites' do
  run YakTest::Application
end

map '/qunit' do
  run Rack::Directory.new( QUNIT )
end

map '/javascripts' do
  run Rack::Directory.new( SCRIPTS )
end

map '/source' do
  run Rack::Directory.new( LIBS )
end

map '/' do
  run Rack::Directory.new( File.dirname(__FILE__) )
end