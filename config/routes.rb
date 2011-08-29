Rails.application.routes.draw do
  match "/alpha_simprini/test" => "alpha_simprini/test#root" unless Rails.env.production?
end