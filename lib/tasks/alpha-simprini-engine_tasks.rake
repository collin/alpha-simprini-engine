namespace :alpha_simprini do
  desc "install a version of alpha simprini"
  task  :install, [:version] do |t, args|
    version = args[:version] or raise "SPECIFY a VERSION string for Alpha Simprini"

    package = "http://cloud.github.com/downloads/collin/alpha_simprini/alpha_simprini-#{version}.html"

    cmd = %|hip install --file="#{package}" --out="app/javascripts/vendor/alpha_simprini"|
    puts cmd
    system cmd
  end
end